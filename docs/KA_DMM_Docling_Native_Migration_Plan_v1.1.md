# KA-DMM：Knowledge Agent 文件模型遷移與 DS 淘汰計畫

> **此版本已由 v1.2 取代。最新版本：** [KA-DMM v1.2（含官方 Docling 上游鬆耦合與版本升級 Gate）](./KA_DMM_Docling_Native_Migration_Plan_v1.2.md)。請勿再以 v1.1 作為 Coding Agent 的執行基準。

> **文件版本**：v1.1  
> **規劃日期**：2026-11-06  
> **適用專案**：現有 `knowledgeAgent` Repository  
> **文件性質**：交付 Coding Agent 的可執行工程計畫與分批驗收規格  
> **目前狀態**：**尚未在實際 Repository 執行驗證；下列路徑來自 2026-11-06 的程式接線盤點。**  
> **變更政策**：先探測、再建立基準、再影子實作、最後逐段切換；任何批次不得跳過 Gate。  
> **第一輪僅授權**：P0、M0、M1 的調查、證據與測試基礎工作。**不得直接替換、刪除 DS、遷移正式 DB 或切換正式 Index。**

---

## 0. 專案目的與不可妥協原則

### 0.1 要解決的問題

目前 KA 將自訂 `DocumentStructure`（下稱 **DS**）作為多格式文件的共用內容模型。即使外部或上游已提供 DocLang / DCLX，仍經過 `DCLX → Docling Core → DS`；有效內容又可經 `DS → DCLX` 投影至 Viewer。這形成兩套文件語意與重複的轉換維護責任，亦已存在非完全映射的證據。

本計畫的**候選目標**是以 Docling 原生 `DoclingDocument` 作為唯一共用文件內容模型，逐步淘汰 DS。`DocLang` 是 XML 文件表示，`DCLX` 是封裝 DocLang 及資產的容器；DoclingDocument JSON 用於保存原生模型。KA 自有的審核、修訂、權限、lineage、來源證據繼續作為獨立領域資料。**上述方向是待驗證的架構假設，尚非已驗收事實。**

### 0.2 最終成功定義

1. 所有正式文件入口都可以在**不先構造 DS**的前提下提供共用內容；無必要的 `Docling → DS → DocLang` 往返。
2. 原始檔、DoclingDocument JSON、所需 assets、來源證據與治理事件能完整保存與重新讀取。
3. Review、Draft、Effective Document、Approval、Conflict Detection、Chunk Planner、Index、Retrieval、Groundedness、Viewer 的可觀察行為不退化。
4. PDF、Excel、PowerPoint 等原生證據精度保持；不能為了統一成 Docling 而刪掉 Excel 公式或 PPT 圖表等專有資料。
5. 正式讀寫路徑、共用資料契約、Index Producer 不再依賴 DS。舊 DS Reader 僅可在有期限、隔離的歷史遷移工具中存在。
6. 任一 Gate 失敗均能停止擴張修改，且正式資料、正式索引、使用者修訂不受測試影響。

### 0.3 嚴格限制

- **不建立新 Repository、不另開新產品**，在 `knowledgeAgent` 原專案演進。
- 不在同一批次同時更換 Docling 版本、Chunk 演算法、Embedding Model、Vector DB 或 Reranker。
- 不把 DS 換名為 `CanonicalBlockV2`、`UnifiedDocument` 等另一個完整文件樹；Extension 只能補原生模型欠缺的特定語意。
- 不以「編譯成功」「API 存在」「測試數量很多」當作產品等效證據。
- 不自動讀取秘密、不連線外部未授權服務、不在正式環境做破壞性試驗。
- Office / DCLX 的特殊能力要逐項驗證，不能從文件格式被宣稱支援，推論其中所有語意均受支援。

---

## 1. 名詞與預期依賴邊界

| 名稱 | 定位 | 在目標架構中的責任 |
|---|---|---|
| `Docling` | 文件解析與轉換框架 | 接收 PDF / Office / HTML 等輸入，必要時搭配既有專用 parser |
| `DoclingDocument` | Docling 原生 Python / Pydantic 文件模型 | **候選唯一共用內容模型**；輸入 Chunking、Editor projection 等 |
| `DoclingDocument JSON` | 原生模型序列化 | 持久化共用內容；要與 schema version、assets、source 一起驗證 |
| `DocLang`（`.dclg`） | XML 文件表示 | 交換、Viewer、文件傳遞；不可預設與 Docling JSON 完全無損等價 |
| `DCLX`（`.dclx`） | DocLang 與圖片／頁面等資產的封裝 | 匯入、交換及原始封裝保存 |
| `DS` | KA 自訂 DocumentStructure | **計畫淘汰的共用內容模型** |
| `Effective Document` | 來源、人工修訂、AI 補充經採用政策形成的有效內容 | KA 應用治理；可保留領域契約，但底層不應綁 DS |
| `Evidence Extension` | Docling 未充分承載的 Office 原生證據／來源 selector | **局部自訂**；不得重新實作通用 Page / Text / Table 文件樹 |
| `Document Map` | 展示、索引投影 | 衍生產物，不當成保存的 canonical 母本 |

目標流程：

```text
Source files / Direct DCLX / External MD ZIP / MCP result
                           |
                    Parser / Adapter
                           |
                    DoclingDocument
                     |           |
             Docling JSON     KA Evidence Extension
                     |           |
                     +-----+-----+
                           |
            Governance / Review / Effective
                           |
                Chunk + evidence lineage
                           |
              Index / Retrieval / Groundedness
                           |
                   Agent / LLM response

DocLang / DCLX：原始或有效文件的交換與 Viewer 投影，不取代核心 JSON 保存。
```

**注意**：`DoclingDocument`、`DocLang`、`DCLX` 同屬一套文件體系，但不表示彼此所有欄位皆能無損往返。是否足以取代 DS，要以 P0 的實機測試證明。

---

# 第一部分：先做 Docling 可行性確認（P0，強制先行）

## P0.0 目的與 Gate 原則

P0 是真正的**遷移啟動前 Gate**，負責查出「目前版本實際能做什麼、哪裡尚未支援、需要哪些 Extension」，避免架構決策建立在官方最新版文件、其他版本範例或想像中的 API 上。

P0 **只允許盤點、探測、建立測試與產出報告**。不准重構產品、不准升級正式依賴、不准進行 DB 遷移。

將每項能力明確標記四層狀態：

- **D（Documented）**：文件或原始碼提到；尚未實測。
- **A（API Present）**：KA 指定環境的實際可 import/呼叫；尚未確認輸出正確。
- **F（Fixture Passed）**：在指定版本，使用可留存、可重跑的代表性檔案，完成行為驗證。
- **R（Replacement Ready）**：通過真實 KA 使用情境、資料完整性、相容性及缺陷注入驗證，足以接替 DS 的該項責任。

**不能用 D 或 A 代替 F / R；未證實一律標記 `UNKNOWN` 或 `BLOCKED`。**

## P0.1 凍結實際安裝版本與相依關係

依照現有 Repository 真正執行 KA 的 venv / container 收集，而非機器的全域 Python：

- `python --version`
- `python -m pip show docling docling-core doclang pydantic`
- `python -m pip freeze` 或相同等級的 lockfile 快照
- `python -m pip check`
- Container image digest、Python 執行路徑、OS、鎖定檔與安裝 extras
- `docling` 與 `docling-core` 必須分別盤點，避免將兩個套件的版本混淆。
- 列出 Viewer 使用的 DocLang／DCLX 解析器版本與其相容性限制。

**版本注意**：先前盤點指出本機 `docling-core==2.105.0`，但尚未由本計畫重新實測。公開 PyPI 顯示 `docling-core==2.106.0` 已於 **2026-11-04** 發布，因此 **2.105.0 並非截至 2026-11-06 的最新版**。本遷移先以實際已安裝版本作為 Baseline，2.106.0 僅列候選版本另做隔離比較，**不得直接升級**。

建議建立 `scripts/audit_docling_environment.py`，只做 introspection、輸出 JSON，至少包括：

```python
from importlib import metadata, util
import json
import sys

names = ["docling", "docling-core", "doclang", "pydantic"]
report = {"python": sys.version, "packages": {}, "modules": {}}
for name in names:
    try:
        report["packages"][name] = metadata.version(name)
    except metadata.PackageNotFoundError:
        report["packages"][name] = None
for name in [
    "docling", "docling_core", "doclang",
    "docling_core.types.doc", "docling_core.transforms.chunker.hybrid_chunker"
]:
    try:
        report["modules"][name] = util.find_spec(name) is not None
    except (ImportError, ModuleNotFoundError, ValueError) as exc:
        report["modules"][name] = f"ERROR: {type(exc).__name__}: {exc}"
print(json.dumps(report, ensure_ascii=False, indent=2))
```

> 這只是環境採集範例，不能取代能力測試；實際模組與 public API 需以本機 introspection 結果為準。`find_spec` 的結果不是功能可用證據。

## P0.2 建立「支援能力矩陣」，至少逐項檢查

| ID | 必測能力 | 最小實驗與證據 | 對 DS 替換的重要性 |
|---|---|---|---|
| P0-C01 | `DoclingDocument` 建立、校驗、遍歷 | 真正建立／載入文件並遍歷節點 | 核心模型可用性 |
| P0-C02 | JSON 保存／載入 | 存檔後用**新 process**重新載入；結構比較 | 核心持久化 |
| P0-C03 | DocLang XML 匯出／匯入 | 用真實 `.dclg`；比對正文、metadata、未知節點 | 交換能力 |
| P0-C04 | DCLX 匯出／匯入 | 以真實 `.dclx` 比對封裝、資產、頁面 | Viewer / 資產 |
| P0-C05 | DCLX 原封裝保留 | 未知 XML / 未識別 assets 仍保留原始位元組 | 防止靜默遺失 |
| P0-C06 | Heading / List / Code / Caption | 對應上下文及關係可重建 | 結構性 Chunk |
| P0-C07 | Reading Order / Group / Section | 跨頁與巢狀組織可表示 | 內容次序 |
| P0-C08 | Table / Cell / Span / Footnote | merged cell、multi-caption、腳註 | 表格理解 |
| P0-C09 | Picture / bbox / provenance | 圖片尺寸、頁面、來源座標與資產可回溯 | Groundedness |
| P0-C10 | Inline formatting / links / annotation | XML 混合內容 round-trip | 交換保真 |
| P0-C11 | DocLang unknown / future nodes | 不認識元素的處理策略及資訊保留 | 前向相容 |
| P0-C12 | HTML / Markdown / PDF / DOCX | 載入並生成完整原生文件，含非文字結構 | 原生入口 |
| P0-C13 | XLSX formula / cached value | 公式文字、計算值、位址、工作表 | 專有證據 |
| P0-C14 | XLSX named ranges / references | 含跨表引用與命名範圍 | 精確引用 |
| P0-C15 | PPTX shape / chart series / workbook | chart series、shape ID、嵌入資料來源 | 精確引用 |
| P0-C16 | `BaseChunker` / `HybridChunker` | 指定模型 tokenizer 下的 chunk、contextualize | RAG 接線 |
| P0-C17 | Extensions / metadata | 自訂欄位可保存、重載、驗證與關聯 | 減少自造模型 |
| P0-C18 | Stable source anchor / remap | 前置節點改動後 `self_ref` 變化的重新定位 | 長期 lineage |
| P0-C19 | 有效文件編輯與投影 | 修改後能否安全重建 JSON / DCLX | Review |
| P0-C20 | 大檔 / 壞檔 / 非預期輸入 | 界限、記憶體、錯誤類型、不完整輸出 | 生產可靠性 |

P0-C13 至 C15 **不能因為 Docling 可以讀 XLSX / PPTX 就填寫 PASS**。需要以現有 `native_canonical_adapter.py` 與 `pptx_canonical_adapter.py` 所保留的來源語意當作比較基準。

## P0.3 兩階段實際探測

**第一層：API 探測**

- 由本機 `inspect.signature()`、實際 imports、Docling Core 模型 fields、Git lockfile、官方文件比對 API。
- 明列實際 callable 名稱、型別、所屬套件及版本，保存逐項調用日誌。
- 不准憑搜尋到的 API 名稱直接修改正式流程。

**第二層：語意探測**

- 由 Golden Corpus 中挑選 10 至 15 個**關鍵小型 Fixture**，至少覆蓋 P0-C01 至 C20 相關能力。
- 用 Docling 原生 API 建立、序列化、存檔、重新載入，比對行為與來源資訊。
- 對 DocLang / DCLX 進行 `source → DoclingDocument → export → import` 的指定欄位比較。
- 對 unknown XML 使用「保留原封裝＋顯式告警」，不得測試通過後把未知資料刪掉。
- 不強制 XML 逐字元相同，但必須對每個業務必要語意建立可重跑斷言。

每項探測記錄 `PASS / FAIL / PARTIAL / UNKNOWN / NOT_SUPPORTED`。`PARTIAL` 必須列出缺漏欄位及備援方案。

## P0.4 Docling 能力缺口的決策表

| 條件 | 處置 |
|---|---|
| 原生模型與 JSON 足以承載 | 直接使用，不另做平行 Schema |
| 原生部分支援且可用局部 metadata / extension 補足 | 實作最小 Extension，獨立測試 |
| 只是 Python API 缺乏，但原生語意可表示 | 經核准建立薄 Adapter，**禁止變成文件模型** |
| Office 專有證據無法原生表示 | 獨立 Typed Evidence Store，與原始檔、Docling anchor 對應 |
| DCLX / DocLang 轉換不可逆 | 保留原始 DCLX；有效文件輸出標記為 projection |
| 原生表示連關鍵語意都無法承載 | **BLOCK**；不得用自造第二套 DS 遮蔽問題 |
| 升級新版可能解決 | 隔離環境重跑 P0；獨立版本升級 ADR 與回歸測試 |

針對「是否仍應保留 DS」必須產出逐項、可挑戰的理由。不能用「既有程式依賴很多」當成合理性理由，那只是遷移成本。

## P0.5 與目前 KA 接線逐一核對

以下是**待現場復核的線索**，不是已完成的新驗收：

- `ingestion_service/external_archive_import.py:100`，外部結果匯入。
- `ingestion_service/dclx_structure_adapter.py:48,83,147,203`，DCLX → DS 能力及失真。
- `ingestion_service/file_preprocessor_mcp.py:631`，MCP 外部結果回收。
- `ingestion_service/document_parser.py:400,435,456`，DS 的 Page / Block 契約。
- `ingestion_service/canonical_document.py:232,265,593,668,700,727,923`，來源及 identity。
- `ingestion_service/prepared_document.py:253,918`，bundle 與 digest。
- `ingestion_service/structure_review.py:105`、`static/document_structure_review.js:421,1232,1415`，Review 與 viewer 操作。
- `ingestion_service/effective_document.py:457`、`ingestion_service/effective_document_runtime.py:1030,1253`，治理與有效內容。
- `ingestion_service/chunk_planner.py:569`、`ingestion_service/canonical_chunk_projection.py:371,659`，切塊與引用。
- `serving_layer/indexing.py:625`、`serving_layer/groundedness.py:41`，索引與證據。
- `ingestion_service/native_canonical_adapter.py:824`、`ingestion_service/pptx_canonical_adapter.py:546,720`，Office 原生證據。
- `ingestion_service/structure_export.py:326`、`artifacts/doclang-viewer/upstream/viewer.js:953`，Viewer 與匯出。
- `.audit/dclx_migration_probe.json`、`docs/dclx_direct_import.md`，既有探測紀錄。

若實際路徑不同，更新報告中的真實位置，不為了符合舊路徑而改程式。

## P0.6 P0 交付物與硬性 Gate

**必交檔案**（建議放在現有 `docs/migrations/ka-dmm/`）：

1. `P0_environment_lock.md`，版本、依賴、Python、容器及相容性資訊。
2. `P0_docling_support_matrix.csv`，每個 C01 至 C20：D/A/F/R、狀態、版本、Fixture、證據路徑、限制。
3. `P0_api_probe.json`，實際 API、signature、異常及測試紀錄。
4. `P0_roundtrip_diff.md`，Docling JSON、DocLang XML、DCLX 的差異與資訊遺失。
5. `P0_gap_and_extension_decision.md`，缺口分級、採用原生/Extension/阻擋決策。
6. `P0_gate_report.md`，准入判定、版本選擇、不可解缺口、下一批限制。
7. 可由 CI 或單一命令重跑的 probe / fixture 測試，保留真實 log。

**Gate P0 = PASS 的條件**：

- 20 項能力全部已調查；重要能力不得保持 `UNKNOWN`。
- 所有關鍵用例有可執行探測及重跑證據，不能只拿文件佐證。
- P0-C02、C04、C09、C13、C14、C15、C16、C17 的核心語意有明確處置：原生 PASS、經驗證的 Extension 或標記 Blocker。
- 已正式確認版本基準及是否需要另案升級。
- **若有 Blocker，P0 結論應是 `CONDITIONAL` 或 `BLOCKED`，禁止直接進入會破壞資料契約的遷移批次。**

P0 決策：`GO`（已可替換）；`CONDITIONAL GO`（具隔離、可驗證的最小擴充）；`BLOCKED`（關鍵資訊無法承接）；`NO-GO`（方案風險或成本不合理，需重新決策）。只有 `GO` 或明文核准的 `CONDITIONAL GO` 能進入後續工作。

---

# 第二部分：建立基準與資料契約（M0、M1）

## M0：凍結現況、Golden Corpus、回退能力

**目的**：在改動之前證明系統基準、已知缺陷、正式資料邊界與回退能力。此步驟不修改 DS 實作。

**工作**：

1. 搜索所有 DS 的 import、序列化、依賴、查詢、UI Contract、DB 持久化及 API 入口。
2. 建立 Golden Corpus；建議最初至少 60 份代表性文件，涵蓋 PDF（含掃描與跨頁表格）、DOCX、XLSX（公式／命名範圍／合併儲存格）、PPTX（圖表／shape／workbook）、HTML、MD、DCLX、外部 MD ZIP、MCP 結果。
3. 為每份文件記錄來源 SHA、現有 DS 結構、Review/Effective snapshot、Chunk/Evidence、主要檢索問答。
4. 對所有既有流程建立固定輸出及可重跑比較器，標記已知問題而非自動把舊版輸出視為正確答案。
5. 建立隔離測試資料庫、Shadow Index、唯讀資料抽樣／匿名化程序。**不需要讀取正式秘密**。
6. 完成一次恢復演練，記錄 commit、DB / Index snapshot 與恢復命令。

**Gate M0**：重要流程測試可重跑；Corpus 與預期語意由人工審查；資料快照驗證有效；已知缺陷獨立紀錄；回退演練 PASS。若任何一項未完成，不進 M1 的遷移決策。

## M1：DS 欄位責任的 100% 去向審查

**目的**：確認 DS 是否可被完全淘汰，或需何種局部 Extension。**本批仍不修改正式資料契約。**

逐項將 DS 所有欄位歸類：

- **A：Docling 原生**：直接映射到 DoclingDocument。
- **B：KA Governance**：權限、修訂、核准、Effective Policy 等保持獨立領域事件／資料。
- **C：KA Evidence Extension**：Office 原生資料、穩定 Anchor、特殊 selector 等，局部補足。
- **D：可刪冗餘**：有明確無依賴證據後淘汰。
- **E：阻擋**：尚無可證明無損的承接方案。

檢查最少涵蓋：PageContent、ContentBlock、heading、tables/cells/span、pictures/captions、reading order、locator、typed payload、provenance、identity、relations、Excel/PPT 來源專有結構。

**Gate M1**：100% DS 欄位有 A/B/C/D/E 及證據；所有 E 有處置計畫或阻擋決策；不存在以完整平行文件樹取代 DS 的提案；完成 ADR 並明確列出必要的不可破壞契約。

**交付**：`M1_ds_coverage.md`、`M1_contract_inventory.csv`、`ADR_docling_native_model.md`。

---

# 第三部分：分批建立 Docling 原生路徑（M2 至 M4）

## M2：建立完全不經 DS 的 Docling Native Shadow Path

**範圍**：僅隔離路徑，建立 `Source → DoclingDocument → validation`，使用本機 P0 已確認的實際 API，不修改正式業務入口，不把 DS 重新包裝成新型別。

**測試**：文字、圖、表格、heading、bbox、來源 anchor，含 DocLang 未知節點保留策略；基礎資料遍歷及 schema validation；壞檔防護。

**Gate M2**：主要 Fixture 能由原生路徑獨立解析；所有未知／不支援內容都產生可追溯診斷；無 DS import；舊路徑完全不變。**失敗時直接關閉 Shadow Flag。**

## M3：原生持久化與 Reader 的影子寫入

新 bundle 建議結構：

```text
prepared_bundle/
  manifest.json
  source/original.*
  canonical/docling_document.json
  extensions/native_evidence.json
  assets/...
  governance/...
```

保存必須帶 `source_sha`、`prepared_artifact_id`、parser recipe、Docling Core version、Schema version、extension version、assets digest、document/effective revision，並在另一次 process / container 重載驗證。

**邏輯**：先 `DS official write + Docling shadow write`；影子寫入失敗不得污染正式狀態；確保原始 DCLX 以原檔保存，而非只保存再生成 XML。

**Gate M3**：全部關鍵 Fixture 可寫入、重啟載入、schema 驗證、digest 驗證；故障注入（中斷寫入、缺資產、錯版本、損壞 manifest）被正確拒絕；舊 bundle 仍可正常載入；尚未替換正式 Reader。

## M4：逐一遷移四類來源入口

每個子批次是獨立 WorkItem、獨立提交、獨立 Gate：

- **M4.1** 原生 PDF / Office / HTML / MD / TXT；原生 Office 證據可以用專用 parser 進入 Evidence Extension。
- **M4.2** 直接 DCLX 匯入；原封裝與未知 XML 不得遺失。
- **M4.3** 外部 UI 手動下載 MD ZIP；不假設必須先轉 DCLX。
- **M4.4** 自動 MCP 外部結果；維持外部專案獨立，不擅自改外部服務，也不假設已可自動取得 DCLX。

**每個子 Gate**：同一來源文件新舊並跑；Source / Structure / Evidence 差異報告可重跑；核心語意缺漏 0；不影響其他入口；異常可單獨關閉該來源的新入口 Flag。

---

# 第四部分：治理、證據、Chunk 與 RAG（M5 至 M8）

## M5：Review / Draft / Effective Document

切成三個獨立子 Gate：

- **M5.1 唯讀**：新模型能驅動 Review 的分頁、區塊顯示與定位；UI 操作仍走舊版。
- **M5.2 Draft**：編輯、預期 Revision、Source SHA、衝突保護與修改紀錄保持正確；測試可能重新切塊的情況。
- **M5.3 Effective**：Review 採用／拒絕、AI 補充、Effective Snapshot、作者與審核證據保持可重建。

**Gate**：舊版和新版在固定事件序列的審核結果相同；未核准內容不可進入有效文件；原始文件不被編輯覆蓋；有可重播／可回退的編輯事件，否則不得開啟新版正式寫入。

## M6：Evidence、Source Locator、Anchor 穩定性

**優先保護**：

- PDF 原頁位置、block bbox、引用 selectors。
- XLSX 的 worksheet / range / cell / formula / cached value / named range。
- PPTX 的 slide / shape / chart series / embedded workbook。
- 原始 source 及 parser 版本、Effective revision、證據身份。

設計 stable **KA Anchor ID** 與解析器的 `self_ref`、DocLang XPath 分離。使用 anchor map 進行升級／重新解析後 remap，若不確定應標記 unresolved，**不能錯引到另一節點**。

**Gate**：所有 critical Evidence Fixture 均能精確定位；多版本 remap 不產生錯誤確證；Excel/PPT 不能降級為純文字證據；未解決 anchor 不得成為 Verified Fact。

## M7：保留原策略，只改 Chunk Planner 的輸入契約

重點修改既有 `chunk_planner.py`、`canonical_chunk_projection.py` 的輸入，不在此批替換為 HybridChunker 或更改切塊策略。

保持 section、reading order、text/table boundaries、token policy、selector、Effective lineage。Embedding Payload 與 Evidence Payload 分開驗證。

**Gate**：完全不依賴 DS 能產出 Chunk；語意、上下文與證據引用符合 Golden Baseline；差異逐項分類為有意變更或缺陷；固定 token policy 下不出現無法解釋的內容缺失。

## M8：獨立 Shadow Index 與 RAG 行為驗收

固定相同 Embedding Model、Tokenizer、Chunk Policy、Reranker、Retrieval 設定；**新舊 Index 物理隔離**。

測試集至少包括精確條文、表格數值、跨章節推理、多文件引用、Excel formula / range、PPT chart、圖片 caption、矛盾證據、無證據拒答。

| 指標 | 初始 Gate（M0 基準核准後才固定） |
|---|---|
| 關鍵 Evidence 定位 | **100% 正確，錯誤確證 = 0** |
| 原始來源及修訂歸屬 | **100% 正確** |
| Critical Q&A / Groundedness | **不得有關鍵退化** |
| Recall@10 | 不低於舊版超過 2 個百分點的暫定門檻 |
| nDCG@10 | 不低於舊版超過 2 個百分點的暫定門檻 |
| 局部精確要求案例 | 遵守專案既定更嚴格 Gate，不以整體平均抵銷錯誤 |
| Regression | 本批受影響既有測試 100% 通過 |

`2 個百分點` 僅為建議初始容差，須於 M0 由實際問題數量、統計可信度與安全門檻定案。不能利用調整門檻讓未達標的遷移過關。

**Gate M8**：有問答逐案比較及人工抽檢，Shadow Index 不污染正式 Index；性能、成本、正確性差異均可重現。

---

# 第五部分：Viewer、正式切換、清除 DS（M9 至 M10）

## M9：原始 DCLX 與有效文件 Viewer

保持雙概念：

1. **Original Viewer**：檢視真正原始 DCLX / assets / pages。
2. **Effective Viewer**：從審核後有效內容產生 DocLang / DCLX 投影；若 metadata/pages 不完整，必須明示它是投影，不可宣稱無損備份。

Editor 回寫拆為獨立 M9 子 Gate：修改內容進入**同一文件的 Draft / Approval**，不可繞過審核，也不得默默視為新文件提交。

**Gate M9**：原始與有效路徑可顯示、定位與隔離失敗；圖文表與原始資產正常；DocLang/DCLX 往返差異可查；回寫先經審核。

## M10：切換正式流量、停止 DS、刪除遺留

**切換順序**：

1. 完成 M0 至 M9 Gate，固定 release candidate、schema/version、影子索引。
2. 驗證資料備份、恢復點與回退策略，做一次實際演練。
3. 唯讀 Canary：開新讀取路徑並監控失敗率、錯誤引用與差異。
4. 有狀態寫入 Canary：先小範圍測試新增文件與 Review 事件；確保舊路徑有可驗證的讀取或重播能力。
5. 擴大新路徑、切換正式 Index alias；停止正式 DS 寫入。
6. 隔離舊版遷移 Reader，建立期限、Owner 與刪除 Gate。
7. 刪除正式 DS model、DS serializer、DCLX→DS adapter、DS→DocLang projection 及無用測試；保持必要的歷史遷移程式與證據。
8. 靜態依賴掃描與全回歸，證明正式業務路徑對 DS 的 reference = 0。

**Gate M10**：正式處理與產品 API 無 DS 依賴；全功能與來源證據達標；歷史資料可讀；備份與恢復完成；沒有 P0/P1 級問題；Owner 簽核。

---

# 第六部分：跨批次的強制驗收與回退

## 6.1 六類強制測試

| 類別 | 例子 |
|---|---|
| Unit | Model validation、序列化、selector、anchor、mapping |
| Integration | Parser → Model → Effective → Chunk → Retrieval |
| Golden Corpus | 必要內容及原生證據不流失 |
| Regression | 舊 API、Review、RAG、Viewer 行為不退化 |
| Failure Injection | 損壞 JSON、缺失 asset、XPath 改變、版本衝突、半成品寫入 |
| Rollback | 不同切換階段回退後的資料與編輯事件完整性 |

每批需記錄**執行環境**、資料集版本、命令、Commit SHA、測試數、失敗數、輸出檔與風險。所有報告路徑相對 repo，供下一輪審查與復跑。

## 6.2 回退層級

- **L1：正式流量未改**，關閉 Shadow Flag；舊路徑不受影響。
- **L2：新路徑只承接讀取**，切回舊 Reader；確定舊 bundle / index 未覆蓋。
- **L3：新路徑已正式寫入**，**不得只關 Flag 就宣稱回退成功**。必須隔離寫入、保存事件、驗證新版事件是否可在舊版重播，必要時恢復檢查點並重新投影。未經 L3 演練不得打開正式寫入。

## 6.3 每批 Stop Conditions

任何一項成立，當批立即標記 `BLOCKED`，不得擴大範圍：

- Critical Evidence 丟失、錯誤指向或 unknown XML 無聲丟棄。
- 無法重新載入已保存文件或 asset digest 驗證失敗。
- Review 的預期修訂／審核政策出現不一致。
- RAG 有關鍵資料引用或品質退化。
- 新 Adapter 又重建一套完整文件 Page/Block/Table 結構。
- 不能在隔離環境證明回退、或觸及未授權正式資料。
- 把版本升級與模型遷移混同，無法歸因。

---

# 第七部分：進度、批次授權與 Agent 交付規則

## 7.1 Gate 清單

| Batch | 邊界 | 核心產物 | 未過 Gate 前不可做 |
|---|---|---|---|
| **P0** | 實際 Docling 能力 | 版本、API、20 項矩陣、缺口報告 | **任何 DS 替換** |
| **M0** | 現況基準 | Golden Corpus、測試、回退 | 改動正式資料契約 |
| **M1** | 架構去向 | DS 欄位 100% 歸屬、ADR | 刪 DS |
| **M2** | 原生 Shadow | DoclingDocument-only path | 正式接入 |
| **M3** | 持久化 | 原生 JSON shadow bundle | 正式 Reader 切換 |
| **M4.1–4.4** | 分來源匯入 | 新舊對照與來源驗收 | 一次切所有入口 |
| **M5.1–5.3** | Review/Effective | Draft / Adoption 等效證據 | 無回退的正式寫入 |
| **M6** | Evidence/Anchor | 精確來源及 remap 證據 | 降級成文字證據 |
| **M7** | Chunk 輸入 | 無 DS chunk producer | 同時改 chunk 策略 |
| **M8** | RAG Shadow | 品質、groundedness、索引比較 | 污染正式 Index |
| **M9** | Viewer | Original/Effective viewer | 繞過 approval 回寫 |
| **M10** | Canary / Cleanup | 正式零 DS 依賴、恢復證據 | 未過 Gate 刪歷史 reader |

## 7.2 Coding Agent 強制交付格式

每批提交以下完整記錄，不得把「有測試數字」或「Agent 活動完成」當成驗收完成：

```text
Batch / WorkItem：
狀態：PLANNED | IMPLEMENTED | TESTED | PASS | FAIL | BLOCKED
環境：Isolated / Shadow / Staging / Production
Repo / Branch / Commit：
本批授權修改邊界：
實際修改檔案與原因：
新增 / 取代 / 保留 / 刪除的資料契約：
測試命令與版本：
Tests Passed / Failed / Skipped：
Golden Corpus / Fixture ID：
輸出及可重跑證據路徑：
Critical Evidence 差異：
Index / RAG 指標差異：
異常／未解決風險：
回退方式與實測結果：
是否碰正式資料／秘密／對外服務：
Gate 結果：
需要人工核准的事項：
允許的下一批：
```

批次可以分 Branch / PR，但必須在**同一既有專案**中工作。不能因架構遷移自行新增 Side Project。超出本批責任邊界的新工作，記入後續 WorkItem，不得當輪擴張。

## 7.3 明確指令：第一輪只執行 P0、M0、M1

Coding Agent 在第一輪應：

1. 先閱讀本計畫與前述 KA 程式接線清單。
2. 在現有環境執行 Docling 版本、API 與 DocLang/DCLX 的真實探測。
3. 保存全部可重跑 fixture、輸出與 probe log。
4. 建立 Golden Corpus 基準、已知缺陷及回退程序。
5. 做 DS 100% 欄位責任分類，提出必要 Extension，而不是直接重構。
6. 交出 `P0_gate_report.md`、`M0_gate_report.md`、`M1_gate_report.md` 以及 ADR。
7. **立即停止，等架構 Gate 審核；不自行進入 M2，也不提交替換 DS 的正式程式。**

第一輪驗收的目的是明確回答：

> **如果今天從零開始建立 KA，使用當前實際可用的 Docling／DocLang 能力，還有哪一項理由必須保留 DS？**
>
> 每一項理由都必須有版本、程式位置、fixture、正反案例、資訊保真差異與成本證據。如果沒有，DS 依賴應列為待移除技術債。

---

# 第八部分：公開參考來源與版本查核

這些是**設計與實測的參考資料，不是 KA 本地 PASS 證據**。

1. Docling 官方支援格式表：<https://docling-project.github.io/docling/usage/supported_formats/>  
   官方列有 Docling JSON、DocLang XML、DCLX、chunks 等輸入／輸出；個別 Office 語意仍需 fixture 測試。
2. Docling 官方 Chunking：<https://docling-project.github.io/docling/concepts/chunking/>  
   `BaseChunker` 接收 DoclingDocument；`HybridChunker` 有 tokenizer / optional extras 依賴，需在本機驗證。
3. Docling Core PyPI：<https://pypi.org/project/docling-core/>  
   查得 `2.106.0` 於 **2026-11-04** 發布，**不要沿用「2.105.0 是最新版」的舊判斷**。
4. Docling Core 2.105.0 PyPI：<https://pypi.org/project/docling-core/2.105.0/>  
   盤點所稱的既有版本，仍要由實際 venv 確認。
5. Docling Core releases：<https://github.com/docling-project/docling-core/releases>  
   例如 v2.104.0 changelog 明載 **DocLang 0.8 partial support**，不能當成全規格支援。
6. Docling Core 原始碼相依：<https://github.com/docling-project/docling-core/blob/main/pyproject.toml>  
   確認實際版本對 `doclang`、`chunking` extras 的約束；主分支內容可能隨時間變動，應以版本 tag/lockfile 為準。
7. Docling Graph 的保存格式說明：<https://docling-project.github.io/docling-graph/fundamentals/pipeline-configuration/docling-settings/>  
   說明 Docling JSON 保存與 DocLang 交換各自角色；具體可逆性仍以 KA fixture 為準。

---

## 最終治理決策

**方向**：優先淘汰 DS 作為共用文件內容模型。**前提**：P0、M0、M1 能證明 DoclingDocument 與少量 KA 原生證據擴充可接手全部關鍵責任。其後才按 M2 至 M10 逐批修改、逐批驗收。

**最高原則**：不犧牲原生證據、審核可信度與 RAG 品質來換取架構簡化。若原生能力不足，讓缺口成為可量化、可決策的明確阻擋項，而不是悄悄保留第二套 DS。

# KA-DMM：M2-V0 無 DS 原生路徑交付指引

> **工作指引版本：v1.3，2026-11-06**  
> **狀態：待 Coding Agent 執行，未宣稱任何新增測試通過**  
> **前置版本**：[主計畫 v1.2](./KA_DMM_Docling_Native_Migration_Plan_v1.2.md)、[P0-R 工作指引 v1.2](./KA_DMM_P0_Blocker_Resolution_Execution_Guide_v1.2.md)  
> **執行環境**：既有 Knowledge Agent 專案。公開 caseykcc0124/codex_coding 僅負責工作指令交接。  
> **授權**：一個獨立、隔離、可運行的 M2-V0 Shadow 垂直切片。**不授權全面 M2、M3、正式資料／Index 切換、DS 刪除、Viewer 寫回、部署、升級正式 Docling 套件。**  
> **本輪必須產出**：真實可執行程式與入口、DoclingDocument 原生 JSON 保存重載、現有政策下的 Chunk、可檢索的證據與引用、失敗注入、回歸測試、回退與 Gate 報告。**禁止僅交分析報告。**

## 0. 指令版本與交接原則

本文件是 **Coding Agent 下一個 WorkItem 的唯一新增授權**。既有 R0、R1、R2、R3 的實際資料與報告依本地 Knowledge Agent 的 P0-R 結果為準，不能因新版指令而改寫、作廢或重新宣稱 PASS。舊工作在原指令版本下完成的內容應直接複用。

Coding Agent 必須：

1. 透過已授權 HTTP 讀取本 GitHub 文件，保存 URL、文件版號與**實際取得的 Commit SHA**，不能把主計畫或舊版 GitHub HEAD 混為本輪指引。
2. 在本地 Knowledge Agent 讀取 P0-R 的 README、R0 Baseline、R1/R2/R3 Gate、架構決策與實際測試輸出。若有本地正在執行的 WorkItem，先記錄交接點，不能強行取消或覆蓋。
3. 僅在原有 Knowledge Agent 專案內建立獨立、可隔離的 M2-V0 工作項目、程式與測試。
4. 只把可公開的工作指引放在此公開 Repo。內部檔案、測試資料、執行 log、來源文件、真實路徑、資安設定與完整報告全部留在本地 KA；未經明確授權不得公開上傳或對上游發 Issue。
5. 完成 M2-V0 的交付與 Gate 後停止，等待下一版 GitHub 指引，不得自行擴大至後續批次。

## 1. 固定架構方向及前輪實測的直接應用

**架構方向已選定**：以 DoclingDocument 作為唯一通用文件內容母本，DocLang／DCLX 負責交換和 Viewer，Office 特有證據與 KA 審核／修訂等領域資料獨立保存；逐步讓正式處理路徑不再依賴自訂 DS。

本輪不再以「是否值得淘汰 DS」作為研究題目。既有 R1/R2/R3 的 BLOCKED，表示**完整格式與正式遷移尚不能驗收**，不代表禁止與問題無關的原生 Shadow 路徑實作。

前輪應從本地報告核對並採納的判斷：

| 前輪發現 | 本輪要採取的工程行為 |
|---|---|
| R0 基準可重跑，既有一項 PPTX digest 已知失敗 | 保留既有紅燈並確認沒有新增退化；不能修改 Golden 強行變綠 |
| DS 部分能力尚未驗證，Office Evidence／Governance 有大量獨立責任 | M2-V0 只驗證當輪切片實際消費的內容責任，**不**要求一次承接所有 DS 欄位；不得重建 DS 2.0 |
| DocLang picture.meta.description.text 可以保留描述 | 將「上游完全丟失描述」的籠統判斷改為**依輸入形態／載入版本測試欄位在哪一層遺失**；對未讀取該欄位的 Adapter 提出局部補正，不重寫官方 Serializer |
| bbox 經過正規化 | 以座標系、頁面尺度、轉換後反算定位驗證；**表示改變不能單獨判為 loss** |
| Windows DCLX 圖片 URI 仍有問題 | 保留 DCLX 專項 Blocker，隔離重現與局部處置；**不阻擋 PDF → DoclingDocument → Retrieval** |
| self_ref 插入節點後位移 | 本切片引用至少綁 source SHA、版本和有效 selector；跨版本無法確認時 fail closed，不能宣稱已全面完成 remap |
| Core 候選新版 Schema 高於既有 Reader，舊 Reader 拒絕 | **本輪不做產品升版**；使用已核實可用的 BASELINE Profile。把新寫舊讀失敗列為未來正式升級的硬 Gate |
| DOCX 巢狀表格手動構造 DoclingDocument 可重載 | 這不代表 Docling 自動 Parser 能抽取；不得把人工手動構造結果當成格式匯入已通過 |
| 檢索、人工 Corpus 與 DB/Index 恢復仍未完整完成 | 保留正式 M8/M10 Gate；M2-V0 用**隔離、非正式的 local retrieval**證明最小功能，不冒稱正式 RAG 等效 |

**原則：問題必須轉成修復實作、最小可驗證 workaround、明確不支援的來源類型，或下一個有界 WorkItem。** 不得讓一個已知 Office／DCLX 缺口阻止 PDF Shadow 切片，也不得為趕進度而讓錯誤資料通過。

## 2. 交付範圍與成功定義

### 2.1 M2-V0 必須交出這條可運行流程

    Local test source (prefer a PDF with headings, paragraphs and a table)
                         |
               Official Docling parser / reader
                         |
                 DoclingDocument (no DS)
                         |
             JSON + assets + versioned manifest
                         |
              Reload in a fresh process
                         |
              Zero-revision read-only view
                         |
         Chunk text + section + source selectors
                         |
              Isolated local retrieval
                         |
        Query → matched chunk → verifiable citation

**最低交付**：一份由**實際解析器處理**而非手動拼裝 DoclingDocument 的本地來源文件，具有標題、段落、表格與可核對的來源定位。優先選 PDF；若現有已核實的解析環境缺少 PDF 解析入口，允許在不碰正式依賴的條件下使用可直接解析且帶來源定位的替代格式，並在報告中列出 PDF 尚缺的確切障礙。

建議第二個簡單來源（MD／TXT）作延伸。若解析器當版缺依賴，先檢查官方 Extras 並在隔離 venv 驗證，不得升級主環境。

### 2.2 範圍內與範圍外

**本輪範圍內**：最小 Docling integration 層、Converter/Reader 的穩定入口、DoclingDocument JSON 保存重載、來源證據 selector、既有 Chunk Policy 的薄適配、本地 deterministic retrieval、測試與獨立 Shadow Runner。

**範圍外**：完整 Office Evidence Store、DCLX Windows Writer 修復、DocLang 0.9 Viewer 正式升級、正式 Review／Effective 寫入、全量 stable anchor remap、Embedding Model 更新、Vector DB、正式 Index、公開服務路由、既有 DS 刪除與資料遷移。

本輪可為已知 DCLX description 或 bbox 問題留下一個**獨立局部驗證案例**，但不得讓它延誤 M2-V0 主要切片，亦不得改產品原有 Adapter。

## 3. 開工前置檢查

本工作包的前置 Gate 限於：

1. **R0 已驗證**本地 Repo HEAD、工作樹、相關環境與 Golden Fixture SHA；已知 1 項 PPTX 紅燈及無快取公式缺口仍有完整記錄。
2. 選定來源格式與 Parser 能在**已核實的既有版本 Profile**實際讀取。使用哪個 Core/DocLang 組合必須從現有環境重新確認；不能混裝 MAIN 與 PARSER。
3. 隔離輸出位址與命令清楚，不能碰正式資料與 Index。
4. 針對該來源與其必要欄位至少有可人工核對的 Truth Source（標題、段落、表格值與定位）。
5. 不需要等待所有 R1/R2/R3 格式問題清零、不需要等待完整 60 份真實 Corpus，也不需要正式 DB/Index 復原完成。

若這五項任何一項失敗：就地做最小修復或選擇另一個已支持格式的 fixture；仍無法做到時記錄**唯一下一步阻擋**及所需變更，停止本 WorkItem，不能無限延長分類研究。

## 4. 實作規則與最小介面

1. 只可新增隔離入口與最小整合模組；不可修改正式 KA 主程式的 Parser、Review、DB、Index、服務路由、發布設定或正式依賴 lock。
2. DoclingDocument 與其原生節點是切片唯一共用內容模型，不得建立新 PageContent、Block、TableCell 等完整副本，不能由 Docling 先轉 DS 再送 Chunk。
3. 小型 integration 專門承接：來源解析、模型保存重載、assets/reference、能力探測、格式專屬錯誤。名稱與 API 必須由現有 Core 實際 signature 決定，不可把設計用的函式名稱誤當已存在官方 API。
4. Chunk 層沿用目前的 text/table/section/reading-order/token policy，優先透過小型輸入適配重用**算法**，而不是複製一份既有 Chunk Planner。若原 Planner 強制依賴 DS，僅為切片新增最小純函式策略抽取，**不在同批替換正式 Planner**。
5. 所有來源引用保存文件 ID、source SHA、版本、原生定位。無法確證映射時拒絕輸出正向引用，禁止自行猜測原始頁面、儲存格或表格。
6. local retrieval 可採簡單可重現的 lexical/BM25 或其他離線檢索；每筆結果要帶 matched text、chunk selector、原始證據位置，**不需要 LLM 生成答案**，也不可宣稱已完成 embedding-based RAG。
7. 保留舊 DS 產品路徑完全原狀。任何 shadow 入口預設停用、不對外發布，不自動寫入正式 DB、Index 或權限系統。
8. 版號與 Manifest 的 docling-core schema、package version、原始檔 SHA、Parser Recipe、Asset Digests 必須分別保存；schema 版本不等於套件版本。
9. 不得在本 WorkItem 混入候選 Core 2.106.0 的正式升級；上游 Upgrade Gate 對應 U3/U4 另行批次執行。

## 5. 可重跑測試矩陣

Coding Agent 應在既有 tests/scripts 結構建立獨立 Runner，例如 scripts/ka_dmm_m2_smoke.py。這是**建議的新檔名**，不代表現已存在。要求一條命令能重跑下表所列的全部 M2-V0 測試。

| Test ID | 驗證內容 | Gate |
|---|---|---|
| T01 | 實際 Parser 解析固定來源；出現標題／段落／表格及 provenance | 必須有原始 fixture 與 Truth |
| T02 | DoclingDocument JSON、Assets、Manifest 寫入後，在新 Python process 正確重載 | 必須 PASS |
| T03 | 重載後必要內容、table spans、讀取順序與定位一致 | 不可靜默遺失 |
| T04 | 既有 Chunk Policy 的原生輸入適配，產生具來源 selector 的 Chunk | 不可經 DS |
| T05 | 至少 5 個檢索用例：標題、段落、表格數值、跨節上下文、無證據拒答 | 預期證據人工核對，錯引 0 |
| T06 | 壞 JSON、缺資產、缺 Provenance、Schema 不相容 | Fail closed，不生成假 Evidence |
| T07 | 靜態／執行期 import trace 證明本 Runner 不依賴 DS model、Reader/Writer、Adapter | 正式 DS 依賴 = 0 |
| T08 | 原產品基準重跑；已知 PPTX 失敗保留，無新增退化 | 不改既有 Goldens |
| T09 | 刪除／停用 Shadow 產物後，原產品仍可正常運作 | 可回退 |
| T10 | 版本、Fixture SHA、輸出 SHA、命令與性能摘要可重現 | 記錄完整 |

為避免只測表面流程，T05 的每個 Query 必須有**預期答案所在原始來源**，並驗證返回來源，而不只驗證搜尋結果非空。至少一筆明確不存在的問題不得回傳偽造引用。

對跨版本 self_ref／XPath 的完整 Remap，本輪可標尚未支援；但本切片若涉及跨版引用，必須版本綁定且不能錯引。bbox 若轉換座標系，測試應驗證換算後定位而不是字面數字相同。

## 6. 具體交付物及驗收 Gate

在**本地** Knowledge Agent Repo 交付：

    docs/migrations/ka-dmm/M2-V0/
      README.md
      scope_and_capability.md
      environment_and_lock.md
      execution_evidence.md
      json_roundtrip_diff.json
      chunk_and_source_evidence.json
      retrieval_cases.json
      failure_injection.json
      unsupported_features.md
      regression_and_rollback.md
      M2_V0_gate_report.md

並提交真正執行的 Shadow 程式、獨立測試、Fixture、可重跑命令及 Commit，不能只新增報告。

### M2-V0 PASS 必要條件

- 上述 T01 至 T10 所屬**本切片承諾支援的功能**全數完成；不得以跳過測試計為通過。
- 原始文件到 DoclingDocument、保存重載、Chunk、local Retrieval、citation 的每一段都有真實產物。
- 本切片**沒有 DS 依賴**、沒有自訂第二套通用文件樹、沒有新增正式業務副作用。
- 至少 5 筆 Truth Query 具來源證據；**錯誤正向引用為 0**；不支援的內容清楚標示。
- 注入缺失資產、錯 Schema、來源失效時 fail closed。
- 舊正式服務、原資料與既有測試無新增回歸；維持可回退。
- 完整交付 Commit、環境、log、Fixture SHA、Diff 與負責人／阻擋清單。

### M2-V0 BLOCKED 的處理

只允許把本切片**真正依賴**的關鍵失效列為本 WorkItem Blocker；不相關的 XLSX、PPTX、DCLX Viewer、DocLang 0.9、60 份 Corpus、完整 Shadow RAG、正式 DB/Index 恢復仍列於**整體遷移 Backlog**，不得因此反覆撤銷 M2-V0 的局部成果。

若有阻擋，列：失敗點、可重跑測試、已試最小方案、下一個**當輪可完成的小修復**、會否影響原正式產品、Owner；不要求在未經授權下擴大範圍。

### Gate 分離原則

- **R0 / P0-R1 / P0-R2 / P0-R3**：沿用前輪已完成的報告與結果。整體架構 Gate 可以繼續 BLOCKED。
- **M2-V0**：這個最小隔離切片可以獨立 PASS。
- **正式 M2 / M3 / M8 / M10**：仍未批准，必須有獨立工作指引和上線前驗收。

## 7. 下一階段可用能力路線圖（規劃，不授權）

完成 M2-V0 後，下一輪應按「替代能力」而非「再盤點」順序決策：

1. M2-V1：DCLX → DoclingDocument 的完整原生 Reader/Description/Bbox/Assets，處理 Windows URI 的局部兼容。
2. M2-V2：原生 Excel/PPT 精確 Evidence Extension，使用原始 Office Truth，改善既有 DS 的公式／圖表缺口。
3. M2-V3：可採用的 Versioned Evidence + Stable Logical Anchor Remap，明確拒絕錯誤確證。
4. M2-V4：Docling Native Review / Effective、Chunk 與 Viewer 的受控整合。
5. M8：Shadow Index/RAG/性能與恢復；M10：Canary、DS 清除、正式切換。

上述順序可由已驗收證據調整，但**本輪沒有授權 Coding Agent 自行開始其中任何一批**。

## 8. Coding Agent 最終回報格式與停止點

每次回報必須清楚區分「已實作、已測試、僅規劃、尚未支援」：

    WorkItem：KA-DMM M2-V0
    指引 URL / Version / GitHub Commit：
    KA Repository / Branch / Commit：
    執行環境 / Core / DocLang / Schema / Lock：
    新增或修改的檔案：
    獨立 Runner 與重跑命令：
    實際可用的端到端路徑：
    支援的來源類型及實測 Fixture：
    Unit / Integration / Negative Test Passed-Failed-Skipped：
    Golden Query 及 Citation 正確／錯誤數：
    JSON / Asset / Manifest 再載入證據：
    無 DS 依賴的證據：
    舊流程 Regression 與已知紅燈：
    回退測試：
    未完成的功能／來源類型與對應下一步：
    是否碰正式 DB / Index / Secrets / Network / Service：
    M2-V0 Gate：PASS / BLOCKED / FAIL
    整體 KA-DMM Gate：維持既有審查狀態
    需要使用者核准的下一批：

**工作終點**：交付可運行切片與真實測試報告，然後停止。不可自行進 M2-V1、更新正式依賴／服務、啟用任何正式寫入或清除 DS。下一輪必須由 ChatGPT 將完整可執行指引推送至公開 GitHub，再由使用者／Coding Agent 明確開始。

**判斷標準**：每一輪至少增加一段經過測試、真正可以替代 DS 的原生處理能力。研究和測試用來控制風險，不能代替交付；已知舊系統缺陷應在對應新切片修正，而不是成為整個專案永久停滯的理由。

# KA-DMM：自主完成 Docling 原生遷移及 DS 淘汰總任務

> **版本：v2.0**
> **狀態同步增補（2026-11-07）**：本任務新增強制公開去敏狀態回報，唯一同步檔案為 [KA_DMM_STATUS_SYNC.md](../KA_DMM_STATUS_SYNC.md)。本增補不改變 E0 至 E9 自主授權。  
> **日期：2026-11-07**  
> **任務狀態：待 Coding Agent 自主執行的完整工程規格，非已完成宣告**  
> **指定執行者：Coding Agent（Main）與其可使用的 Sub Agents**  
> **公開指令 Repository：caseykcc0124/codex_coding**  
> **實作位置：使用者既有的 Knowledge Agent Repository，禁止另開新產品 Repository**  
> **參考主計畫：[KA-DMM v1.2](./KA_DMM_Docling_Native_Migration_Plan_v1.2.md)**  
> **前批次：[M2-V0 v1.3](./KA_DMM_M2_V0_Delivery_Execution_Guide_v1.3.md)、[M2-V1 v1.4](./KA_DMM_M2_V1_DCLX_Native_Import_Execution_Guide_v1.4.md)**  
> **優先權：本文件取代先前「每完成一小批就停止、必須等待下一份指令」的授權限制。此前所有資料安全、回退與證據可信度要求仍有效。與舊版 Gate / 停止條件牴觸時，以本文件第 1、2、9、10 節的自主工作權限和正式環境邊界為準。**

## 0. 任務宣言：一次完成最終目標，不再由使用者充當信差

**本次授權的是整個 KA-DMM 完整工程，不是下一個小型調查工作包。**

Coding Agent 必須在原有 Knowledge Agent 專案中，自主完成：

1. 以官方 DoclingDocument 為唯一通用文件內容母本，逐步且最終移除正式流程對自訂 DocumentStructure（DS）的依賴。
2. 讓所有**目前 KA 已實際接受、且產品確實需要支援**的輸入來源，經過不依賴 DS 的 Docling Native 路徑，保留完整且正確的來源證據。
3. 遷移保存、版本、Review、Draft、Revision、Effective、Approval、Chunking、索引、Retrieval、Groundedness、Viewer、DocLang/DCLX 輸入輸出與必要編輯回寫。
4. 保留並改善 Excel、PowerPoint 的原生精確證據，實際修補現有 DS 已知的公式／圖表資訊缺失。
5. 建立官方 Docling Release 可持續升級的鬆耦合整合邊界、跨版本回歸與回退機制。
6. 交付可實際運行、可從乾淨環境重現、具整合測試與資料遷移程序的完成版本，最後清除正式 DS 程式依賴。

**Main 不得將每個小 Gate、已知缺口或技術選型重新送回使用者等待批准。** Sub Agent 可平行處理，但由 Main 負責整合、解衝突、補測試、合併有證據的成果與推進工作。只有第 10 節規定的真正外部授權點，才需向使用者要求決策。

**完成主張必須建立在程式及測試實證。** 如果礙於無法取得正式資料、權限、網路／套件來源或安全環境而未能執行生產切換，要交付完整可部署版本與可重跑部署包，明確標示「工程完成，正式環境切換待授權」。不能把尚未執行的測試報成 PASS，也不能因一個外部依賴就停止其他工程。

## 1. 既有證據與可直接繼承的起點

Main 啟動後須先讀取本地 KA 的 docs/migrations/ka-dmm/README.md、P0／P0-U／M0／M1、P0-R、M2-V0 報告、Git HEAD、當前 working tree、實際依賴 lock。下述數字為使用者提供的前批回報，不代表本次重新測得；只對內容有實質差異的項目重驗，不准因新任務而全數重做。

| 項目 | 已回報成果 | 本任務的處理 |
|---|---|---|
| M2-V0 | 驗收與獨立審查 PASS，PDF → DoclingDocument → JSON＋圖片 → fresh-process load → Chunk → local retrieval／citation | **保留現有實作並擴展，不重寫一個平行 Pipeline** |
| M2-V0 程式 | 本地 Commits 2a740b3、b44f8f6；Runner scripts/ka_dmm_m2_smoke.py | 使用本地實際存在的 Commit；不可假設已公開 push |
| M2-V0 測試 | T01～T10 PASS，8 項 integration，5 positive＋1 negative，6 種失敗注入，錯引 0 | 作為新任務不可退化的 Golden Baseline |
| 文件模型 | Core 2.101.1、DocLang 0.7.3、slim 2.137.0，Schema 1.10.0 用於 V0 | 保留可用 Baseline；正式版本升級做獨立兼容性決策 |
| R0 | 既有 50 項中 49 PASS、1 項 PPTX projection digest FAIL | 記錄 Known Baseline Failure；不得改 assertion 製造全綠 |
| P0-R R1 | 170 欄已裁決，NATIVE 5、KA_NATIVE_EVIDENCE 81、KA_GOVERNANCE 46、DERIVED 9、BLOCKED 29 | 用這張表驅動**能力實作與測試**，不再反覆純分類 |
| 巢狀 DOCX | 由 python-docx 讀 Truth、手動構造 DoclingDocument 可保存重載 | **尚未證明自動 Parser**；需做真正來源抽取或局部補強 |
| DCLX | Windows Writer URI 缺陷；有情境能在 picture.meta.description.text 保留描述 | 修匯入邊界與 Adapter 消費，不因 annotations 為空判全部遺失 |
| bbox / Anchor | bbox normalization 未必是 loss；self_ref 重排會改位址 | 用相同座標系比較；版本綁定 Evidence 與 remap |
| 官方候選版 | Core 2.106.0 / DocLang 0.9.0 的 JSON Schema 1.11.0 已被 1.10.0 Reader 拒絕 | **新寫舊讀不能假裝相容**；先有完整資料降版／回退策略才升版 |
| 專案現況 | 正式服務、正式 DB／Index、正式依賴未改；DS 仍為正式路徑 | 新路徑先 Shadow、再 staging；正式切換按第 10 節授權邊界 |

本次起點不需要重新證明「DS 是否值得被替換」。**此架構決定已成立**，只在取得具體無法承接必要產品語意且無可行最小 Extension 的反證時，才重新提 ADR。

## 2. 完成狀態與自主執行契約

### 2.1 狀態不是每輪停止指令

每個內部工作包可以標 PASS／FAIL／BLOCKED／NOT_TESTED，但它**不應自動中斷其他無依賴的工作**。Main 必須根據依賴圖持續調度：

- PASS：有真實程式、測試、可重跑證據，可提供下一階段使用。
- FAIL：當批程式或測試失敗，優先診斷與修復，不傳回使用者只問「怎麼辦」。
- BLOCKED_LOCAL：當批某來源／版本不可用，找官方方案或最小 workaround，必要時暫用明確不支援狀態；繼續其他批次。
- BLOCKED_EXTERNAL：需正式憑證、授權套件、未取得的真實資料或不具可用正式環境，產出可交付替代測試及明確所需輸入，繼續不依賴該外部條件的工程。
- READY_FOR_RELEASE：功能與可取得的所有測試完成，待正式環境操作授權。
- COMPLETE：正式目標已實際在核准環境切換、驗證，且正式路徑不依賴 DS；若未執行正式上線不得使用此狀態描述 production。

### 2.2 失敗的自治處置順序

每個障礙至少按照以下順序推進，**不要讓單一阻擋變成無限研究**：

1. 重現，縮成最小 failing fixture，分辨上游、KA Adapter、來源資料缺失、版本／環境問題。
2. 查核當版官方公開 API、Extras、Serializer、Chunker、Model 的可用方法，避免私有實作重造。
3. 在同 Repo 的單一整合邊界做**最小、限定版本、可開關、可撤除**的兼容實作，附正反測試。
4. 若官方能力仍不足，透過原始來源的**專用 Extractor**補充 KA Native Evidence Sidecar；不創建另一套泛用文件樹。
5. 若整個來源格式仍失敗，既有正式 DS 路徑暫可用；新路徑明確返回 UNSUPPORTED／PARTIAL_UNVERIFIED，並繼續開發其他格式和後續組件。
6. 將上游 defect 整理成公開 Issue 草稿，但不自動送出、不把公司樣本公開。候選官方版本只能在隔離環境測試。
7. 到可交付節點時回報剩餘風險及解法。除非涉及第 10 節的不可逆操作，不得因普通缺口逐批等待使用者決定。

**不允許把錯誤引用改為 Warning 以取得 PASS**。會錯誤確證來源、資料毀損、不能恢復修訂事件、越權訪問或污染正式 Index 的問題必須 fail closed，並停止該危險路徑，其他可獨立工作仍繼續。

### 2.3 Main／Sub 協作與提交治理

Main 持有唯一工作進度與依賴圖。可平行委派 DCLX、Office Evidence、Review、RAG／Index、Viewer、相容性 CI 的獨立工作項，但避免同時修改同一核心 Schema 或同一主幹檔案。

每個 Sub 提交：實際 diff／Commit、實測命令與結果、哪些是規劃、未解風險、必要依賴。Main 自己做整合測試、負責糾正互相衝突的實作，不要求 Sub 額外撰寫沒有實質作用的理由報告。每個改動需可 review、可 revert，對局部功能做小型 Commit，但**不因單個 Commit 完成就停止整輪任務**。

不存在人工核准就不必連續發多次「需確認」；應直接推進到最終 Engineering Definition of Done。

## 3. 不得偏離的最終資料與模組架構

    PDF / DOCX / PPTX / XLSX / HTML / MD / TXT
    DCLX / 外部 MD ZIP / MCP 準備文件
                      |
          Version-aware Source Ingestion
                      |
          Official Docling parser / reader
           + optional source-specific evidence extractor
                      |
                DoclingDocument
                 (唯一共用內容)
                 /              \
       Canonical JSON        Native Evidence
           + Assets          + Provenance
                 \              /
             KA Versioned Bundle
                      |
            Review / Draft / Revision
                Adoption Policy
                 Effective View
                      |
         Chunk Planner + Evidence Lineage
                      |
          Index / Retrieval / Groundedness
                      |
                Agent / Viewer
                      |
        DocLang / DCLX export (projection)

Docling Integration Boundary 只需要集中 Parser／Reader／Serializer／API 兼容、原生遍歷和能力探測；不可製造新的 PageContent、ContentBlock、TableCell、Picture、Generic Relation 樹，亦不得把 DS 換名成 DoclingAdapterModel 就算完成。

最終保存（可依原 Repo 既有部署形態調整，但語意不變）：

    prepared_bundle/
      manifest.json
      source/<original>
      canonical/docling_document.json
      assets/<digest-based assets>
      extensions/native_evidence.json
      governance/<versioned revision events>
      projections/<derived, regenerable output>

任何原始 DCLX、Office 原檔、未知 XML、必要 page images 均需保留。Manifest 各自記錄 source SHA、parser recipe、原始格式、docling/docling-core/doclang 版本、DoclingDocument Schema 版本、KA Extension Schema 版本、asset digest、document/effective revision、index recipe；**Python 套件版本不等於資料 Schema 版本**。

持久化操作須原子提交、Manifest 和資產完整性驗證、重試冪等、失敗不留下被誤認為有效的部分文件。原始資料不可因生成 DocLang／Markdown 等投影就被覆寫。

### 3.1 Anchor 與來源證據的最低契約

保留至少三種獨立身份：

- Source Identity：document id + source SHA + source version + parser recipe。
- Evidence Identity：從實際來源項目／Office cell、slide 或原始定位與內容摘要導出、綁定具體版本的 immutable Evidence ID。
- Logical Anchor：支援文檔版次、Parser 變動時的候選 remap；含結構脈絡、來源 selector、內容 fingerprint 與適當的 confidence／人工確認。

Docling self_ref／DocLang XPath 是**在指定版本內有意義的 locator**，不是跨重解析後保證不變的全域 ID。Remap ambiguous、目標被刪、無來源或 confidence 不足時進入 unresolved，不得指向看似相似的另一段作為 Verified Evidence。

### 3.2 與上游 Docling 的耦合政策

- 官方 DoclingDocument 原生型別與穩定 API 可以使用；只隔離可變的 Reader／Writer／Loader／Options／private API，不為了零 import 重建 DS。
- 專用 Office Evidence Extractor 只處理原生格式補充證據，不能另建整份共用文件的平行內容模型。
- 先固定已通過的 Baseline Profile。要採用新 Docling Release，先候選 venv/container、Schema 相容性、DocLang/Viewer、資料回退、完整 Regression、Shadow RAG；不能直接正式 pip upgrade。
- 官方功能升級優先能只修改 Integration Boundary、版本鎖與 fixtures。需要修改大範圍 KA 業務模組，代表邊界尚未收斂，應優先調整架構。
- 對已過時的 compat workaround 保留 Owner、版本適用範圍、啟用條件、解除條件與刪除測試。

## 4. 一次授權的完整工程任務與實作順序

以下是**內部實作批次及整合檢查點**，全部已在本文件授權，不能每完成一階段就停下來等 ChatGPT 出新指令。允許平行處理，但遵守資料契約／依賴順序。

| 階段 | 必須交付的真正功能 | 依賴 | 階段 Gate |
|---|---|---|---|
| E0 | 凍結現況、可重跑基準、工作樹／資料備份、權限與相容 Profile | 已有 P0/M2-V0 | 既有 V0 測試不退化 |
| E1 | DCLX 原生 Import，Windows URI 局部修復，Picture/Caption/Description/Provenance，原始 XML 保留 | V0 JSON/Assets | DCLX → local retrieval/citation PASS |
| E2 | 全來源 Native Ingestion：PDF、DOCX、PPTX、XLSX、HTML、MD、TXT、外部 MD ZIP、MCP 結果 | E1 的 Boundary 可複用 | 每類必要來源可處理、缺口明示、無 DS |
| E3 | Office Native Evidence、stable anchor、跨版重載／remap | E2 | Excel/PPT 精確證據、Anchor 0 錯引 |
| E4 | Prepared Bundle 保存、Reader、歷史資料 Migration、雙寫與完整性 | E2/E3 | 真實可恢復的 Shadow Bundle、歷史可讀 |
| E5 | Review、Draft、Adoption、Effective、Conflict Detection 由 Docling Native 驅動 | E3/E4 | 治理語意與版本可重播、可回退 |
| E6 | Chunk Planner、Index Producer、Retrieval、Groundedness 原生資料契約 | E3/E5 | 全部 RAG 測試及來源可信度達標 |
| E7 | Original/Effective Viewer、DocLang/DCLX Projection 與編輯回寫 | E5/E6 | Viewer／Revision／Effective 一致 |
| E8 | Docling Upgrade Compatibility CI、Shadow Index、版本與效能回歸、自動 Upgrade PR 能力 | E1～E7 | 可實測官方候選版升級與回退 |
| E9 | Staging 全路徑切換、歷史遷移工具、DS 正式依賴清理、遷移交付包 | E0～E8 | Release Candidate 完整驗收 |
| E10 | 經核准的 Production Canary、正式索引 Alias／寫入切換、觀測與最後 DS 淘汰 | E9＋第 10 節授權 | 真正生產環境 PASS 才能宣稱 COMPLETE |

### E0：不可退化的工作基線

- 讀取本地 P0/M0/M1、P0-R 與 M2-V0 的完整證據，辨識既有 Commit/Golden Corpus 與 dirty tree。備份現有資料和配置（限授權本地環境）。
- 以目前可用的 12 synthetic + MCP sample、M2-V0 PDF fixture 啟動；補充更多**有來源 Truth** 的實際測試。缺少 60 份真實代表文件不阻止寫完產品，但會限制正式生產品質驗收。
- 重跑 M2-V0 T01～T10、原 50 項；保留一項既有 PPTX digest Failure，不更新 Golden。任何後續版本的既有 PASS 不可無理由回歸。
- 保存帶版本的 manifest、source hash、test logs 與環境 lock。不要擅自清除使用者未提交的程式。

### E1：DCLX 直接落地，不再新增 P0-R 問卷

交付至少一個可用 DCLX 真實匯入流程，重用 V0 的 JSON、Asset、Chunk、Retrieval。使用不同來源方式的 DCLX fixtures 驗證，避免同一 Writer/Reader 互相掩蓋錯誤。

- Windows 反斜線圖片 URI：先試公開 Reader 設定，否則僅在版號限定、可停用的 DCLX Source Compatibility 中對封裝內安全相對 URI 正規化。原始 DCLX 不改，保存修正前後 mapping。禁止外部網路、任意磁碟存取、ZIP traversal。
- picture.meta.description.text、caption、annotations、bbox、assets 以各自原生語意驗證，不因 annotations 空白就判所有描述消失。bbox 以座標系轉換後等效比較。
- Unknown XML 保存原件，標明 PARSED_AND_VERIFIED／PRESERVED_UNPARSED／REJECTED_UNSAFE／UNSUPPORTED_VERSION，重大未解析內容不能被納入 Verified Evidence。
- 經 fresh-process JSON load、至少五筆正向及一筆拒答查詢證明來源可回溯，不用 DS。
- 上游缺陷可產出無敏感資料的 Issue 草稿，**不自動公開發布**。若特定 DCLX 子格式仍不可用，先限制版本／來源，照常推進 E2。

### E2：所有輸入改走統一的原生資料路徑

實際搜尋現有 Repository 的 Importer／Adapter／MCP 接口與業務消費者，逐來源切換**新 Shadow**，不能以理論 Format Support 替代測試：

- PDF：文字 PDF、掃描 PDF（受授權 OCR Pipeline）、跨頁表格、圖片、頁／bbox。
- DOCX：標題、列表、表格、巢狀表格、Caption、圖片及來源關聯。前輪手動構造 DoclingDocument 成功不能當 Parser 自動抽取；若官方 Parser 無法承接，用**DOCX 專用 Extractor**補來源 Evidence／必要節點映射，不能另造整篇文件樹。
- PPTX：Slide、Shape、Text、Chart、Series、Embedded Workbook、圖片關係。
- XLSX：Sheet／Cell／Range、Formula（有和沒有 Cached Value）、Named Range、Merged Cells、表格與來源 Selector。
- HTML／MD／TXT：標題、行內連結、列表、表格與來源資訊；對缺 marko 的 Parser Profile 以官方相容依賴補齊隔離環境。
- DCLX／DocLang：本批 E1 的來源路徑，進入共用 DoclingDocument。
- 外部 MD ZIP／MCP：維持既有外部流程不變，只修改本地入口 Adapter，使其**直接產生 DoclingDocument 而不先產生 DS**；保留外部輸入原件、SHA、解析策略與來源追溯。

Format-specific Evidence 若無上游原生承接，應建立有限的旁掛資料。不要把不同來源的 page_number 強行視為同一物理語意。每個來源的**真正驗收**是至少一條可重跑「Import → JSON → Reload → Chunk → Retrieval → Citation」加上負案例，而非只有 convert 成功。

### E3：補足精確證據與 Anchor Remap

把之前 R1 的 170 欄、A1/B53/C93/D0/E23 和 R1 新裁決變成追蹤**產品責任覆蓋**的矩陣。每個欄位只需歸屬原生 Docling／KA Office Evidence／KA Governance／Derived／真正廢棄五類，並有受影響的 consumer、測試與移除依賴的 Commit；不能用文件清冊代替實作。

**Excel 的真值必須以原始 workbook 為準**。對沒有 Cached Value 的 Formula，保留公式本身及「尚無計算結果」狀態，禁止替換成 0、空白或已確證值。Named Range、Merged Cells 與 Sheet／Cell 引用都要能回溯。

**PPT 的真值來自實際 Shape／Chart Series／Embedded Workbook**，不能退化成只有圖片與 AI 描述；至少測 category/value、series mapping、slide／shape id、source resource relationship。

Anchor 應支援以下情境：前方插入節點、重複文字、同形表格、Caption 改動、重新解析、跨版內容修改、目標刪除、複數候選、同文件多修訂。對確證來源錯誤零容忍，不能讓 heuristic remap 虛構證據；不確定就 UNRESOLVED，Review 需要人審時只阻擋該筆引用，不停止無關文件與批次。

### E4：持久化、歷史資料與雙寫切換基礎

- 將新的 Prepared Bundle 實際寫入 Shadow Storage，包含 Docling JSON、原始檔、資產、Evidence Sidecar、Manifest、版本標記與 integrity 校驗。
- 既有 DS canonical.json 和 manifest 可能承載大量歷史修訂／block id／lineage。先寫**一次性的歷史 Migration Reader／Migrator**，可讀舊資料並生成新的 Native Bundle 和映射報告；此工具可以讀 DS，但不得成為新正式業務的中介模型。
- 舊資料經新格式保存重載，驗證所有原有 Review、Version、Evidence、Chunk 與延遲遷移資料；即使不重解析也要有舊版 → 新版對應方式。含損壞資料、重複執行、半途中斷、版本衝突、同名文件與不完整 Assets。
- 設計雙寫但一開始 DS 仍是正式主資料源，新 Bundle 影子保存。所有寫入使用原子發布、SHA／Manifest 驗證；測試失敗不污染正式資料。
- 準備升級時如需新 Schema，做獨立 migrator。不可在普通讀取時偷偷全庫升版，亦不可假設「新 Reader 可讀舊 Schema」意味降版安全。
- 產生可重複跑的 migration dry-run、差異與 rollback scripts。正式資料 migration 必須遵守第 10 節。

### E5：Review、修訂及 Effective Document 真正改為原生

將 Review、Draft、Approved Revisions、AI Supplement、Policy、Effective Snapshot 的資料擁有權從 DS 移到 DoclingDocument + KA Governance。優先保留現有產品 API/UI 行為，但內部內容與 selectors 不再依賴 DS。

必測：

1. 原始文件 immutable；使用者修訂只能進 Draft，採用後有新的有效版本；拒絕與回退不污染原檔。
2. 人工修訂與 AI 補充 provenance 不混用；未審核 AI 描述不得被算作原始事實或 Grounded Evidence。
3. Expected Revision 與競爭更新，確保 stale revision、衝突編輯被阻擋；不覆蓋他人已採用內容。
4. Effective Snapshot 在獨立 process 可重建，內容、Order、Table、Anchors、來源版本與採用政策一致。
5. Viewer 的編輯回寫必須經相同 Draft／Review／Approval 流程，不得繞過治理。
6. 歷史 Review／Revision 可轉新 Contract；若仍有不可安全重播的事件，該文件標明待處理且保持舊讀取，不能假造過去的審核決策。

若為了相容必須調整 API Contract，先以 adapter／versioned endpoint 將變動隔離，測試所有已知 UI consumers，再由 Main 自主修正及整合，不因一般 DTO 變更回來問使用者。

### E6：正式 Chunk、Index、Retrieval、Groundedness

- 既有 Chunk Policy 與 Tokenizer／Embedding／Reranker 設定先固定。不要在替換 DS 的同一階段隨意改演算法；無必要則沿用 M2-V0 已測的 1500 字元與重疊 100、表格分列並重複表頭策略，實際配置以 Repo 現行規則為準。
- 正式 Chunk Planner 直接吃 DoclingDocument + Effective View + Evidence Sidecar；生成 Chunk、Context、Source Selector、Revision、Payload。要求移除 DS 中介，禁止先輸出 Markdown 造成表格 Span／證據降級再當 Canonical。
- Chunk 可用原生 Docling BaseChunker／HybridChunker 作探索，但若採用需在**另一個算法變更對照測試**中證明品質及來源等效，不能直接替換已驗收策略。缺 tree_sitter 的問題先以隔離 Extras 補足再選型。
- 新 Index 與正式 Index 物理隔離，先 Shadow Index，不覆蓋既有 Index。固定相同 Embedding Model、Tokenizer、Reranker、Query、Threshold；驗證 P@k／Recall@10／nDCG@10／Groundedness／引用完整率與成本／延遲。
- 來源精確性比文字相似度重要：錯誤正向來源引用 0、關鍵 Excel/PPT 值與公式的錯誤確證 0、未審核 AI Supplement 不能混入原始 Evidence。
- 對舊 DS 已存在的來源缺漏，用人工確認的原檔 Truth Source 判定新路徑是否改善，不准用錯誤舊輸出迫使新路徑重現舊 bug。
- 無證據情況要拒答或標不確定；多文件矛盾須顯示各自來源版本，不能硬合成單一確證。

### E7：Original / Effective Viewer 與 DocLang/DCLX

- Original Viewer 仍能展示來源 DCLX 或原始文件與資產；Effective Viewer 從已審核的 DoclingDocument Effective View 生成可檢視／交換的投影。
- DocLang／DCLX 作 Exchange／Projection，**不作唯一的無損母本**。不能把有效投影冒稱原始無損封裝，未知 XML 與原始 DCLX 另行保留。
- PDF／Office 的 Table spans、Picture description／caption、bbox、source locator、page images 應可見、可定位、可核對；DocLang 丟失未支援 Metadata 時標明投影差異，不靜默丟失後又覆蓋母本。
- Viewer 编辑／DCLX 回寫設計以新的 Edit Event 或 Draft 操作進 Governance，通過 Approval 才進 Effective，不得另開新 Document 或直接回寫已審核 Source。
- 針對既有 Viewer 對 DocLang 0.7/0.8 的支持以及候選 0.9，建立格式相容矩陣與明確功能降級。必要時先保留已驗證的格式版本；不要因升上游套件直接破壞 Viewer。
- 完整 UI 流程以可重跑整合或 Playwright 測試檢查，包含檢視、定位、編輯、儲存草稿、批准、重新打開、版本衝突、錯來源引用。

### E8：官方升版相容、CI 與維運自動化

在既有 KA Repo 設置官方 Docling／docling-core／DocLang 的版本與 API 相容測試，不新增獨立產品。流程：

    Official Release / Package Update
                |
       Candidate isolated lock
                |
        API / Schema / DCLX Diff
                |
       Golden Corpus / Office Evidence
                |
       Review / Effective / Chunk / Viewer
                |
        Shadow Retrieval / Groundedness
                |
       Failure Injection / Rollback
                |
        Upgrade PR / Review Report

- 至少一組已通過的 Baseline 與一組官方正式 Candidate 測試；要展示舊 JSON 新 Reader 及新 JSON 舊 Reader 的結果，不得把 Schema 1.11.0 直接交給舊 1.10.0 Reader。
- 依賴全部有可重現 lock、Python/OS、Extras、Wheel Hash（若可得），安裝與使用時的網路、外部服務和模型下載都遵守權限。
- 靜態檢查 Docling private API、跨層直接依賴與重建 DS 2.0 的模式，避免升版讓 KA 內部所有層一起修改。
- 可設置既有 GitHub Actions／依賴管理工具的 Upstream Watch 或 Upgrade PR 自動產生，但不自動合併、部署、升級正式相依、重建正式 Index。
- 完成至少一次官方候選版的「升級隔離驗證 → 發現不相容 → 回退」演練；不強迫正式環境採用候選版作為遷移完成條件。

### E9：Stage Full E2E、歷史遷移與 DS Cleanup

這階段須交付一個從**真實支援來源 → DoclingDocument → 版本保存 → Review → Effective → Chunk → Shadow Index → Retrieval/Groundedness → Viewer** 的可運行環境，涵蓋錯誤處理與回退。

對所有已知產品入口進行靜態依賴掃描、執行期 smoke 與 API consumer 驗證。最後刪除正式 DS model、Serializer、DCLX→DS、DS→DocLang、canonical.json 的正式寫入及其他過時共用 Adapter，**不是僅把 DS 改名為 legacy 而仍由正式路徑呼叫**。

例外：隔離、唯讀、有時限的 Historical DS Migration Reader 可以留下，用於舊資料補遷移；必須標註 Owner、清除期限、明確測試，不能被任何新文件或正式 Index Producer 調用。

須提供 staging 環境零 DS 依賴之證明、可回退的 Migration Dry-run、版本策略、性能／記憶體比較、風險清單、完整 Release Candidate 及部署說明。Main 可自行完成本地／隔離環境的 DS Cleanup，但不得先刪除**尚未安全遷移的唯一歷史原始證據**。

### E10：Production Cutover 與產品交付

這是**唯一需要依第 10 節明確授權**的最終環境操作。Agent 在 E9 達標之前不能自動進 Production；達標後可準備完整 Cutover Bundle、Canary Runbook、回退點、監控與可執行 Script，供授權後執行。

Cutover 次序：
1. 產出可恢復、來源可信的正式資料備份與 schema/version inventory。
2. Canary 唯讀新路徑；監控錯誤引用、查詢結果、解析失敗、Latency。
3. 已確認可恢復使用者新寫入／修訂事件後，小比例切換寫入與有效版本。
4. Shadow Index 達標後原子調整 Index Alias，雙路由仍具回退能力。
5. 停止正式 DS 寫入並驗證所有消費者已遷移。
6. 清除已確認無依賴的 DS 正式程式與 Schema，以受控變更進入 Release。
7. 完成恢復演練與一段由實際環境要求決定的觀察期，最後記錄正式完成證據。

未獲 Production 權限時應交付 E9 的完整程式、工具、驗證與明確的 E10 Release Runbook，並將狀態定為 READY_FOR_RELEASE，**不是 BLOCKED 全案或虛報 COMPLETE**。

## 5. 對所有已知 Blocker 的具體解決策略

下表是**既定工程動作**，Main 應自動調度，不要再提交一輪只含分類的調查報告。

| 問題 | 優先解決方案 | 如仍不成立，如何繼續 |
|---|---|---|
| Windows DCLX 圖片 URI 反斜線 | 版本限定的安全相對 URI 正規化，保留原件和映射，新增正反 Fixture | 對壞封裝拒絕／隔離，繼續正常 DCLX 和 Office |
| DCLX 圖片 Description | 正確消費 picture.meta.description.text、caption；比對原始 XML→Reader→JSON→Viewer | 明確判斷 loss 發生層，不再重寫整個 Serializer |
| bbox 正規化 | 統一 coordinate system，檢查頁面尺度／原點／轉換 | 無法確證 Locator 則 fail closed，文本與非定位功能仍運行 |
| Unknown XML | 原始 XML/Assets 保留，影響內容的節點記錄 PARTIAL_UNVERIFIED、不能索引為 Verified | 支援範圍清楚，已驗證內容可繼續 |
| DocLang 0.9 與 Viewer 不兼容 | 留在已驗證的格式版本；新版本只在隔離 Profile 做 Schema/Viewer matrix | 不強迫整個 KA 升版 |
| Schema 1.10.0 / 1.11.0 不可降版 | Reader/Writer version profiles、向後／前向測試、可恢復遷移、保存舊原件 | 正式寫入先留舊版；不阻止其餘程式開發 |
| HybridChunker 缺 tree_sitter | 查看當版 Extras，隔離依賴安裝；若不用 HybridChunker 就維持既有 Chunk Policy | 不讓此依賴阻止 Legacy Chunk Algorithm 直接吃 DoclingDocument |
| Markdown 缺 marko | 在解析環境驗證對應 Extras，必要時使用受控 MD Parser | 不把錯誤轉換後內容當完整原生證據 |
| Excel 無 Cached Formula | 原始 workbook 真值、公式與計算結果分離保存、專用 source Evidence extractor | 只拒絕當作有計算值的 Verified Fact，不丟公式 |
| PPT Chart series/workbook | 來源 PPTX 專用 Extractor 結合原生 Docling Item／Anchor | 確切來源無法讀取時標記該細項未驗證，不偽造 series |
| 舊 PPTX 固定 Digest 失敗 | 保存 baseline defect，查決定性／排序／版本；修正需有 Truth Source 證據 | 舊已知紅燈不能壓倒新功能驗收，最終應有處理結論 |
| R1 29 BLOCKED／歷史 E22 | 逐類落到產品 consumer、source truth、native／sidecar／derived／drop；實作時一起關閉 | 缺真的來源/授權則標 EXTERNAL_DEPENDENCY；不讓不相關工作中止 |
| self_ref 位移／Anchor | Immutable Evidence ID + versioned logical anchor remap + ambiguity rejection | 未確證只停止受影響引用，不阻塞其他文件 |
| DS Review／Effective 深耦合 | 用 Versioned Governance／Native Effective View 逐點替代，保留 API/Editor 輸入契約 | 以相容 Adapter 區隔 UI，不能保留 DS 正式模型 |
| RAG 缺完整真實 Corpus | 先用合成、契約測試與授權可取得文件完成所有程式，Shadow Index 使用同設置 | 真實 Corpus 若不可得，E9 標 READY_WITH_VALIDATION_GAP，列明上線前必要資料 |
| DB/Index 恢復尚未演練 | 隔離 DB 快照／合成 staging 與恢復腳本、Shadow alias | 正式環境不可得時準備可執行 Runbook，只保留最後授權點 |
| DS 歷史資料版本 | Legacy Migration Reader + Source/Revision mapping，逐份原子轉換與 Dry-run | 無法安全轉換的歷史文檔隔離唯讀，不丟資料、不當新內容母本 |

## 6. 自主測試策略與不可妥協品質 Gate

### 6.1 測試層級

- Unit：DoclingDocument model、versions、source selector、URI normalization、Office Evidence、revision collision、migration Idempotence、assets SHA、Chunk policy。
- Contract：所有 Ingestion、Prepared Bundle、Review、Index Producer、Viewer API／data contracts，對比原產品 API 及版本語意。
- Golden Corpus：現有合成集合 + 必要新複雜 Fixtures（巢狀 DOCX、無快取公式、PPT embedded chart、DCLX unknown XML、Windows URI）；以實際原檔 Truth 優於舊 DS。
- Integration：Importer → JSON → Reload → Review → Effective → Chunk → Index → Retrieval → Viewer，涵蓋批准與拒絕事件。
- Failure Injection：壞 JSON、缺資產、錯 Schema、不安全 URI、壞 ZIP、XML 扭曲、Parser 升版、失效 Anchor、變更原件、DB 中斷寫入、Index 半成品、並發 Revision。
- Regression：現有產品測試與 M2-V0 全數，確保原本 PASS 不變；舊 PPTX Fail 的狀態和最終解決或隔離證據都需保存。
- Recovery：Shadow Bundle 恢復、歷史 Migrator 重跑、索引 alias 回退、Revision Event Replay、雙寫分歧後恢復。
- Security：DCLX ZIP slip、壓縮炸彈、XML entity / 外部資源、本機任意路徑存取、意外出站、檔案權限與秘密存取。**Python socket 攔截與 offline flags 不等於 OS 隔離**，執行報告須如實區分。

### 6.2 驗收門檻

| 項目 | 不可降低的門檻 |
|---|---|
| 來源證據確證 | Golden Truth 的關鍵引用正確率 100%，錯誤正向引用 0 |
| 原始 Office Formula、Range、Series、Workbook | 被宣稱支援的用例不得靜默遺失，來源映射須精確 |
| Document / Asset / Manifest | 保存與新 process 載入後完整校驗；錯誤時 fail closed |
| Review／Approval／Effective | 未核准內容不進正式 Effective；衝突修訂不被覆寫；版本可重播 |
| Retrieval 品質 | 與相同演算法設定的舊版相比，Recall@10 / nDCG@10 原則不得下降超過先前暫定 2 個百分點；最終依 M0 已核准基準及真實樣本統計，關鍵問題零退化 |
| Index | Shadow 與正式隔離，不得因測試覆蓋正式索引 |
| 舊產品回歸 | 已知 PASS 不可回歸；每一項歷史 FAIL 有獨立 defect 歸因，不能偷改 Golden |
| 正式 DS 依賴 | Staging 的新文件／API／Reader／Index Producer 正式路徑 = 0；只允許隔離 Legacy Migration Reader |
| Docling 升版 | 已演練至少一個候選版本的相容測試與失敗恢復，不能假稱舊 Reader 能讀新 Schema |
| 恢復能力 | 各種變更可安全回退且不丟 Source／Revision／Approval／Evidence |

測試數量多不代表功能達標。僅本機可重跑的樣本不能冒稱生產 Corpus 全覆蓋。當缺少真實資料或 staging 權限，應將工程功能完成與 Production Acceptance 分開標示。

### 6.3 自動化的 Gate Runner

在現有 Repo 添加一個可重跑的全任務驗證入口，例如 scripts/ka_dmm_full_verify.py（名稱僅為建議，執行者要按原 Repo 規範實作）。至少要能：

1. 列出環境、依賴、Source/Fixture SHA。
2. 執行所有 native imports 與 schema/asset roundtrip。
3. 執行各來源 Precision Evidence、Anchor、Review/Effective、Chunk、Viewer、Index 測試。
4. 執行 failure injection、安全與 fallback 測試。
5. 與原產品回歸比較，輸出基準已知錯誤和新回歸差異。
6. 針對資料 Migration、Shadow Index、version upgrade 的可恢復性做隔離演練。
7. 產生機器可讀 Gate 結果與人類可審閱的完整摘要，**不可將未跑的測試記為 PASS**。

## 7. 範圍與完成義務：消除文件工程的永久試驗狀態

M2-V0 已經 PASS，代表「原生內容解析至本地檢索」這條主幹可行。後續不能永遠停留在 Shadow Demo。完整任務完成前 Main 必須自主接續 E1～E9，直到實際可上線的 Release Candidate 成立。

「某功能尚未完成」一定要轉成：
- 正在實作並有 Commit／可重跑測試的工作。
- 已知可行但需局部兼容的特定 bug 修正。
- 缺外部來源／憑證／權限的明確授權項，並已完成不依賴該項的所有工程。
- 確實不可安全實作、且已完成可重現反例的架構例外 ADR。

不允許：每發現一項問題就新增一輪只做 P0、問使用者是否繼續；也不允許為了快而降低 Gate、抹除已知缺陷、把錯誤確認為正確或偷渡 Production 寫入。

## 8. 最終完整交付包

Main 應在本地 KA Repo 製作（允許按 Repo 既有結構調整路徑）：

    docs/migrations/ka-dmm/autonomous/
      README.md
      architecture_and_decisions.md
      upstream_compatibility_matrix.md
      data_schema_and_manifest_contract.md
      supported_sources_and_fidelity_matrix.md
      evidence_and_anchor_contract.md
      review_effective_migration.md
      chunk_index_groundedness_results.md
      viewer_doclang_dclx_contract.md
      historical_migration_and_rollback.md
      ds_dependency_removal_report.md
      security_and_failure_injection.md
      release_candidate_checklist.md
      production_canary_and_rollback_runbook.md
      full_gate_report.md
      open_issues_with_bounded_next_actions.md

加上實際產品程式、Migration Tools、Feature Flags、測試與 Fixture、CI／Upgrade Checks、Shadow Index／Staging Script、可重跑 Runner 與完整 Git Commits。**只交報告不算完成**。

### 8.1 Definition of Done

**Engineering Complete** 必須同時具備：

1. E0～E9 實際功能可在 Staging／隔離環境執行，沒有資料或證據的靜默流失。
2. 共用內容模型只剩 DoclingDocument，無第二套 DS 2.0。
3. 所有現有必需文件來源、Review/Effective、RAG/Index、Viewer、歷史 migration 都有真實端到端路徑。
4. 新正式程式路徑、產品 API、Index Producer 完全不依賴 DS，僅剩隔離舊 Reader。
5. 完整 Regression、Golden Truth、異常、跨版、Rollback 與 CI 都有可重跑證據。
6. 已有安全、可執行的正式 Cutover／Rollback Runbook，若缺真實 Production 權限則記錄最後授權點。
7. Main 能提出完整 Release Candidate Commit、功能支援表、風險與部署方法，而非只說「研究完成」。

**Production Complete** 必須另外具備：使用者授權、實際資料備份／Cutover、觀測結果、最後 DS 停寫／移除成功與生產復原能力證據。未執行不得宣稱 production 已完成。

## 8A. 必須持續同步的公共狀態契約

**強制要求**：Coding Agent 主代理必須將本次長程自主任務的進展同步至公開交接 Repository 根目錄的 [KA_DMM_STATUS_SYNC.md](../KA_DMM_STATUS_SYNC.md)。這是對使用者的進度透明度要求，不改變自主執行授權，也不需要使用者在中間轉送報告。

### 8A.1 固定寫入目的地與頻率

- Repository：caseykcc0124/codex_coding，Branch：main。
- 固定目標路徑：KA_DMM_STATUS_SYNC.md。此檔已由交接端建立模板；**不要另外建立第二份狀態文件**。
- Agent 只可在自身工作執行中定期推送，不是要求 ChatGPT 替它撰寫或猜測進度。
- **任務 ACTIVE 時至少每 60 分鐘同步一次**。這是最大間隔，不必每次都增加新功能。即使沒有進展，也應更新 heartbeat、正在處理的工作及下一步，但不可假裝進度。
- WorkItem 開始／完成、Gate 轉換、重大阻擋與恢復、Stage 改變、Engineering Complete、READY_FOR_RELEASE、需使用者授權或任務暫停時**立即同步**。
- Agent 進入 PAUSED 或完成狀態後不需持續心跳；下一次重新開始時立即轉回 ACTIVE。
- 無法使用計時器時，Main 透過既有 Loop／Heartbeat／Agent scheduler 機制實作每 60 分鐘的同步檢查；**不應另啟無人管理的背景程序、未授權服務或自動化**。如執行環境本身無法維持長時間運行，應在每次可執行段落開始與結束時更新，標明實際可達成的頻率，不能虛報為常駐。

### 8A.2 每次必須同步的資訊

請更新固定 Markdown 表格／區段，保留可供人直接閱讀的摘要與機器可分析的欄位：

1. updated_at_utc、updated_at_taipei、last_progress_at_utc 與 instruction_version／instruction_commit。
2. mission_state、active_stage、current_work_item、stage_gate、engineering_release_status、production_status。
3. **真正交付的新能力**：目前哪些來源／Review／Index／Viewer 路徑可執行，已實作與已測試分開。
4. 測試 Passed／Failed／Skipped，新的 regression 與前輪已知 PPTX red baseline 的區別。
5. 每個 E0～E10 的狀態、受影響範圍、下一個可交付里程碑。
6. Blocker、最小可重現原因、已採用方案、下一項自行修復動作，以及哪個事項真的需要使用者授權。
7. Evidence／Citation 的錯引數、是否仍有 DS 正式依賴、Shadow／Staging／Production 位置及回退驗證摘要。
8. 若 User Action = YES，給出唯一或少量明確決策點、風險、推薦與不授權時可繼續做的其他工作。

所有量化數字都有時間及範圍，不可只用「跑了 100 個測試」代替工程進度。每次更新若無新增實際交付，應記「本次無新增可用能力，仍在修復 X」，避免虛假 Completed。

### 8A.3 寫入權限、併發與 GitHub API

使用 Agent 已獲授權的 GitHub/HTTP 寫入能力，採用 GitHub 內容 API 或等價操作，先讀取檔案 Blob SHA，再做條件式更新；失敗時重讀、合併後重試。禁止使用強制推送覆蓋其他編輯。**只有 Main Agent 寫此檔，Sub Agent 交付 Main 匯總，不得各自互相覆寫。**

此公共 Repo 的例外授權**僅涵蓋這個去敏狀態檔**。不得把本地 KA 私有原始碼、公司內部資料、完整 logs、檔案路徑、真實 Source Fixture、可識別環境資訊、密鑰或未審核內容推送公開。可用代號、測試類別和量化摘要；完整 Commit／Log／測試證據留在原本本地 KA Repo。若對某內容是否可公開無把握，省略內容、標示已保留本地證據，不要上傳原文。

若 Agent 缺寫入權限或 GitHub API 暫時不可達：將錯誤記錄在本地工作日誌，重試；仍可繼續工程。**不能宣稱已同步**。待可用後補上去敏狀態，並在下一次對使用者報告寫入失敗原因。此情況不授權讀取新秘密或變更網路政策。

### 8A.4 監督者讀取與陳舊判定

ChatGPT 的定時監督預計由獨立的排程任務讀取此公開檔案。**截至本次指引更新，新增排程因使用者帳號已達 5 個任務上限而尚未成功建立**，不可宣稱巡檢已啟用。待使用者騰出排程名額並建立任務後，才會自動巡檢。Agent 的每小時 GitHub 狀態更新義務不受此限制。Agent 應保持固定欄位及穩定 Markdown 格式，讓未來監督者能比較：

- 狀態是否變更、是否新增可用能力、Gate 是否改變；
- 發生新 BLOCKED／需授權／完成；
- updated_at 是否在持續 ACTIVE 時落後超過 3 小時。

**更新過久只代表狀態資料可能過期，不等於 Coding Agent 真的停止工作或產品當機。** 避免為「檔案沒更新」直接觸發有風險的修復或重新部署。

### 8A.5 強制同步 Gate

- 本輪交付、任何 E 級重大完成及 READY_FOR_RELEASE，必須在同步檔留下去敏摘要。
- 公開狀態檔的最新更新須含最新 Gate 與 next_action；未經 GitHub 實際寫入成功不得聲稱同步 PASS。
- 若狀態檔更新失敗，但產品工程有真實成果，分開記錄「產品 Gate」與「狀態同步 Gate」，**不抹除已完成的工程成果**；Main 必須自主補正同步。


## 9. 主代理如何自行推進，避免無限往返

1. 啟動時一次形成依賴圖與實作次序；除第 10 節保留的授權點外，全部 E0～E9 是**已授權工作**。
2. 自己按可工作量分解任務，直接進行程式修改、整合和測試，局部錯誤至少先走完「最小重現 → 修復候選 → 測試 → 回歸 → 留證」的流程，不要用一行 BLOCKED 結束工作。
3. 當某來源有未解上游缺陷，先在本地隔離該來源並繼續其他來源，最後回到該缺陷；不可因局部問題反覆要求使用者批准開發。
4. 可把無相互檔案衝突的任務分配給 Sub 並行，但 **Main 必須輪詢／收取成果、整合 Git、檢查錯誤與重新指派**；不要把 Sub 活動量當成進度。
5. 有有限度、明確的工作範圍和停止條件，避免不斷擴張需求。每個缺陷應有完成標準，不因任何新想法額外開一個平行大專案。
6. Main 可以按可用工具能力提交本地 Branch、Commit、PR 或 Staging 產物。除非使用者明確授權，**不得將私有 KA 內容推送到公開 Repo 或外部服務**。
7. 只在真的需要第 10 節授權、或 E9 Engineering Complete 後，提供一份整合性回報。其餘進度可紀錄在本地狀態看板與 Gate JSON，不應要求使用者當跨批次信差。

## 10. 唯一真正需要使用者再介入的情況

以下情況 **Main 必須停止受影響的動作**，提交單一具體決策／授權要求；**同時繼續不依賴該操作的工程**：

1. 需要直接修改、重建、清除正式環境的 DB／Index、或切換正式 API 寫入與正式服務流量。
2. 需要刪除、覆寫無可恢復備份的真實使用者資料／歷史修訂或唯一原始證據。
3. 需要提升或取得未授權權限、密鑰、公司機密、跨網服務、付費模型／套件或外部連線。
4. 需要將任何公司／私人原始碼、文件、測試資料、檔案、Issue、PR 推向公開第三方。
5. 出現已充分實測、且無法透過 Docling 原生模型＋局部 Evidence／Governance 承接的必要功能，必須更改本次核心架構目標。
6. 正式切換前的生產資料恢復或使用者已在運作的 Review／Approval Event 無法保真，須做不可逆資料處置。

**普通 bug、已知官方缺陷、版本不兼容、測試失敗、需要新增 fixture、缺可選 Extras、現有 DS 已知缺漏，均不屬於每輪需找使用者的理由。**

如需問使用者，只能提出少量真正不可由 Agent 自決的具體選項、影響、推薦與已完成的其他工作，不能只問「下一步要不要繼續」。

## 11. 完整任務最終回報格式

    Mission: KA-DMM Full Autonomous DS Replacement v2.0
    Instruction URL / exact GitHub commit:
    Local KA Repo / working branch / final commits:
    Status: ENGINEERING_COMPLETE / READY_FOR_RELEASE /
            PRODUCTION_COMPLETE / EXTERNAL_APPROVAL_NEEDED / PARTIAL
    Environment / Docling package versions / Schema versions / lock:
    Implemented capabilities by source and business module:
    Actual DS-free production/staging dependency evidence:
    Reused M2-V0 functions:
    Supported and unsupported formats/versions:
    Original-source fidelity / Office Evidence / Anchor results:
    Review / Effective / Approval / Viewer verification:
    Chunk / Index / Retrieval / Groundedness quality:
    Golden Truth / Unit / Integration / Security / E2E passed-failed-skipped:
    Known existing PPTX failure disposition:
    Historical migration dry-run and recovery results:
    Candidate upstream upgrade and downgrade test:
    Change list / Commit evidence / CI / performance:
    DB / Index / Secrets / Network / Published code touched?:
    Product and production environment change authorization status:
    Rollback tests / failure-injection / backups:
    Final unmet items with exact cause and next bounded action:
    Engineering Definition of Done status:
    Production acceptance status and required authorization:
    Recommended release procedure and final risks:

**本任務的交付物是可運行的完整 KA 原生模型系統與 DS 淘汰所需的全部程式、測試、資料轉換與驗收證據。除本文件第 10 節的正式環境與不可逆授權外，不再需要 ChatGPT 每一小段重新發一份 GitHub 工作指引。**

## 12. 官方資料與對接優先序

下列公開來源是開發和能力測試的參考，**不能取代本地安裝版的實際 API／Fixture PASS**：

- https://github.com/docling-project/docling
- https://github.com/docling-project/docling-core
- https://github.com/docling-project/docling-core/releases
- https://docling-project.github.io/docling/reference/docling_document/
- https://docling-project.github.io/docling/concepts/serialization/
- https://docling-project.github.io/docling/concepts/chunking/
- https://docling-project.github.io/docling/usage/supported_formats/

優先使用官方 DocumentConverter、DoclingDocument 原生 Serializer、load/save、DocLang archive Reader、BaseChunker 等**在當版實測可用的**能力。官方 DocLang archive Loader 具有資產解壓／大小設定，應確認實際版本可用的安全限制；JSON 讀回對本機圖片載入的選項需根據來源信任級別使用。DocLang 與完整 JSON 的語意、跨版本保真和 Reader 相容性要靠契約測試確認。

**上游演進方向確立：能以官方版本正常升級，才算架構真正收斂。**

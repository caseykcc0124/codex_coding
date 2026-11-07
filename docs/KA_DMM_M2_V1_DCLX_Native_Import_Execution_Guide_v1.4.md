# KA-DMM：M2-V1 原生 DCLX 匯入與證據保真交付指引

> 文件版本：v1.4  
> 制定日期：2026-11-07  
> 適用對象：Coding Agent，執行於既有 Knowledge Agent Repository  
> 上位計畫：[KA-DMM v1.2](./KA_DMM_Docling_Native_Migration_Plan_v1.2.md)  
> 前一工作包：[M2-V0 v1.3](./KA_DMM_M2_V0_Delivery_Execution_Guide_v1.3.md)  
> **本輪唯一新增授權：M2-V1，DCLX → DoclingDocument → 保存重載 → Chunk → 本地檢索與來源引用，僅於隔離 Shadow 運行。**  
> **不授權**：替換 DS 正式流程、正式 DB/Index、Review/Effective 寫入、Viewer 回寫、正式依賴升版、正式部署、公開公司資料或自動建立上游 Issue。

## 0. 指令來源、執行交接與不重工原則

這份 GitHub Markdown 是本輪完整正式工作指引。ChatGPT 對話內容只有在已寫入本文件後才構成 Coding Agent 的工作要求。Coding Agent 可透過經授權的 HTTP 抓取此檔，需保存**實際取得的 GitHub URL、Commit SHA、指引版本和工作時所用的本地 KA Commit**。不得把本公開交接 Repo 當作 KA 原始碼 Repo。

既有 M2-V0 已由使用者於 2026-11-07 回報**Gate 與獨立審查 PASS**；本輪禁止反覆重做它，應直接沿用其已驗收的 API、Runner、JSON/asset 保存、Chunk 策略、local retrieval、測試和回退。前輪實測資料只屬於使用者回報，執行前先在本地確認報告和 Commit：

- M2-V0 代碼 Commit：2a740b3，交付記錄 Commit：b44f8f6，未 push 公開 Repository。
- 官方 PDF 解析至 DoclingDocument，JSON＋2 張頁面圖片，新 Process 重載，7 個 Chunks，原生 source selector。
- 5 筆正向 Truth 查詢加 1 筆無證據拒答，錯誤引用 0；T01～T10 通過；8 項整合測試無失敗、錯誤或跳過；6 類 fail-closed 注入。
- 執行環境 Core 2.101.1、DocLang 0.7.3、docling-slim 2.137.0、Docling schema 1.10.0。
- 舊 DS 測試 49 PASS、1 項既有 PPTX FAIL，正式服務與 DB/Index 未動；整體 KA-DMM Gate 仍 BLOCKED。
- 已回報的入口為 python -X utf8 scripts/ka_dmm_m2_smoke.py。本輪將其作為不可退化基準，不要求重新命名。

如本地數據、工具版本或工作樹與回報不同，先記錄差異並保護使用者現有修改，不許無條件 reset、覆蓋或清理。

### 0.1 固定最終架構

DoclingDocument 是**唯一通用內容母本**；DocLang/DCLX 用於輸入、交換與 Viewer，Docling JSON 用於保存原生內容；KA Office Source Evidence 與 Governance 在獨立領域資料層保存。不得將 DCLX 先轉 DS 或創造任何 PageContentV2、CanonicalBlockV2、UnifiedTable 等第二套通用文件樹。

M2-V1 的交付目標是：在既有 M2-V0 程式路徑加入**真正可用的 DCLX 來源入口**，並讓保真、引用與故障行為可重跑。不得退回「再次盤點 Docling 能否支援 DCLX」的開放式研究。

## 1. 本輪任務與完成樣態

### 1.1 必須交付的端到端流程

    Local DCLX bundle (DocLang XML + images/pages/assets)
                        |
          Validate container and source SHA
                        |
       Docling Core native DCLX / DocLang Reader
                        |
                 DoclingDocument
                        |
          Native JSON + assets + manifest
                        |
              Fresh-process reload
                        |
          Existing zero-revision read view
                        |
           Existing M2-V0 Chunk Policy
                        |
       Existing M2-V0 local lexical retrieval
                        |
       Matched chunk + evidence + source location

這條路徑必須真的使用 DCLX 作輸入，不能以「從 Python 手動建立 DoclingDocument」冒充 DCLX 匯入，也不能只顯示圖片就宣稱結構、說明、provenance 完整。

至少提供**兩類獨立 Fixture**：

1. 受控、可重現的 DCLX，包含標題、段落、表格、至少 1 張圖片、圖片描述或 caption、來源定位及相應 assets。
2. 另一個**不同產生路徑或不同封裝來源**的 DCLX（例如由官方 Writer 輸出，或由已存在且授權使用的 DCLX 封裝）。避免只用同一 Writer→Reader 的單一循環測試掩蓋共同錯誤。

若來源格式的某一組語意在已安裝版本根本無法被 Docling 原生 Reader 接受，必須留下最小正反 fixture 及明確的 Input Compatibility Limit；仍需完成至少一個真正可用的 DCLX 來源路徑。若連一個完整來源都無法承接，才將本工作包標 BLOCKED，並交付有限修復的下一步。

### 1.2 唯一新增主要範圍

- 將 DCLX 格式作為 M2-V0 Shadow Runner 的新增輸入來源，**重用**其原生 JSON、Manifest、assets、Chunk、local retrieval、source citation 邏輯。
- 以最小化 DCLX Source Adapter／Versioned Compatibility Policy 補足 Windows URI 與資產引用的既知失敗。
- 正確處理 Docling 原生 Picture、Caption、Description、bbox、pages、source locator，僅保存能驗證的 provenance。
- 為未知 DocLang XML 建立保留、顯示／索引處理、告警和拒絕採用的明確政策。
- 提供版本相容性、故障注入、全流程測試和回退證據。

本輪**不**：更新 Core 至 2.106.0、強制導入 DocLang 0.9、修原生 Excel/PPT 解析、全面 stable anchor remap、Review 寫入、正式 Viewer 行為、Embedding RAG、正式 DB/Index、正式 DS 刪除。

## 2. 已知缺陷的「有界修復」規則

### 2.1 Windows DCLX 圖片 URI

前輪觀察：部分 Core 在 Windows 官方 DCLX Writer 會輸出含反斜線的圖片 URI，Reader 直接重讀可能失敗；診斷副本正規化後可以讀圖。下一步要交付**實際可用的受控匯入**：

- 優先檢查該版本官方 Reader 的可用設定及公開 URI／Asset API；能官方方式解決就不要建立私有轉換器。
- 若需 workaround，只在 M2-V1 的 **DCLX Source Adapter** 進行「版本限定的 URI 正規化」，不得修改 Docling 原始碼、已安裝套件、主環境依賴或原始 DCLX。
- 永久保存原始 DCLX bytes、SHA 和原始 XML；修正只作用於**隔離的解析輸入副本**，記錄修正前後的 URI、檔案／Asset 對應與完整性差異。
- 只對已驗證可安全正規化的**封裝內相對 Asset URI**生效；不允許藉由 URI normalization 存取外部磁碟檔案、網路資源或壓縮檔外路徑。
- 版本不適用、無法正規化或資產不存在時應拒絕處理／引用，明確報錯，不要產生空圖或虛假來源。
- 加入可停用開關、版本範圍、Owner、撤除條件；日後官方修正時能移除 workaround，留下同一測試集驗證。

不得把「Windows URI 修正後圖片看得到」當成整體 DCLX 資料保真 PASS。

### 2.2 圖片描述與 Caption 的真實位置

前輪已證明部分情境中 picture.meta.description.text 仍保留圖片描述文字；既有 KA Adapter 未讀取，annotations 為空**不等於** description 遺失。

本輪要從**實際 DCLX 來源**驗證：

- Picture 本身存在且 Asset digest 可定位。
- Caption、Description、Picture item、其 metadata 與來源 locator 的關聯正確；不能只用 display text 代替原生欄位。
- 讀回 DoclingDocument JSON 後，保留描述的原生字段及語意，不應把描述移到未知的自訂 GenericBlock。
- 如某版 Reader 對某種來源仍丟失 Description，必須標明「原始 XML 是否存在」、「官方 Reader 是否接到」、「KA 原生路徑是否讀取」哪一段發生 loss，不得泛化成所有 Docling 都不支援。
- 原生 description 與 AI 補充描述須區分來源與可信狀態；不得將 AI-derived caption 當原始來源事實。

### 2.3 bbox 與頁面定位

bbox 尺度或座標規一化可能改變數值表示，不能直接判 loss。測試必須對照原始 page dimension、coordinate origin、bounding box transform，**在一致座標系中比較位置**。若無法驗證轉換，不允許產生看似精確的頁面引用；不得將 PDF physical page、PPT slide 或 Excel worksheet 誤當相同 page_number 語意。

### 2.4 Unknown XML

原始 DCLX／DocLang XML、Assets 與未能被 Reader 表示的節點要可追溯保留；定義至少以下狀態：

- PARSED_AND_VERIFIED：Reader 能表達且通過 Truth Source 檢查，可參與 Chunk／Evidence。
- PRESERVED_UNPARSED：仍保存在原始封裝，但目前未被 Reader 解析；不能假裝進了 Effective 或索引。
- REJECTED_UNSAFE：URI、封裝檔案或解析要求違反安全邊界，拒絕。
- NOT_SUPPORTED_VERSION：DocLang 格式版本超出已測試範圍，明確拒絕或隔離，不擅自降版。

若未知內容會影響標題、表格、來源關係或 Evidence 真值，整份文件應標為 PARTIAL_UNVERIFIED 或 BLOCKED，至少不能讓相關未驗證區塊進入檢索證據。若是無關緊要、已證明可忽略的非內容 metadata，可保留且告警，不能靜默丟棄。未知 XML 的完整 round-trip 不要求在本批重寫官方 Writer，但必須保存原始資料，清楚揭露衍生結果並非無損替代。

## 3. 可執行分批 WorkItem

### V1-A：固定基準、直接證實 DCLX 來源

- 讀取並重跑 M2-V0 的既有 Smoke（至少 T01～T10）與現有產品回歸；保存執行命令、環境、Commit、Fixture SHA 和差異。既有 PPTX 紅燈作 Known Failure，不更新 Golden。
- 從本地實際 P0-R 的 DCLX fixture 和測試報告確認哪個 Core/DocLang 組合可用。優先沿用已核准的 Core 2.101.1／DocLang 0.7.3；需要試 2.105.0／0.8.1 時，只能用其已存在的隔離 Profile，不能混裝。
- 在未改正式流程的前提下直接載入至少一個真正的 DCLX，列出 source、assets、DoclingDocument items、caption/description、page/locator。
- **Gate A**：能證實至少一個明確支援的 DCLX 輸入，以及未支援的精確缺口。若受控 fixture 本身缺必要資料，可在本地補一個合成 fixture，但要記錄原始 Truth。

### V1-B：完成可用的 DCLX Source Adapter

- 針對已證實的 Windows URI 失效做最小安全兼容，原檔不可修改；不得為此新增 DCLX DocumentStructure。
- 將 Adapter 接到 M2-V0 已有的 JSON＋Asset 保存／重載流程，加入來源版本、原始 DCLX SHA、DocLang schema／Reader Profile、兼容處理日誌、資產 digest。
- 如 Docling 原生圖片／描述已可完整讀取，直接沿用，不再重做一個自訂 picture table。
- **Gate B**：支援範圍內，至少 1 個帶圖且有來源關係的 DCLX 完成「匯入 → 保存 → 新程序重載」，圖片與描述、bbox／locator 經 Truth 驗證，未校驗的資料不隱藏。

### V1-C：接回 Chunk／Retrieval，驗證可信證據

- 重用 M2-V0 既有 chunk policy：1500 字元、重疊 100、表格分列且重複表頭，除非本地已驗收政策的實際配置不同，以既有原始設定為準，不自動修改。
- 透過官方 DoclingDocument 原生 items 產生 Chunk 與來源 selectors；**不得經 DS**，也不得從 DCLX Viewer 的渲染文字反推 Canonical 內容。
- 在 local lexical retrieval 至少測 **5 筆正向 Truth Query + 1 筆無證據拒答**，其中至少涵蓋圖片 caption/description、表格值、段落／標題及資產來源定位。
- 回答可簡化為 matched chunk、source id、page/locator、證據 fragment；不需要 LLM 作答，不得宣稱已完成正式 RAG。
- **Gate C**：每筆正向查詢指向原始 DCLX／相應資產的正確位置，錯誤正向來源引用 = 0。沒有可驗證 provenance 時 fail closed。

### V1-D：失敗注入、回退與整合驗收

- 檢查不安全 ZIP member path、絕對路徑、dot-dot traversal、symlink／外部參照、過大解壓資料與資產引用、遺失圖片、Asset SHA 不符、XML 格式錯誤、未支援 DocLang 版本與 JSON schema；不要求重新設計安全框架，只要對本入口 fail closed。
- 驗證兼容正規化**不會**把封裝內相對路徑提升為本機任意檔案存取，不允許自動出站網路抓圖。
- 重新執行 M2-V0 測試及舊 DS 路徑回歸，不允許造成既有 PASS 變 FAIL，也不允許隱藏已知紅燈。
- 刪除／關閉 M2-V1 Shadow 輸出後，既有 DS 流程仍正常；測試不得污染正式 DB／Index 或修改產品依賴 lock。
- **Gate D**：完整 CLI／測試一次重跑，生成真正的差異與原始 log、版本、Commit、回退證據。可控失敗時不生成錯誤證據。

各子批次可獨立 Commit／測試／驗收；上一子批次未通過，不得透過擴張下一個工作包掩蓋問題。本輪不需要反覆開新的架構研究與報告，應優先落地 B／C 可運行能力。

## 4. 測試矩陣與量化 Gate

| ID | 測試內容 | PASS 條件 |
|---|---|---|
| D01 | 兩種來源路徑的 DCLX 檔案、格式版本與 Zip/Asset 清單 | 至少 1 個完整有效來源可處理；第二個來源測試結果有差異報告 |
| D02 | Docling 原生 Reader → DoclingDocument，無 DS | 實際 import 成功、來源 items 可讀；DS import/call = 0 |
| D03 | Windows URI 正規化，保留原始 bytes 與 URI 追蹤 | 安全、限定版本、可停用、可重複、沒有來源改寫 |
| D04 | 圖片 Asset SHA、Caption、Description 與 relation | 原始有的關鍵值在重載後一致，不能只檢查可見性 |
| D05 | bbox 座標系等效、來源頁面定位 | 轉換後 locator 正確，無錯頁或假 precision |
| D06 | JSON/Manifest/Assets 新 Process 重載 | Digest、來源版本與內容語意保留 |
| D07 | Chunk 與 DCLX 原始來源 Evidence 索引 | 不經 DS；不從 Viewer 反推；表格與圖片證據完整 |
| D08 | 5 positive Truth + 1 no-evidence query | 來源引用錯誤 = 0；拒答不生成假引用 |
| D09 | Unknown XML／未支援版本與未解析內容政策 | 有明確警告、保留原始檔；重大未解析內容不被當 Verified Fact |
| D10 | ZIP traversal／外部 URI／資產缺失或修改等故障注入 | Fail closed；不逃逸容器、不出站抓資料 |
| D11 | M2-V0 T01～T10 與已知 DS 回歸 | 既有 PASS 不減；保留 1 項已知 PPTX Fail |
| D12 | 完整回退、無正式依賴／DB／Index／Service 修改 | 原流程不變；Shadow 可關閉並移除輸出 |

每個 Test 必須記錄來源 Fixture SHA、Core/DocLang/Schema 版本、Runner 命令、預期/實際、日誌與輸出。**不得用測試數量或可顯示圖片替代資料保真與引用正確性的證據。**

### 4.1 Gate 分離

- **M2-V0：前輪已回報 PASS**。維持可運行，不重做其全部內部設計。
- **M2-V1：本輪 PASS** 只代表已明確列出支援範圍的 DCLX → DoclingDocument → 保存／重載 → Chunk → local retrieval + Evidence 完成，且具有安全故障行為。
- **DCLX 相容性跨版本全覆蓋** 可以仍是 PARTIAL／BLOCKED，特別是尚未核准的 DocLang 0.9／Core 2.106.0、Viewer 編輯與 unknown XML 全部 Schema 往返。
- **整體 KA-DMM：仍可 BLOCKED**。正式 Reader／DB／Index／Review／RAG／Office 等尚未完成，不得以 M2-V1 局部 PASS 宣稱全遷移已交付。

## 5. 完成定義、產物及下一輪方向

在本地 KA Repository 內交付（檔名可依現有命名規則調整，但內容不能省略）：

    docs/migrations/ka-dmm/M2-V1/
      README.md
      scope_and_supported_dclx_versions.md
      native_dclx_import_contract.md
      windows_uri_compatibility.md
      original_asset_and_metadata_truth.json
      unknown_xml_and_safety_policy.md
      dclx_roundtrip_and_fidelity_diff.json
      chunks_and_source_evidence.json
      retrieval_truth_cases.json
      negative_tests_and_fail_closed.json
      regression_and_rollback.md
      M2_V1_gate_report.md

並交付**真正可運行**的 Adapter、既有 Runner 的 DCLX 來源入口或獨立輕量 Runner、新增 Tests/Fixtures、單一可重跑命令、原始測試 log、Commit。不得只有文件和樣本資料。

建議 Runner 命名 scripts/ka_dmm_m2_v1_smoke.py（僅為建議，**不表示此檔已存在**）。必須能由單一 command 完成 DCLX fixture import、保存、重載、Chunk、Retrieval、Evidence 與失敗注入。若重用 M2-V0 CLI 更合理也允許，但必須保留 V0 入口完整可用。

### 5.1 下一輪只作規劃，不在本批授權

M2-V2 預定處理 **XLSX/PPTX 原生證據完整承接**：公式及快取／無快取、named ranges、chart series、shape/embedded workbook 的正確來源 binding，繼續不經 DS，並接入已驗證的原生 Chunk／檢索路徑。

M2-V3 預定處理 Stable Logical Anchor、跨 Parser 版本 reparse／remap。M2-V4 再處理 Review／Effective 的真正採用語意與 Viewer。M8/M10 的正式 RAG、Canary、DS 清除及資料轉換另行核准。

## 6. Coding Agent 完整回報格式

    WorkItem: KA-DMM M2-V1
    Instruction URL / version / fetched Commit:
    KA Repo / Branch / Commit / dirty worktree:
    Docling Core / DocLang / Schema / Parser version:
    Supported DCLX version + fixture sources:
    New code files / actual changes / why:
    Reused M2-V0 components:
    Real end-to-end command:
    D01-D12 PASS / FAIL / SKIP with raw logs:
    Native items and JSON + asset digest diff:
    Picture description / caption / bbox / provenance outcome:
    Windows URI fix scope / toggle / removal condition:
    Unknown XML and unsupported version policy:
    5 positive + 1 negative citation results:
    DS import/call count and evidence:
    Existing M2-V0 / DS regression:
    Failure injection + rollback:
    Production DB / Index / API / Secrets / Network touched?:
    Remaining blockers mapped to exact source or feature:
    M2-V1 Gate:
    Overall KA-DMM Gate:
    Next bounded WorkItem proposed / approval requested:

**最後停止點**：M2-V1 交付且 Gate 報告完成後停止。不得自行開始 M2-V2，不能切換正式入口、升級正式依賴、部署、公開公司資料或刪除 DS。下一輪新指令必須由 ChatGPT 整合到公開 GitHub，Coding Agent 才能另行開始。

**最高驗收原則：每一輪增加一段真正可用、可驗證、可回退、無 DS 的文件處理能力，已知缺口應在對應來源格式中修正，不讓不相關問題阻擋本輪交付。**

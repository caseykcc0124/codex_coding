# KA-DMM：下一輪執行指引（P0-R1、P0-R2、P0-R3）

> **已由 [v1.2 收斂交付版](./KA_DMM_P0_Blocker_Resolution_Execution_Guide_v1.2.md) 取代。請勿再使用 v1.1 作為新 WorkItem 的執行依據。**

> 文件版本：v1.1（本輪完整正式執行規格；v1.0 已被取代）  
> 日期：2026-11-06  
> 主計畫：[KA-DMM Docling Native Migration v1.2](./KA_DMM_Docling_Native_Migration_Plan_v1.2.md)  
> 指令接收者：Coding Agent  
> 狀態：**待執行規格，非已驗收報告**  
> 工作模式：在原本 Knowledge Agent 專案內逐批執行，保留逐批 Gate。  
> 本輪授權：R0 基準確認、P0-R1 替代性裁決、P0-R2 保真與 Anchor 驗證、P0-R3 官方版本相容性。  
> **禁止直接進 M2、刪 DS、更新正式 DB/Index、修改正式服務、部署或公開內部資料。**

## 零、正式指令單一來源與跨代理交接

**本文件是本輪 Coding Agent 的完整正式工作指引。所有具體指令必須落在 GitHub，而非僅出現在 ChatGPT 對話。** ChatGPT 對話中的分析、建議、狀態摘要，未在此文件明載的部分都不構成本輪授權。新增或修正要求必須以 GitHub 新版文件和可追溯 Commit 交付，不能口頭擴張。

兩個 Repository 分工：
- 公開交接 Repo：caseykcc0124/codex_coding，用於放置完整工作指引和經核准可公開的非敏感狀態。
- 既有 Knowledge Agent Repo：Coding Agent 實際執行與儲存所有完整測試證據的位置。此 Repo 可能有私有資訊，不得複製到公開 Repo。

**每輪工作循環：**
1. ChatGPT 更新 GitHub 完整 Markdown 指引，並核實遠端檔案內容、版本與 Commit，向使用者提供連結。
2. Coding Agent 取得指定版本和 Commit，在既有 KA 專案建立 WorkItem，依本指引逐批執行，不自行進入下一版任務。
3. Coding Agent 在 KA 本地保存測試、fixtures、差異與報告，產出方便使用者貼回的精簡 Gate 摘要。除非有明確授權，不將這些內部證據推送公開 Repo。
4. 使用者將驗收報告交給 ChatGPT；ChatGPT 審查後將下一輪指引寫回 GitHub。下一輪尚未發布前，Coding Agent 必須停在 Gate。

**交接完成標準：** 新指引已推送、可從 GitHub 重新讀取且主計畫連到最新版本；如果只在聊天中說明，或只有本地未推送文件，均不算完成。

## 一、GitHub 交接契約

本公開 Repository（caseykcc0124/codex_coding）是 ChatGPT 與 Coding Agent 的**工作指引交接管道**。Coding Agent 從此處讀取此版指令，在**既有** Knowledge Agent Repository 執行。此公開 Repo 不是 KA 產品程式、正式文件、實際測試資料或秘密的保存區。

1. 先讀本文件，再讀連結的 v1.2 主計畫，以及 KA 本地已建立的 P0、P0-U、M0、M1 報告與 README。主計畫的安全禁止規則優先。
2. 本輪使用文件版本 v1.1，記錄取得的公開指令 Commit SHA。v1.0 已被取代；往後文件有更新，不可默默更換執行基準，需明確版本決策。
3. **詳細證據僅存於本地 KA 專案**：Commit、測試 log、Fixture、來源 SHA、內部路徑、Diff、工作樹狀態；不可直接推送至此公開 Repo。
4. 任何可公開的工作回報必須先去識別、確認沒有公司資料及內部資訊，且取得授權。沒有授權時，向使用者提交本地證據摘要即可。
5. 每個 WorkItem 都有自身的狀態、Commit、測試、Gate 與停止條件。完成 R1/R2/R3 後先停止，由使用者提供證據進行下一輪架構審核。
6. Agent 活動量、通過測試的數量、報告檔案數量不代表成功；以可重跑行為和關鍵證據為準。

## 二、前輪已回報的基準

以下是第一輪回報，**仍需 R0 在 KA 實際環境確認，不可當成我方已執行的測試**。

| 項目 | 已回報 |
|---|---|
| P0／P0-U／M0／M1 | 調查與測試基礎完成，Gate 全部 BLOCKED；DS 未替換 |
| DS 覆蓋 | 170/170 欄位；A1／B53／C93／D0／E23 |
| Corpus | 12 份合成文件，另有 1 份 MCP 合約樣本 |
| 針對性測試 | 50 項，49 PASS、1 FAIL |
| 原始碼還原 | 1247/1247 檔，361 個產品檔與還原點一致，Git HEAD 未變 |
| MAIN | docling-core 2.105.0、DocLang 0.8.1 |
| PARSER | docling-slim 2.137.0、Core 2.101.1、DocLang 0.7.3 |
| 候選 Core | 2.106.0 未實測，據前輪回報涉及 DocLang 0.9 |
| 重要缺口 | Windows DCLX 圖片 URI／描述、Office 精確證據、self_ref 位移、未知 XML、依賴 extras |
| 其他缺口 | PPTX 固定 projection digest 一項失敗；部分無 cached value 的 Excel 公式未進既有 DS |
| 未完成 | 完整 hash lock、60 份代表文件人工審查、正式 DB/Index 恢復、Shadow RAG |

本地既有重跑入口：

~~~powershell
python -X utf8 scripts/ka_dmm_verify.py
~~~

已回報 exit code 3 表示遷移 Gate 阻擋，exit code 1 表示 runner 步驟失敗。重跑時需核對當前腳本定義與子測試明細。不可為取得 exit 0 而降低 Gate 或更改既有 assertion。

本輪目標有三個：**（一）C93/E23 到底是否需要 DS 2.0？（二）哪些來源保真缺口是真正阻擋？（三）能否跟進 Docling 官方 Release 而不再製造廣泛耦合？**

## 三、嚴格授權及風險邊界

可以：本地原始碼閱讀、測試基準重跑、隔離 sandbox/venv 的 API probe、合成文件、回歸測試、最小 Anchor/Serializer 原型、受控版本矩陣及 ADR。

不可以：修改正式 DS Schema 或業務流程、正式 Review/Effective/Viewer 入口、正式 DB/Index、Embedding Model、Chunk Policy、Reranker、部署設定、正式依賴 lock；不可清理無關模組、覆蓋使用者未提交的工作、修改上游安裝目錄、讀取秘密或未經授權對外連線。若需安裝候選套件，必須在**隔離環境、獲授權的網路或預先核准的套件快取**中完成。

已存在的 Python socket 攔截和 offline flags，**沒有 OS 層隔離保證**。須在報告區分「設定了禁網意圖」、「實際阻擋驗證」和「OS 層隔離」，不得誇稱。

任何需要變更產品的修復，先提出可核准 WorkItem，不可在本輪直接改正式路徑。

## 四、執行順序與批次 Gate

| WorkItem | 准入條件 | 產物 | 停止點 |
|---|---|---|---|
| R0：Baseline Recheck | 原專案與報告可讀 | 重跑 log、環境／Commit／SHA、已知失敗分析 | 基準未重現時 BLOCKED |
| P0-R1：DS 替代性 | R0 已完成 | 170 欄位新分類、C93/E23 去向、最小擴充 Schema | 不實作 M2 |
| P0-R2：文件保真 | R0 已完成，已有 R1 的證據群組定義 | DCLX、Office、Anchor、PPTX Red Test 證據 | 不修改正式 Reader/Writer |
| P0-R3：官方升級可行性 | R0 與依賴環境凍結 | 版本相容矩陣、Viewer 相容、U1 邊界 ADR | 不升級正式套件 |

R2 和 R3 的隔離探測可並行，但各自需完成自身驗收；R1 的欄位群組和證據類型是 R2 最終裁決的輸入。

### R0：重建不可變測試基準

1. 核對 KA 原專案 Git HEAD、工作樹、源文件 digest、P0/M0/M1 證據、執行的 venv/容器和已安裝套件。
2. 重跑既有驗證命令，保存全部 step、stdout/stderr、exit code、各個測試的 PASS/FAIL/SKIP、實際檔案產物。
3. 為既有 PPTX projection digest 失敗建立 Baseline Defect ID，保留輸入、預期與實際 digest、執行環境、可能序列化差異。**不得改 Golden 讓紅燈消失**。
4. 為缺 cached value 的 Excel formula 建立 Known Gap，說明舊 DS 輸出未必是正確事實。
5. 保留回退與工作樹證據，不修改現有產品程式。

**Gate R0**：基準可重跑且每一項與先前回報差異都能解釋。否則 R0 BLOCKED。

交付：R0_baseline_recheck.md，附完整原始 log 路徑和不可變 Fixture hash。

## 五、P0-R1：170 欄位責任重新裁決

**核心問題：93 個 C 是真正必要的 KA Extension，還是重造 Docling 的 Page/Text/Table/Relation？**

保留原始 A1、B53、C93、D0、E23，不覆寫歷史分類。另新增責任分類：

1. DOC_CONTENT：通用文字、Page、Heading、List、Table、Picture、Relations、Reading Order。
2. SOURCE_PROVENANCE：bbox、page/slide/worksheet locator、parse recipe、source SHA。
3. OFFICE_NATIVE_EVIDENCE：XLSX formula／cached value／named range／cell/range、PPTX shape／chart series／workbook。
4. KA_GOVERNANCE：Review、Revision、AI 補充、Approval、Effective、Lineage。
5. DERIVED_PROJECTION：Chunk、Embedding Payload、Index、Document Map、Viewer Projection。
6. UNDECIDED：需可重跑資料決定的混合或未知語意。

每一欄需有下列資訊：

~~~text
field_id,original_class,responsibility_group,current_consumers,
source_of_truth,proposed_owner,native_docling_api_or_path,
extension_if_any,fixture_id,test_result,evidence_path,
decision,blocker,reviewer
~~~

新決策值僅限 NATIVE、KA_GOVERNANCE、KA_NATIVE_EVIDENCE、DERIVED、DEPRECATE、BLOCKED。原生支援可由多個 Docling 原生欄位組合，不必一對一，但必須有 API 和 Fixture 證據；不得用「方便接線」當 Extension 必要性的理由。

每個責任群組至少建立一個不經 DS 的小型探測：從原始文件或 Docling Core 載入 → 取得相關資訊 → DoclingDocument JSON 保存與重載 → 驗證來源與 Extension。嚴禁新的通用 PageContent/ContentBlock/TableCell 文件樹。

**Gate R1**：

- 170/170 欄位逐項具新決策、來源、消費者、Owner、證據或確切 Blocker。
- C93 按責任群組收斂，不能直接轉成 93 個自訂 Schema 欄位。
- E23 全部得到具體處置，包括未解決者的真實阻擋原因，不得以「待確認」批次結案。
- 產出最小 Extension Contract，並證明不構成 DS 2.0。
- 若關鍵 E 未解決，**不允許轉入 M2**，即使 R1 的盤點工作已完成。

交付：R1_field_decisions.csv、R1_responsibility_groups.md、R1_extension_minimal_contract.md、R1_gate_report.md。


### R1 的逐欄裁決規則與 DS 2.0 防線

C93 並不等於一定需要新增 93 個自訂 Extension 欄位；A1 也不代表 Docling 只原生支援一個能力。須核實分類方法是否僅允許一對一映射，而 Docling 是否能透過其原生節點、關係與 API 組合提供相同語意。

對所有 170 欄逐一檢核：原始來源、現有使用者與引用處、Docling 原生 API 或衍生方式、真實 fixture、序列化與重載後的差異、需新增 Extension 的原因、失效時對 KA 的影響和人工待決事項。保留原 A/B/C/D/E 分類，新增責任群組與裁決，不覆寫原報告。

判斷表：

| 判斷點 | 需要的證據 | 禁止的捷徑 |
|---|---|---|
| Docling 是否已可表達 | 指定 Core 版本、API、正反 fixture | 查到名稱就說已支援 |
| 可否以原生結構組合取得 | 實際讀寫與來源回溯 | 找不到同名欄位就造新欄位 |
| 是否屬於 Office Native Evidence | 原始 XLSX/PPTX 儲存格或 series 真實資料 | 只留顯示文字或圖像 |
| 是否屬於 KA Domain Governance | Review、Revision、Approval、Policy、Lineage 的契約 | 全部塞入 DocLang XML |
| 是否只是衍生投影 | 從內容母本和修訂重建 | 把 Chunk 或 Viewer 輸出當第二份母本 |
| 是否真的必須 Extension | 最小反例、失敗測試、原生能力缺口 | 複製一整套 Page/Block/Table/Relation |

**C93 要按責任群組收斂，E23 必須逐項有具體且可查證的去向**。未解決的關鍵 E 可標 BLOCKED，但不得以籠統待確認或直接開工新 Schema 取代決策。

本輪所稱最小 Extension 僅允許 KA 的 Office 原生證據、來源補充、治理／Anchor 關聯，不得重新定義通用文件的 PageContent、ContentBlock、TableCell、Relation 全樹。不可以用不同名稱複製 DS；如方案仍需要完整第二套文件樹，R1 架構 Gate 直接 BLOCKED。


## 六、P0-R2：DCLX、Office 與 Anchor 保真

### R2-A：Windows DCLX 圖片 URI 與描述丟失

在兩個已安裝 Core 版本各建立可重現案例：Windows 反斜線路徑、相對與絕對 URI、空白與 Unicode、缺資產、不合法 URI。依序比較官方 DCLX Writer → Reader、原始封裝、僅用於診斷的 URI 正規化副本。

逐一比對圖片 bytes/hash、bbox、caption、description、relationships、assets/pages、未知 XML；**「圖片可見但描述消失」必須判失真**。原件不可覆寫。

如需 workaround，僅提出隔離、版本限定、可停用、有移除 Gate 的 POC。產生公開 Issue **草稿**，移除所有公司與本機特定資料；本輪不得自行向官方 Repo 發 Issue/PR。

### R2-B：Office 精確證據 Truth Table

**原始 Office 文件是 Truth Source**，舊 DS 僅用來比對既有行為。

| 格式 | 必須測試 | 不可接受 |
|---|---|---|
| XLSX | Formula、cached/non-cached value、worksheet、cell/range、named range、merged cells | 無快取公式被當成無公式、範圍或 worksheet 錯誤 |
| PPTX | Slide、Shape、Chart Series 的 category/value、Embedded Workbook、圖片關聯 | 僅剩圖表圖片／文字，無法精確引用 |
| PDF | Physical Page、bbox、table span、Reading Order、caption | 錯頁、錯表、caption 關係消失 |
| DOCX/HTML/MD | Heading、List、Table、Image、links、inline relations | 結構遺失卻無告警 |
| DCLX | Assets、Pages、Unknown XML、description、source references | 未知節點被靜默丟棄、推論描述當 Verified Fact |

所有失真都需可重跑、可定位、可區分上游能力缺口與 KA Adapter 問題，不得把原 DS 既有缺陷視為正確結果。

### R2-C：Stable Anchor 原型

必測：原文件前置新增節點造成 self_ref/XPath 位移；修改 caption、重複文字、兩個相似表格、跨 Parser 版本、刪除節點、修改來源版本、兩個可能的 remap 目標。

區分版本綁定 Evidence ID 與可重新定位的 Logical Anchor。不確定時保留原證據，標記人工審核或拒絕採用；**錯誤確證容忍度 0**。

### R2-D：既有 PPTX Digest 紅燈

在隔離環境檢查排序、決定性、Fixture 漂移、版本差異、產品投影錯誤。只提交歸因、測試與建議修復方案，不更新 Golden 或擅自修產品碼。

**Gate R2**：DCLX、Office、Anchor、PPTX 均有正反測試、真實來源、差異結果及未解決缺口；關鍵資訊失真則保持 BLOCKED。不得宣稱完成無損往返。

交付：R2_dclx_windows_uri_repro.md、R2_dclx_fidelity_diff.json、R2_office_truth_table.csv、R2_anchor_remap_cases.json、R2_pptx_baseline_defect.md、R2_gate_report.md。


### R2 的明確測試矩陣與失敗處置

每個 fixture 都須記錄 Source SHA、版本與環境、測試命令、Truth Source、預期值、實際值、差異、錯誤分類、證據路徑。差異需分類 UPSTREAM、KA_ADAPTER、MISSING_SOURCE、BASELINE_BUG、UNRESOLVED、NOT_TESTED，不得自動推定都是 Docling 缺陷。

| 主題 | 最低正反案例 | 不可接受的退化 |
|---|---|---|
| Windows DCLX | 相對/絕對路徑、反斜線、Unicode、空白、缺檔、非法 URI、官方原封裝與診斷副本 | 圖片可讀但 caption、description、bbox、relations 或 assets/pages 缺失 |
| XLSX | 有/無 cached value 之 formula、named range、worksheet、cell/range、merged cell | 公式存在卻被記為空白、0 或無公式 |
| PPTX | slide、shape ID、chart series category/value、embedded workbook、圖片 rels | 圖表只剩圖片或標題，無法精確引用 |
| PDF | page/bbox、reading order、跨頁 table、span、caption | 錯頁、錯表、錯引用 |
| DOCX/HTML/MD | heading、list、inline link、table、image 關係 | 轉換遺失結構而無告警 |
| Anchor | 前置插節點、重複文字、相似表、caption 改動、刪節點、Parser 升版、來源改版、二義性 | self_ref/XPath 位移後仍錯認成正確來源 |
| Unknown XML | 原件保留、可顯示/不可解析、有效內容採用政策、告警 | 靜默丟棄或未審核當 Verified Fact |
| 既有 PPTX Digest 失敗 | 輸入 SHA、Expected/Actual、序列化順序及決定性分析 | 改 Golden 或刪 assertion 製造全綠 |

DCLX 的 Windows URI workaround 僅允許在隔離原型測試，必須限定版本、可停用、附移除條件。要形成**已去識別的官方 Issue 草稿**，但禁止自動向公開上游送出。

Anchor 設計區分版本綁定的 Evidence ID 和可 remap 的 Logical Anchor；若有兩個合理候選或 confidence 不足，保留待審查／拒絕自動採用。**錯誤來源對應容忍度為零**。

12 份合成文件與 MCP 合約樣本僅提供初步測試基準。未完成 60 份代表性 Corpus、人工審查和 Shadow RAG 前，R2 不得宣稱已全面驗收，不可把原本 DS 的缺漏當 Golden Truth。


## 七、P0-R3：官方 Docling 升級與鬆耦合

建立可重現且**分離**的 Profile：

- MAIN_BASELINE：Core 2.105.0／DocLang 0.8.1。
- PARSER_BASELINE：docling-slim 2.137.0／Core 2.101.1／DocLang 0.7.3。
- OFFICIAL_CANDIDATE：依官方 Release/PyPI 與 resolver 確認，隔離探測 Core 2.106.0 等候選，實際驗證對 DocLang 0.9 的依賴。
- VIEWER_COMPATIBILITY：檢查 Viewer 宣告的 0.7／0.8 與候選 DocLang 版本的真實相容性。

檢查 Python、OS、完整相依鎖定、wheel digest、Extras、package metadata、對應 Release/Tag。不得在正式環境執行 pip upgrade。

每個 Profile 驗證 API import/signature、DoclingDocument JSON、DocLang XML/DCLX、未知 XML、圖片／描述、Office Evidence、Anchor、HybridChunker、Markdown Parser。對 tree_sitter、marko 等缺依賴先核對官方當版 extras，再在隔離環境補齊。

必須區分舊檔新 Reader、新檔舊 Reader 和版本回退時的事件／資產恢復。已裝兩版 Core 的合成 JSON 雙向測試不代表所有格式、文件均可互通。

產出 **U1 Integration Boundary ADR**，但本輪不正式實作 U1。目標為 DoclingDocument 原生內容模型、集中不穩定上游 API、Office Evidence 與 KA Governance 旁掛，禁止建立 Docling→第二套 DS 的模型映射。

比較三種可行方案：保留現版、升官方正式版、版本限定的局部 workaround；需附風險、成本與退出條件。

**Gate R3**：

1. MAIN/PARSER 可重現。
2. 候選有實際執行證據，或清楚記錄阻擋原因，未測一律不標 PASS。
3. DocLang/DCLX/Viewer/Chunker 的 API 與版本差異已分類，關鍵保真失敗維持 BLOCKED。
4. Reader 相容、資料降版恢復策略明確；沒有恢復方法就不可授權正式升級。
5. U1 ADR 顯示官方版本升級原則上可透過整合邊界處理，沒有 DS 2.0。

交付：R3_runtime_profiles.json、R3_dependency_install_report.md、R3_compatibility_matrix.csv、R3_viewer_format_matrix.md、R3_upstream_upgrade_ADR.md、R3_gate_report.md。


### R3 的相容 Profile 和升級風險裁決

| Profile | 實測目標 |
|---|---|
| MAIN：Core 2.105.0／DocLang 0.8.1 | 原環境版本鎖、API、DocLang/DCLX/JSON 行為 |
| PARSER：slim 2.137.0／Core 2.101.1／DocLang 0.7.3 | 不同解析路徑、Markdown marko 缺口 |
| CANDIDATE：官方已發布 Core 2.106.0 等候選及實際 DocLang resolver | 安裝、DocLang 0.9 依賴、Schema、Chunk、Evidence |
| VIEWER：實際既有版本與 DocLang 0.7/0.8/0.9 | 完整／部分支援、拒絕模式、圖片與描述保真 |
| ROLLBACK：舊 Reader 及新增資料 | 降版讀取、原始資產與審核事件恢復 |

Core 2.106.0 的安裝相容性與 DocLang 0.9 要求必須以候選環境實測，不可因公開版本公告而宣稱 PASS；Viewer 既有列 0.7/0.8 不代表 0.9 可用。主 Core 版本與解析器 Core 版本不可混為一個套件組合。

對缺少 tree_sitter 的 HybridChunker、缺少 marko 的 Markdown Parser，應核對相應版本官方 Extras 與安裝限制，在獨立測試環境安裝驗證；可補齊的依賴視為環境缺口，不應直接結論為核心架構問題。不要升級正式環境的 lock。

**U1 整合邊界候選**：集中 Docling Parser / Converter、DoclingDocument JSON、DocLang / DCLX Writer/Reader、Capability Probe 與版本專用相容處理。業務流程可直接使用經審查的 DoclingDocument 官方型別，但不該大量散落 private API。不為消除每個 import 再造一套內容樹。

對比三種升版策略：維持已驗證版本、導入官方正式版、有限期限的相容補丁。優先使用官方公開 API／Extension，之後才考慮局部 workaround，私有 Fork 必須另案核准且不是預設。

**重要**：新版能讀舊版，不代表舊版能讀新版寫入內容。若新 Schema 不能降版，必須保留原始文件與修訂事件，設計復原點和可重播策略。這輪只形成 ADR，不准切換正式版本、Reader、Viewer 或 Index。


## 八、統一 Gate 定義與報告格式

狀態：PASS、CONDITIONAL、BLOCKED、FAIL、NOT_TESTED。**CONDITIONAL 不表示自動准許進 M2**。不得以檔案數、工作量、Pass 數量或測試腳本退出碼取代內容保真與架構 Gate。

每個 WorkItem 報告必須包含：

~~~text
WorkItem：R0 / P0-R1 / P0-R2 / P0-R3
狀態：
Repo / Branch / Commit：
執行環境：MAIN / PARSER / CANDIDATE / ISOLATED
本批授權邊界、實際修改檔案：
Docling / Core / DocLang / Viewer 版本與 lock：
Fixture ID、原始檔 SHA、Truth Source：
測試命令、Passed / Failed / Skipped：
原始 log、差異、可重跑證據路徑：
既有 1 項 PPTX 紅燈是否仍存在：
關鍵 Evidence／Office／Anchor／DCLX 保真差異：
官方缺陷與 Issue 草稿：
未解決風險、Blocker、未測項：
回退證據：
是否使用 DB／Index／秘密／外網：
Gate 判定、需人工核准項目：
下一輪可執行事項與前置條件：
~~~

建議在本地 KA Repo 內使用 docs/migrations/ka-dmm/P0-R/ 作為報告目錄，並保持指令與證據相互引用；**不要把這些內部產物推到本公開 GitHub**。

## 九、整體架構裁決與硬性停止點

完成 R1、R2、R3 後建立 P0-R_Architecture_Decision.md，必須回答：

1. 170 個 DS 欄位是否已有完整且具保真證據的去向？
2. C93／E23 收斂後，是否只需 KA 自有 Evidence／Governance 而非 DS 2.0？
3. DCLX Windows、Office、Anchor、Unknown XML、PPTX 的核心缺口是否仍阻止 M2？
4. 哪個 Docling 版本組合可進入下一輪隔離 Shadow Path？新版本／Viewer 有哪些真實風險？
5. M2 的准入條件、回退方案、需要人工核准的未解決項是哪些？

**交付上述決策與三份 R Gate 報告後立即停止。不得自行開始 M2、M3、DS 刪除、正式產品重構、Viewer 回寫、DB 或 Index 遷移。**

本輪成功的定義是取得**足以批准或否決 M2 的可重跑證據**，而不是宣稱已淘汰 DS 或已完成 RAG 遷移。


## 十、完整交付證據清單與目錄

這些路徑均以**本地 Knowledge Agent Repository** 為根目錄，不得自動推送至公開交接 Repo。依現有 Repo 結構允許調整，但結果報告需給出實際相對路徑與重跑命令：

    docs/migrations/ka-dmm/P0-R/
      R0_baseline_recheck.md
      R1_field_decisions.csv
      R1_responsibility_groups.md
      R1_extension_minimal_contract.md
      R1_gate_report.md
      R2_dclx_windows_uri_repro.md
      R2_dclx_fidelity_diff.json
      R2_office_truth_table.csv
      R2_anchor_remap_cases.json
      R2_pptx_baseline_defect.md
      R2_gate_report.md
      R3_runtime_profiles.json
      R3_dependency_install_report.md
      R3_compatibility_matrix.csv
      R3_viewer_format_matrix.md
      R3_upstream_upgrade_ADR.md
      R3_gate_report.md
      P0-R_Architecture_Decision.md

每一項測試至少保存：
- WorkItem、執行指引版本與公開 Commit、KA 本地 Commit/dirty-tree 狀態。
- Python、OS、Docling/Core/DocLang、Viewer 版本與已驗證 lock、Fixture ID 和 SHA。
- 原始 Truth Source、預期結果、實際結果、差異、錯誤分類、完整 log。
- Passed/Failed/Skipped，特別標明既有 PPTX projection digest 紅燈有沒有被保留。
- 是否連線、存取秘密、變更正式 DB/Index、對本地工作樹造成修改。
- 測試隔離、可回退狀態、剩餘風險、Gate 判定與人工核准事項。

公開工作摘要只可在經使用者明確核准後提交；即使是測試報告，也不能擅自推送包含內部檔案路徑、公司文件、程式碼、秘密、真實 fixture 的內容。若沒有公開授權，Main Agent 向使用者提供可貼回 ChatGPT 的摘要即可。

## 十一、M2 准入的決策選項及硬性停止

最終 P0-R_Architecture_Decision.md 必須採取其中一項並附證據：

| 決策 | 條件 | 下一步 |
|---|---|---|
| APPROVE_M2_ISOLATED | 內容模型替代性與 Extension 邊界成立，保真風險已分級、可在 Shadow 隔離 | 僅建議另案授權 M2，不能自行執行 |
| BLOCK_M2_FIXTURES | 重要 Truth Source、C/E 欄位或人工審核仍不足 | 先補測試與來源證據 |
| BLOCK_M2_UPSTREAM | DCLX／DocLang／Office／Anchor 關鍵缺口無可用隔離解法 | 上游 repro、局部 POC、候選版本 |
| REVISE_ARCHITECTURE | 替代 DS 仍需建立第二套通用內容樹、或升版造成廣泛業務重寫 | 修改設計，不進 M2 |

R0／R1／R2／R3 都有獨立 Gate。若任一關鍵項 BLOCKED 或 FAIL，不得將平均通過率當作通行證。CONDITIONAL 也不是默許 M2 的授權。

**本輪執行終點**：交付三份 R Gate、R0 基準報告、P0-R_Architecture_Decision；立即停止，等使用者與 ChatGPT 審核並將下一輪授權**完整寫入公開 GitHub 新版指引**。未經新版本，不可開始 M2／M3、DS 刪除、Viewer 回寫、產品 DB/Index 更新、正式升級或部署。

**核心架構目標**：消除沒有必要的 DS 通用文件模型和反覆轉換，同時保留 Office 原生證據、KA 治理可信度、Anchor 正確性與長期跟進 Docling 官方發布版本的能力。

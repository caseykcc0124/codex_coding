# KA-DMM：下一輪執行指引（P0-R1、P0-R2、P0-R3）

> **此指引已由 [v1.1 完整版](./KA_DMM_P0_Blocker_Resolution_Execution_Guide_v1.1.md) 取代。請依 v1.1 執行；v1.0 僅留作歷史。**

> 文件版本：v1.0  
> 日期：2026-11-06  
> 主計畫：[KA-DMM Docling Native Migration v1.2](./KA_DMM_Docling_Native_Migration_Plan_v1.2.md)  
> 指令接收者：Coding Agent  
> 狀態：**待執行規格，非已驗收報告**  
> 工作模式：在原本 Knowledge Agent 專案內逐批執行，保留逐批 Gate。  
> 本輪授權：R0 基準確認、P0-R1 替代性裁決、P0-R2 保真與 Anchor 驗證、P0-R3 官方版本相容性。  
> **禁止直接進 M2、刪 DS、更新正式 DB/Index、修改正式服務、部署或公開內部資料。**

## 一、GitHub 交接契約

本公開 Repository（caseykcc0124/codex_coding）是 ChatGPT 與 Coding Agent 的**工作指引交接管道**。Coding Agent 從此處讀取此版指令，在**既有** Knowledge Agent Repository 執行。此公開 Repo 不是 KA 產品程式、正式文件、實際測試資料或秘密的保存區。

1. 先讀本文件，再讀連結的 v1.2 主計畫，以及 KA 本地已建立的 P0、P0-U、M0、M1 報告與 README。主計畫的安全禁止規則優先。
2. 本輪使用文件版本 v1.0，記錄取得的公開指令 Commit SHA。往後文件有更新，不可默默更換執行基準，需明確版本決策。
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

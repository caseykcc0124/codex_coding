# KA-DMM E10：Production Acceptance 與受控 Cutover 執行指令

> **最新 E10 執行命令，2026-11-07。** 使用者已要求「開始進行 E10 的工作」，因此 Coding Agent Main 應**現在立即開始全部可合法執行的 E10 準備、隔離驗收、切換封裝與授權交付工作**，不再等待新一份開工指令。
>
> **授權邊界**：本次「開始 E10」授權的是本地／隔離／既有允許的 staging 之 E10.1 準備及預演，**不是**對正式 Production 的 DB／Index／服務／Alias／寫入／資料備份／流量、正式資料處理、正式共同服務或不可逆移除的具體授權。實際操作這些正式資源之前，須依 [Autonomous Mission v2.0 第 10 節](./KA_DMM_Autonomous_End_to_End_DS_Replacement_Mission_v2.0.md) 提交**一次性、精確、可審閱的 Cutover Authorization Packet**，取得使用者明確同意後才能執行 E10.2、E10.3。
>
> 核心實作仍在現有私有 Knowledge Agent 專案，不得另建新產品 Repo。公開 Repo 只用於發布去敏指令及單一狀態檔 [KA_DMM_STATUS_SYNC.md](../KA_DMM_STATUS_SYNC.md)，不得公開私有程式、模型、原件、公司測試資料、內部路徑、憑證或 logs。

## 0. 已完成工程基線，立即接續，不得重啟 E9

依 2026-11-07 20:23（台灣時間）的公開狀態，本次 E10 接續以下 **E9 已交付而不再重新開發** 的工程基線：

* `mission_state=ENGINEERING_COMPLETE`、`engineering_release_status=READY_FOR_RELEASE`、`active_stage=E9_COMPLETE_AWAITING_PRODUCTION_ACCEPTANCE`、`production_status=NOT_AUTHORIZED`。
* 凍結產品 Release Commit：`fb1aa0e6dc9da4fedcd285ea2471dff230f862ad`。本地正式使用前應核實其實際可審查來源、完整 SHA 與 Manifest，不得自動換版。
* 同一 RC 的本機整合 CI 22/22 PASS；原有 50 regression 為 49 PASS／1 個既有 PPTX 身份 digest FAIL；Chrome 10／page-cache 5 PASS；API98/PDF84 離線安裝和限定 PDF→Serving PASS；170 欄 native 責任為 161 bounded mappings／9 approved supersessions。
* 新業務入口／Index／Serving 的已測 DS import/loaded 為 0，歷史 DS Reader 僅隔離只讀。
* 最終私有程式包、獨立 wheel/model 依賴包、Release Manifest、四個必要 migrations、Canary／Rollback Runbook 及非作者完整性驗證已交付。
* 尚無正式真 corpus／live LLM RAG 品質、正式規模性能或共同服務新 host/正式部署的實測證據。既有 PPTX digest 身份失敗、深路徑、不可唯一映射的歷史 revision 必須受控處置，不能當作沒風險。

本段是公開去敏快照，Main 必須在原 KA Repo 讀取真正的 Release Commit／receipts／Bundle，**E9 的 tests、已知 FAIL、權限與安全界線不因 E10 而重置**。

## 1. 終局目標與不擴張政策

E10 的唯一產品目標是：在**取得正式授權後**，讓官方 DoclingDocument 為核心的 KA 正式流程接管現有服務，安全遷移必要資料與修訂事件，以受控順序切換 Review／Effective／API／Index／Viewer，完成新正式路徑的 DS 退役與觀察、回退驗證。**只有真的通過 Production Acceptance 與部署驗證，才能宣告 `PRODUCTION_COMPLETE`。**

本階段嚴禁擴充 E9 測試集合、新增研究工作包、追求任意 170 欄的虛構 parity、開新產品 Repo 或形成無止盡的新階段。E10 驗收**只用 Mission v2.0 既定 Production Cutover Gate 與 E9 已批准的產品品質契約**。正式環境特有的真實資料、服務健康、備份與 rollback 驗證是既定的 E10 門檻，不代表可以無限制再開發測試。

Main 必須主動調度 Sub Agents，完成可平行的 Readiness、Runbook、Shared Services、Migration／Rollback、Production Quality Evidence，自己整合並產出一次性授權請求。不應每步等待 ChatGPT 指令，也不把使用者變成報告傳遞者。

## 2. E10.1：現在立即自主執行的工作（只限已授權的非正式環境）

### A. Release Baseline 與安裝／依賴可重建性

1. 在原本 KA Repo 封存本輪 RC commit、source ZIP、獨立 wheel／14 sealed models、checksum sidecar、lock、Manifest、四個 migrations、Viewer 既有 126 assets 清冊、外部 file-preprocessor／CLI／共同服務的版本及依賴。
2. 在**已授權的隔離環境**執行 Runbook 的 verify-only 與必要的 clean install／restore dry-run，證明套件、模型、資產、source ZIP 身份吻合。不得把舊 RC source backup 認成最終 successor commit，也不得默認所有共同服務都包含在 source ZIP 中。
3. 確定部署配置的環境變數、遷移順序、feature flags、storage buckets、DB schema、Index alias 和版本 identity 有可審查清單；正式 secrets 不得進入 GitHub。
4. 禁止未授權直接讀寫 Production、取得新的公司憑證或讀取真實客戶資料；可對已授權 staging 做同構檢查，缺少 Production 權限則形成精確待授權清單。

### B. 正式資源、資料風險與依賴圖（文書／已授權隔離讀取）

用已有文件、已批准的部署描述與可合法存取的配置形成一張可操作的 Cutover Inventory，至少包含：
* 實際 API／Review／Effective／Viewer／Index Producer／Search／共同 preprocessor／模型 runtime、監控與回退端點；
* Database、索引、storage、事件帳本、Revision／Approval／Evidence 與資產保存的位置類型（公開去敏只寫代號）；
* old DS writer、DS readers、Legacy Migration Reader 的實際服務依賴，哪些是不能立即移除的隔離歷史橋接；
* Backup／restore 來源、完整性驗證方式、復原點與 RPO/RTO 要求，如未知標 UNKNOWN 待決，不得捏造；
* 進入 Canary 前的 Change Window、Operator、最低必要權限、回退負責人、拒絕條件與告警。

### C. Production Acceptance 的既定品質條件

準備**最小、固定**的正式驗收矩陣，僅含已承諾的：
1. Source／Evidence 正確與拒錯、ACL、Approval／Effective 一致，錯誤正向 citation=0；
2. 已核准代表性 corpus 的檢索 Recall@10／nDCG@10 與既定 M0 基準比較，原則不得退化超過 2 個百分點，關鍵問題 0 退化；若沒有真實 corpus／權限，記 `NOT_TESTED / INPUT_AUTHORIZATION_REQUIRED`，絕不能拿合成 embedding 冒充正式品質；
3. 共同服務及 Viewer／file-preprocessor 的實際健康、身份／ACL、來源 asset、真實重載與 API 路徑；
4. 歷史 Migration dry-run 的可唯一映射 Revision／Approval／Source 保真，未解歷史只讀隔離，不偽造 Verified；
5. 正式備份可恢復、雙讀／影子索引隔離、別名原子切換與恢復，以及已批准的效能／延遲／錯誤率與觀察閾值。

全部閾值須引用現有已批准 runbook／SLO；若缺少某項閾值，提交建議值供**正式切換授權包一次性核准**，不可假裝已有基準，也不自行增生測試。

### D. 可執行 Cutover Packet、Rollback Packet 與前置證據

在現有私有 KA Repo 完成可直接使用的、版本凍結的 Script／Runbook，形成以下序列及每步 Stop／Rollback 機制：

`G0 Preflight` → `G1 可恢復備份` → `G2 唯讀 Canary／Shadow` → `G3 限流正式寫入與 Revision Replay` → `G4 Shadow Index 驗證與 CAS Alias` → `G5 停止 DS writer` → `G6 觀察及受控退役`。

每步記錄：入口條件、使用命令／變更對象、實際環境、證據、零錯引與 ACL 門檻、期望結果、失敗回退及精確操作者；有無法恢復的 Revision／Approval／Source 證據、未授權存取、錯誤引用、錯誤 Index Alias 時必須**停止擴大並保留歷史事件**。

在正式授權前，以上僅允許**已授權隔離／staging dry-run**，不得在正式環境執行任何一步，包括以「備份」「Canary」「shadow」為名直接碰觸正式資源。

## 3. 單次正式 Cutover Authorization Packet

當 E10.1 的可自主完成項目已執行並驗證，Main 必須在根目錄唯一公共狀態檔發布一份**去敏但足以讓使用者決策**的 `E10_AUTHORIZATION_REQUEST`，同時完整私有附件留在 KA Repo。

只允許一次整合式授權請求，必須至少含：

* E10.1 Ready 或 NOT_READY、凍結 RC SHA、已驗證可恢復的隔離部署證據；
* 正式環境的抽象識別、涉及的服務／DB／Index／storage／事件類型；
* 需要的最低權限和資料／模型／真 corpus 存取，哪些是使用者尚未批准的具體資源；
* 明列預期正式操作：備份、只讀 Canary、影子索引、寫入切換、Alias 切換、DS 停寫、可能的 Schema／資料清理。**不同不可逆動作需分別被明確包含，不可用概括「開始 E10」替代**；
* 固定 Acceptance Gate、真實基準、觀察期、Change Window、Stop Threshold、Rollback 的可執行條件與責任人；
* 既有 PPTX digest FAIL、任意 legacy mapping 未解、Windows 深路徑與其他仍受限功能的影響和風險接受方式；
* 推薦是否先做唯讀 Canary、是否仍缺正式條件、是否可核准具體操作。使用者未批准的部分不可被視為通過。

**只有取得使用者明確的正式切換授權（具體操作和範圍）後，Main 才能執行 E10.2。** 如果正式條件或資源不足，保留 `ENGINEERING_COMPLETE / READY_FOR_RELEASE` 和 `E10_WAITING_FOR_AUTHORIZATION` 的真實事實，不得重新打開 E9。

## 4. E10.2：取得具體授權後才實際執行

1. 在核准的 Change Window，依批准範圍執行正式備份與恢復驗證、版本 inventory；未完成可恢復備份時禁止進入後續寫入切換。
2. 啟動受控**唯讀 Canary／Shadow**，看真實 corpus evidence、ACL、錯誤引用、query quality、Latency、共同服務健康；禁止無監控直接全量切流。
3. 已確認 Revision、Approval 及使用者增量事件可完整保存與回放後，依 runbook 逐級切換最小比例寫入和 Effective View，觀察到 Gate 成立才擴大。
4. 先 Shadow Index，確認相同 revision、來源身份與檢索品質，再透過已驗證的 CAS／原子 Alias 切換；保留舊路徑／索引可 rollback。
5. 確認全部真實 consumer 已離開舊 DS writer，才停寫 DS；舊資料不可唯一映射的部分保持隔離唯讀，不能強制轉為 Verified。
6. 只有在另行**明確批准不可逆資料／程式 Schema 清理**、正式備份可恢復且已過觀察期時，才真正刪除 DS 正式程式或 Schema；若未獲此授權，可完成可回退 Cutover，將最後清理列為後續唯一待核准動作，不能冒稱整體 Production Complete。

## 5. E10.3：正式觀察、恢復驗證與結案

使用正式環境既有觀察期／SLO 與約定窗口，核對：
* 正式 API／Review／Approval／Effective／Index／Retrieval／Viewer 真實資料一致，錯誤來源正向引用 0，ACL 不退化；
* Source／Asset／Revision／Governance 及新寫入事件未遺失，失敗能回到已證實的 Recovery Point；
* 正式 DS 新寫入已停止，正式新業務已不依賴 DS，未核准的歷史遺留仍有安全隔離；
* 新正式 Release Commit 與部署包 identity 一致，監控記錄可追溯，已知 PPTX／legacy 限制按批准條件處理。

只有真正完成上述正式證據與所有已授權的必要退役義務，才能狀態更新 `mission_state=COMPLETE`／`production_status=PRODUCTION_COMPLETE`。反之如實保持 PARTIAL／WAITING_FOR_AUTHORIZATION／ROLLBACK_PERFORMED，保留最終事件、證據、回退紀錄。

## 6. 不允許的行為與固定同步契約

* **不**重新打開 E9、不新增產品功能或多輪測試、不為每個小 Gate 找使用者、也不設未授權持續背景 daemon。
* **不**修改 GitHub 根目錄 [KA_DMM_STATUS_SYNC.md](../KA_DMM_STATUS_SYNC.md) 以外的公開進度文件。只有 Coding Agent Main 寫它，Sub 只匯報 Main。Main ACTIVE 時每 60 分鐘更新及重大 Gate 即時同步；E9 最終已完成的狀態繼續保存。
* 本次新 E10 指令已公開後，Main 應先把 `active_stage=E10_PRODUCTION_READINESS`、`current_work_item=E10.1 非正式環境準備／單次授權包`、`production_status=NOT_AUTHORIZED` 及下一個可交付成果寫入原檔，但只在實際開始 E10.1 時宣告 ACTIVE，不得冒稱正式部署或生產資料已處理。
* 如果缺正式連線／資料／權限，不要回報泛泛的 BLOCKED；先完成隔離環境和 Runbook 全部可做項目，再產生具體最小授權請求，**不得自行跨過授權邊界**。
* 本任務的終點是 **E10.1 Ready + 一份完整可核准的 Cutover Packet**，之後等待明確生產授權；取得核准後按上述固定序列完成 E10.2、E10.3。不能宣稱因為「開始 E10」就已經完成 Production Cutover。

**立即開始 E10.1，既有工具與授權範圍內自行完成所有工程準備與證據封裝，無須再請 ChatGPT 發新指令。**

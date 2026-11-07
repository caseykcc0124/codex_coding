# KA-DMM E9 Final Closure：最終工程收斂與發行驗收指令

> 指令性質：既有 [Autonomous Mission v2.0](./KA_DMM_Autonomous_End_to_End_DS_Replacement_Mission_v2.0.md) 之 E9 收尾執行細則，**不取代 v2.0 的架構、Definition of Done、E0 至 E9 自主授權或第 10 節正式環境授權邊界**。
>
> 指定執行者：現有 Knowledge Agent 專案的 Coding Agent Main，允許管理 Sub Agents。
>
> 固定指令入口：[KA_DMM_CURRENT_WORK.md](./KA_DMM_CURRENT_WORK.md)。
> 唯一公開去敏進度檔：[KA_DMM_STATUS_SYNC.md](../KA_DMM_STATUS_SYNC.md)。
>
> 本文只授權本地／隔離／已授權 Staging 的工程、測試與交付，不授權 Production Cutover、正式 DB／Index／流量變更、不可逆資料處置、額外權限或外網連線。

## 一、主旨及接續基準

本次目的為**一次收斂 E9 的 Release Blockers，完成可重現的產品與部署證據，交付真正可執行的 Release Candidate**。不要再以每個局部 Gate 為停工點，也不要重新建立專案、重寫已通過的 E0～E8，或把使用者當作 Main／Sub 之間的訊息轉送者。

2026-11-07 公開狀態參考基準（請先重新讀取 main 及本地 KA 實證，不得將此快照當成最新事實）：

* mission_state：ACTIVE；active_stage：E9_FINAL_VERIFICATION。
* stage_gate：FULL_SUITE_22_PASS / RELEASE_GAPS_REMAIN；engineering_release_status：NOT_READY。
* E0～E8 為各自限定範圍的 PASS，**不代表所有正式產品 Gate 已通過**。
* 第二輪 frozen-source 22 步 fresh-process 統一驗證全部 PASS，無必要 skips；第一輪 17 PASS／5 FAIL 及修復證據保留。
* Chrome UI 10 項、45 頁按需快取 5 項、隔離 PostgreSQL 48 migrations／26 checks、DS retirement 18 項已回報 PASS。
* 既有 50 項 Regression：49 PASS、1 個已知 PPTX digest FAIL，Golden 未改。
* 目前未閉合：最終 Feature Commits／Manifest／Release Gates；PDF clean offline rebuild 尚缺 18 項套件；170 欄矩陣仍有 gaps；真 corpus／live LLM 品質及實際 CI job 證據未完備。
* E10 正式切換仍為 NOT_AUTHORIZED；requires_user_action=NO。

**不要把公開狀態當成工程證據**。Main 必須查閱原有 KA 的程式、Commits、Runner、receipts、失敗原始證據、依賴及可重跑測試，先確認差異，再繼續。

## 二、執行方式與統一決策規則

1. Main 自主管理依賴、指派互不衝突的工作給 Sub，主動輪詢、收集成果、整合 Commit 與測試，保持單一 Release Candidate。Sub 完成不代表總任務完成。
2. 對每一個 Release Gap 建立**具體可關閉項目**：受影響能力、可重現失敗／缺少證據、根因、最小修復、驗收命令、PASS 判準、Commit／receipt、是否屬於外部授權。禁止無限研究與不斷新增平行大專案。
3. 發現失敗時先重現，再處理 root cause、正反測試、完整回歸及版本雜湊；保留第一次失敗，不改 Golden、不降 assertion、不把未測項目寫成 PASS。
4. 只有 v2.0 第 10 節的真實授權點才能請使用者決策，其餘持續完成無依賴工作。不能因一項離線套件缺失就停止整輪工程。

## 三、六個必須收斂的交付流

### A. Feature Commits、凍結候選版與 Manifest

* 盤點目前 KA 工作樹、未提交改動、本地 feature branches、既有 22 步 receipts 與原始測試資料。保留其他人的 dirty work。
* 用可審查、可 revert 的 Commits 落實功能修復，Main 合併後建立**單一 Release Candidate Commit**，記錄完整 SHA；不可僅寫文件聲稱提交完成。
* Manifest 至少記錄：Source／Parser／Docling／Schema 版本、原始檔及資產 hash、Extension Schema、治理版本、Index Recipe、依賴 lock／wheelhouse、Feature Flags、Migration Tool 版本、Runner 與測試輸入 hash。
* 基於最終凍結 Commit、固定 inputs、clean 或明確列示的隔離 runtime 再跑完整 22 步，檢查 source_changed=false、inputs_changed=false、無非預期 skips，統一與子 receipt 的 SHA256 可核對。變更 Commit 後不可沿用舊測試結果當作新 Commit 的 PASS。

### B. 封存 PDF 之全離線 clean rebuild

* 將 84 個來源套件、已確認的 wheel 與**仍缺的 18 個**建立逐項 Missing Dependency Matrix：套件／版本、transitive dependency、Python ABI、OS／平台、hash、必要性、可用的已授權本機來源、不能重建的確切原因。
* 優先盤點本地已授權 wheelhouse、cache、env；區分真正必備 runtime 依賴和非必要 extras。不得任意刪除必要依賴以偽造通過。
* 在**完全離線且乾淨**的驗證環境實際安裝與重建，重驗 PDF submit → Review → Approval → Index → Serving、模型重載完整性和 guard，保存命令、exit code、package lock 與 receipt。
* 禁止擅自外網下載、重包不明 wheel、取得新憑證或放寬網路 guard。若 18 項確屬無法在既有授權下取得，標為 EXTERNAL_DEPENDENCY_NOT_AVAILABLE，完成全部其他工作，再提交**最小、明確的套件來源授權需求**。不可宣稱全離線 Gate PASS。

### C. 實際 CI、Regression 與失敗注入

* 將 22 步統一 Runner、各來源 Truth／Citation、拒答、tamper、stale、ACL、版本檢查、Index、Viewer、恢復及升降版 probes 接入現有 CI，**實際在已授權環境啟動至少一次 CI job**，提供 run ID／Commit SHA／exit code／receipts。只有 workflow YAML 而未執行者為 NOT_TESTED。
* 原 50 項必須與基準逐項比較，保留 49 PASS／1 已知 PPTX FAIL 及 Golden hash；任何新增 FAIL 必須定位、自主修復。
* 確認 source-citation 0 misbinding 的**實測範圍**，unresolved 明確 fail closed，不以模擬 embedding 代替真實 RAG 品質結果。
* 保存故障注入的前後差異、交易回退、崩潰恢復、冪等與事故後資料驗證；不可只引用測試數量。

### D. 170 欄產品責任及 DS 依賴退休

* 170 欄矩陣必須從 AUDIT_COMPLETE_WITH_GAPS 落到**必要功能逐欄 owner／consumer／implementation／test／commit 或已批准 deprecation 的證據**。不必對已裁定無產品需求的欄位憑空製造 parity，但不能把尚未驗證的必需欄位當作已完成。
* 優先封閉 Office 公式／圖表／來源定位、精確引用、Review／Effective、Index／Retrieval／Viewer、歷史採用與重播等產品必需項目。
* 任何來源不確定、版本失配或錯誤綁定均保留 UNRESOLVED／REJECTED，不得偽造 Verified Evidence。
* 追查正式新入口、API、Indexer、Serving、Viewer 是否存在 DS import／runtime fallback；需為零。舊 DS Migration Reader 可限縮隔離讀舊資料，須有廢止與回退邊界。提供實際 Dependency Report 和 guard 結果。

### E. 真正端到端、歷史恢復與 UI

* 在本地隔離或已授權 Staging 重驗：Source → 官方 DoclingDocument → Canonical Bundle → Draft／Review → Approval／Effective → Chunk／Index → Retrieval／Groundedness → Original／Effective Viewer。
* 覆蓋 PDF、DOCX、PPTX、XLSX、DCLX、HTML／MD／TXT、外部 ZIP／MCP 等現有**必需來源**；不足的格式誠實標註子範圍及未驗證條件。
* 保留資料與引文的 SHA、revision、adoption、作者／時間、ACL／stale／tamper，驗證隔離 PostgreSQL migration、rollback、crash recovery 與重試；圖片、文字、表格同 transaction。
* 重驗 Chrome 的混批編輯、同版 chunk、HTML 匯出、核准與 Serving 一致性、45 頁懶載入；Windows 長路徑既有失敗應有明確支援上限或可重現修復，不得稱全面相容。
* 真實 corpus、live LLM／retrieval quality、Production-scale 效能若未具備授權資料或環境，獨立標 NOT_TESTED 及精確風險，不可由 stub 或合成測試推論正式品質。

### F. Release Candidate 包與逐項 Gate 判定

依 Mission v2.0 第 8 節在**原本 KA Repository**交付實際程式與以下可重跑證據：Release Commit、Manifest、Architecture／Schema、Supported Source Fidelity、Evidence／Anchor Matrix、Review／Effective、Migration／Rollback、Chunk／Index／Groundedness、Viewer／DCLX、Upstream Compatibility、DS Retirement、Security／Failure Injection、完整 Gate Report、RC Checklist、Production Canary／Rollback Runbook，以及有界的 Open Issues。

每個 Gate 必須標示 PASS／FAIL／NOT_TESTED／BLOCKED_EXTERNAL、適用環境、執行 Commit、Runner、收據與風險；不可用公開簡報取代工程證據，也不可在沒有實際 CI 或 clean build 時寫「全驗收」。

## 四、嚴格完成條件

只有 Mission v2.0 的 Engineering Definition of Done **全部**成立才允許將工程標為 ENGINEERING_COMPLETE，包含必需來源、Review、索引檢索、Viewer、歷史遷移／Rollback、正式新路徑無 DS、完整可重跑 Regression／CI、可重建 Release Bundle 與安全 Cutover Runbook。

有未封閉 Release-critical Gap 時維持 engineering_release_status=NOT_READY，stage_gate 明列具體剩餘項。若所有工程及可授權驗收已完成、僅 E10 正式環境操作待許可，請提供 ENGINEERING_COMPLETE／READY_FOR_RELEASE 的真實證據與正式授權清單；**不可自動部署**。

沒有權限、資料、合規套件或網路等外部條件時，不要偽造完成；但要自主完成其餘可執行工作，交付已完成的 RC、缺口矩陣、外部授權最小清單，準確標示何者阻止 Engineering Complete、何者只影響 Production Cutover。

## 五、交接及每 60 分鐘去敏同步

* Main 在執行前讀取 [KA_DMM_STATUS_SYNC.md](../KA_DMM_STATUS_SYNC.md) 的最新版本與 GitHub SHA，並使用唯一同步檔，不建立第二份。
* ACTIVE 時至少每 60 分鐘更新一次；重要 Gate、錯誤恢復、阻擋與 Engineering Complete 即時更新。同步檔由**Coding Agent Main** 透過 SHA 條件更新，Sub 不直接修改。
* 必須提供 updated_at_utc、last_progress_at_utc、mission_state、active_stage、E0～E10、stage_gate、engineering_release_status、可用能力、Passed／Failed／Skipped（附來源／引用結果的驗證範圍）、Blockers、自主修復、next_action 與 requires_user_action。遇到未更新或同步失敗不得宣稱已同步。
* 只上傳去敏摘要。私有 KA 原始碼、公司文件、真實原件、內部測試日誌、路徑、憑證和秘密不得公開。
* Main 不需等 ChatGPT 再發下一輪指令；**直接完成 E9 Final Closure**，最後一次性提交可執行 Release Candidate 與真實判定。

## 六、最終給使用者的交付格式

最後總回報必須包括：工程狀態（ENGINEERING_COMPLETE／READY_FOR_RELEASE／NOT_READY）、完整 Release Commit SHA、可執行功能、各 Gate 與測試數及證據、來源引用可信度、DS 退休結果、實際 CI／離線 rebuild 狀態、未閉合風險、部署與回退程序、是否真需使用者授權。清楚區分「已實作」「已實測」「僅規劃」「只在隔離環境」「正式環境未動」。

**現在開始執行，勿等待逐項人工回覆；正式 E10 Production Cutover 仍需另外授權。**

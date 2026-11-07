# 09｜自由模式、混合事件與故障注入驗證計畫

## 9.1 自由模式是真正的長生命週期 Runtime

沒有預設結束劇情。Runtime 即使在全部 Tickets 完成時仍處於 `IDLE / READY_FOR_EVENTS`。使用者可以在任何時間注入合法新 Spec、PPA Target、RTL Change、Sim Failure；也可同時對不同 IP 注入事件。Web 不能只靠事先錄製動畫；自由模式需要操作正式 Gateway 或獨立 Mock Namespace 的同一個 Runtime Interface。

## 9.2 自由測試測項

- F01：空白 Workspace 注入 `SPEC.CHANGE_REQUESTED`，依路由至 Spec Owner。執行完成後保留 Ticket 資料。
- F02：同 IP 已 Release 後注入新 Spec，建立新 Revision / Run，不能覆寫上次 Release。
- F03：當 RTL Arena 正在執行，再注入一個更高優先級的 Spec Change。舊 Candidate 標示 superseded，新 Baseline 開始。
- F04：Verification 正等待 EDA 時，注入 PPA Target Change。PPA Ticket 自行啟動，不能在等待 Sim 時卡住所有工作。
- F05：Env Profile 中途失效，Job 暫停，Environment Owner 修復，Job 不用人類重送。
- F06：A 與 B IP 同時運作，A 死循環被 Watchdog Stop，B 完成 Release。
- F07：閉環持續發生同 Failure Signature，零有效進展，第三次停止，不無限開 Worker／下載框架。
- F08：RTL Owner 嘗試建立無關的 Framework 或增加 Max Budget，拒絕並記錄，不影響可繼續的合法設計任務。
- F09：錯誤 Formal Property 造成矛盾，Formal Owner 能提出證據與 Spec Clarification，不自行削弱 Property 以過 Gate。
- F10：User Harness 退出，Backend 重啟，Notification Service 暫時失效，Ticket 與未讀通知都保存。
- F11：從 Codex 提交 Spec，再用 Claude Code 查詢同一 Event/Result，Identity 與权限正確。
- F12：人工提交不具授權的強制發布要求，Gateway 擋下；模型文字「已獲批准」不得越權。

## 9.3 測量自主任務是否真正有效

每個場景都收集：有效工程進展次數、失敗簽章重複率、迭代／費用上限、完整 Evidence Gate、人類中途介入數、Owner 責任分派、總時間、停止原因。

特別注意：成功的 `BLOCKED` 是合理狀態，只要其原因與證據充分。無限執行直到資源耗盡，以及偷改條件取得假成功，才是失敗的 Runtime。

## 9.4 負面案例的停止精度

需能區分 `NO_PROGRESS`, `BUDGET_LIMIT`, `SCOPE_VIOLATION`, `UNTRUSTED_EVENT`, `STALE_EVIDENCE`, `ENV_MISMATCH`, `HUMAN_CLARIFICATION_REQUIRED`, `MODEL_UNAVAILABLE`, `EDA_INFRA_FAILURE`。每個停止原因要有不同後續處理，不能一律送人類問「下一步怎麼辦」。

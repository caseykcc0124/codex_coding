# 02｜Super Agent Runtime 與事件閉環協定

## 2.1 事件作為第一級資料，非單純 Log

Event Envelope v1 詳見 `contracts/event.schema.json`。必要欄位：`event_id`, `schema_version`, `type`, `occurred_at`, `source`, `principal_id`, `project_id`, `ip_id`, `trace_id`, `correlation_id`, `causation_id`, `idempotency_key`, `payload`, `expected_revision`。Producer 真實身份須在 Gateway 端由憑證／程序身分建立，不能相信 payload 自稱的 `principal_id`。

### 建議正式 Event Family

- `SPEC.CHANGE_REQUESTED`, `SPEC.BASELINE_APPROVED`, `SPEC.CLARIFICATION_REQUIRED`
- `RTL.CANDIDATE_READY`, `RTL.REPAIR_REQUESTED`
- `SIM.REGRESSION_FAILED`, `SIM.REGRESSION_PASSED`
- `FORMAL.PROOF_FAILED`, `FORMAL.PROOF_PASSED`
- `PPA.TARGET_CHANGED`, `PPA.TARGET_MISSED`, `PPA.TARGET_MET`
- `EDA.JOB_REQUESTED`, `EDA.JOB_COMPLETED`, `EDA.JOB_FAILED`
- `ENV.PROFILE_REQUIRED`, `ENV.PROFILE_READY`, `ENV.PROFILE_BLOCKED`
- `PEER.REQUEST_CREATED`, `PEER.RESPONSE_RECORDED`
- `GATE.EVIDENCE_READY`, `GATE.RELEASE_ACCEPTED`, `GATE.RELEASE_REJECTED`
- `POLICY.BUDGET_EXHAUSTED`, `POLICY.SCOPE_VIOLATION`, `RUNTIME.STALLED`
- `HUMAN.APPROVAL_REQUESTED`, `HUMAN.APPROVAL_RECORDED`

Event 類型會版本化。未知或無權來源事件必須隔離 `QUARANTINED`，附理由與可供人類查看的紀錄，不能落到 Main Agent 自由判斷。

## 2.2 Ingress 到 Owner 喚醒的完整生命週期

1. Source Adapter 收到 Human Intent、Git Commit、CI、EDA Runner 或 Timer 訊息。
2. AuthN / AuthZ 驗證實際主體、Event Type、受允許 project/IP 與 scope；確認來源並不只是外部文字。
3. 驗證 schema、規格版本與 `idempotency_key`。相同 key、相同 payload digest 回傳原 Event Receipt；相同 key、不同 payload digest 回覆 `409 CONFLICT`。
4. 在**同一個 DB transaction** 裡新增 Event Journal、Route Resolution、所有 Delivery、Outbox；Commit 成功後才回覆接收成功。
5. Scheduler 掃描 READY / 租約過期 Delivery，依 priority、跨 Ticket fairness 和配額挑選。
6. Claim 以 compare-and-swap 方式更新 `lease_epoch` / `lease_owner` / `lease_until`，設定 `RUNNING`，記錄 Attempt。
7. Wakeup Adapter 為 Owner 取得 Ticket Snapshot（含截至特定 Sequence 的 Event、Evidence、受允許的 Peer Messages）。
8. Owner 啟動已配置的 Harness，解析事件，選用領域 Skill，提交結構化 Action（EDA Job、Peer Request、New Event、Decision、Wait、Done）。
9. Runtime 僅驗證 Action 權限、合約、版本與預算，在 transaction 中提交 Attempt Result、產生新 Event／EDA Job、釋放或變更 Ticket 狀態。
10. EDA Runner 結束時以註冊的 `job_id` 回傳結果。Runtime 查詢 Job Registry 得知合法的 `requesting_owner`；不信任回傳 payload 自帶的 owner。
11. 新結果進入相同 Ingress 流程，重新進行 Router 與 Owner Wakeup；工作收斂或有正當 Stop Reason 才終止。

## 2.3 Durable Delivery 的約束

- 語義為 **At-least-once + Idempotent Side Effects**，不承諾物理 Exactly-once。
- Delivery 的唯一鍵 `(event_id, target_owner, route_version)`；相同 Event 可 fan-out 到多位 Owner，每一位有自己的 Delivery 狀態。
- `attempt_id` 和 `lease_epoch` 必須在完成時提交；舊 Attempt 即使較晚完成也不能寫入。
- Restart 掃描逾期租約，記錄 `ATTEMPT_INTERRUPTED`，重新入佇列。
- 已提交的外部副作用利用 `operation_key` + Outbox Receipt 防止重複發起。
- 比較 Spec / RTL / Environment Revision。過期候選結果可存檔作研究，但不能提升 Release Gate，不能覆寫較新的 Ticket Current Revision。

## 2.4 Ticket、Run、Peer Request 狀態機

`Ticket`: `NEW → ACTIVE → WAITING_FOR_EDA | WAITING_FOR_PEER | WAITING_FOR_HUMAN | VERIFYING | BLOCKED → ACTIVE | COMPLETED | CANCELLED`。

`Delivery`: `READY → CLAIMED → ACKED | RETRY_WAIT | DEAD_LETTER`。`CLAIMED` 過期返回 `READY` 並遞增 epoch。

`EDA Job`: `REQUESTED → VALIDATING → QUEUED → RUNNING → COMPLETED_PASS | COMPLETED_FAIL | INFRA_FAILED | CANCELLED`。

`Peer Request`: `CREATED → DELIVERED → ACCEPTED | NEEDS_EVIDENCE | REJECTED → RESOLVED | EXPIRED`。拒絕需要 reason code；要求額外資料需一次列出欄位，避免兩個 Agent 無限互問。

`Notification`: `PENDING → DELIVERING → DELIVERED → ACKED`，若失敗重排並保留送達記錄。Session 重新開啟時用 Cursor 讀取未確認通知。

### Owner 狀態 vs Runtime 狀態

Owner 可以回報 `WAITING_FOR_EDA` 代表釋放模型資源；Runtime 可在 EDA Job 返回時喚醒 Owner。不可用一個永遠開著的模型 Loop 等待。

## 2.5 事件分派政策與路由表

詳見 `config/routes.yaml`。路由是純函數 `route(event, route_version, job_registry, owner_registry)`，輸出 `{primary_owner, subscribers, matched_rule_id, authz, disposition}`，不可呼叫 LLM。

| Event | Primary Owner | Extra subscriber |
|---|---|---|
| SPEC.CHANGE_REQUESTED | spec | integration 觀察 |
| SIM.REGRESSION_FAILED | verification | 依 Ticket 關聯通知 RTL 僅作 context |
| FORMAL.PROOF_FAILED | formal | verification 觀察 |
| RTL.CANDIDATE_READY | rtl 不消費自身 | verification、formal、ppa（由有效變更判斷） |
| PPA.TARGET_CHANGED | ppa | integration 觀察 |
| ENV.PROFILE_BLOCKED | eda_environment | 請求該 Profile 的 Owner 訂閱狀態 |
| EDA.JOB_COMPLETED | job_registry.requesting_owner | 該 Job 的保留訂閱者 |
| PEER.REQUEST_CREATED | peer_request.target_owner | peer_request.origin_owner 接收狀態 |

需要只提供 context 的 Delivery 與需要主動行動的 Assignment 要區分。相同 Event 不應因雙重訂閱造成兩個 Owner 都認為自己負責主流程。

## 2.6 死循環抑制與「有效工程進展」定義

每次 Owner 嘗試的 `progress_delta` 必須引用可驗證證據。合法的工程進展僅包括：

1. 原本失敗的可重現 Test 現在通過，且其他必要回歸沒有退步。
2. 在相同 Fingerprint 下，已驗證的 Formal Counterexample 集合縮小，或新增有效性質通過。
3. 不改變約束與功能的前提下，實測 PPA 指標改善並通過 Gate。
4. 新增可復現且與既有簽章不同的 Root Cause／Reproducer，使問題空間可證明縮小。
5. 正式規格歧義已由有權人員澄清並更新基線。

單純修改檔案、產生測試、模型說找到原因、分派 Worker、重複跑同樣的失敗案例、拉高 token 預算，都不算 progress。

Watchdog 用 `(ticket, fingerprint, failure_signature)` 追蹤：

- 每個相同 failure_signature 預設最多 **3 次無有效進展的修復嘗試**。
- 每個 Ticket 預設最多 **8 次 Agent 工作 Turn**，每個局部 Arena 最多 **3 個候選**，最多同時 **3 個 Worker**，嵌套深度預設 **2**。
- 每個 Ticket 的 Token／EDA 時間配額由 Policy 定義（預設示範值見 `config/autonomy.yaml`），超過上限則停止或提出批准。
- 任何超出既定範圍的新 Framework、套件、外部 Repo、長期排程、發布，都必須另外批准。
- 轉為 `BLOCKED` 時保留最小再現、嘗試歷史、最近有效成果與可行下一步。不會阻擋其他 Ticket。

設定檔可以改預算，但**必須經 Policy API、身份驗證與版本記錄**，不能由 Agent 改自身的配置繞過 Watchdog。

## 2.7 Event Loop 的三條工程鏈

### Chain A：Regression Bug

`SIM.REGRESSION_FAILED` → Verification Owner (`waveform-tdd`, 重現 / triage) → `PEER.REQUEST_CREATED(RTL_REPAIR)` → RTL Owner (`rtl-arena` 可選) → `RTL.CANDIDATE_READY` → Verification + Formal 分別 EDA Job → `EDA.JOB_COMPLETED` → 原 Owner 驗證 Evidence → Integration Gate → `GATE.RELEASE_ACCEPTED` 或重試 / 停止。

### Chain B：Spec Change

`SPEC.CHANGE_REQUESTED` → Spec Owner 確認影響與批准基線 → `SPEC.BASELINE_APPROVED` → RTL / Verification / Formal 依 Dependency Map 改變 → 相同版本驗證 → PPA → Integration。

### Chain C：PPA Miss

`PPA.TARGET_MISSED` → PPA Owner 確認約束 → `PEER.REQUEST_CREATED(PPA_RTL_ALTERNATIVE)` → RTL Owner 使用 `rtl-arena` → 候選先功能／Formal 過關，再在同一 Toolchain 和 Constraints 下公平比較 PPA → Integration 或 PPA 提出有證據的不可達結論。

## 2.8 同步與併發衝突

- 每個 IP 的 Spec Baseline 和 Candidate SHA 是 MVCC 的版本欄位；舊結果不得覆蓋新基線。
- 新 Spec 在舊 Run 中到達：記錄 `SUPERSEDED`，舊 EDA Job 可受控取消或繼續提供診斷參考，不能混入新 Release。
- 不同 IP Ticket 之間應能獨立 Claim；一個被 Watchdog Blocked 不能拖垮其他 IP。
- 寫同一 RTL 模組的平行 Worker 必須使用不同 Git Worktree 和輸出路徑。產物由 Owner 決定合併，合併後重新跑完整 Gate。

## 2.9 Failure / Recovery Matrix

| 故障 | Runtime 必須採取行為 |
|---|---|
| Backend Crash | Restart 重建 Queue / 逾期 Lease；同一 operation 不可雙重外部提交 |
| Harness 逾時 | kill / interrupt 本 Turn，保留 Ticket / trace，下次可換 Session 重建 context |
| Harness 切換 | 將事件、決策、證據與最小 Resume Snapshot 遷移，不能只寄望原模型 Context |
| EDA runner Crash | 標記 `INFRA_FAILED`，分別計算 Infra Retry，不消耗工程修復額度 |
| Toolchain mismatch | Job 停至 `WAITING_FOR_ENV`，Environment Owner 修復，Profile Ready 後重排 |
| Peer 無回覆 | 到期提醒一次，擁有者自行要求補件或升級成跨領域阻礙，不轉給 Main 做技術裁決 |
| 無法判斷需求 | Spec Owner 建立 Human Attention，問題收斂成最少必要選項 |
| 未知 Event | Quarantine，理由與原事件可查，不丟失 |
| 連續等值失敗 | Watchdog 停止該 Ticket，保留 Evidence 並新增 PDCA Case |
| 通知服務離線 | Outbox 重試，登入 Harness 時 Session Resume Sync |

## 2.10 A0 參考原型與正式產品差別

本套件 `reference/` 是可測試的 Runtime 子集，並沒有真實 Harness / MCP Server / EDA Runner / Web。它不提供高可用、正式權限驗證或永久升級路徑。Coding Agent 必須實作後續 Gate，而不是複製測試讓它顯示綠燈。

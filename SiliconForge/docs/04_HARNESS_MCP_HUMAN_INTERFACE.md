# 04｜原生 Harness、MCP、Skills、Hooks、通知與人類介入

## 4.1 產品裁決

**不開發自行維護的自然語言 CLI**。使用者直接開啟原本的 Codex、Claude Code；SiliconForge 以可安裝 Skills、專案指引與 MCP Server 擴充。Web 是獨立 Operational Dashboard。Codex / Claude Code 的 User Session 退出後，Runtime 仍能自行啟動 Domain Owner Worker；User Session ≠ Owner Session。

需區分兩個不同的方向：

- `Harness as Client`：人類使用 Codex / Claude Code 作為 Main 對話入口，透過 SiliconForge MCP Server 提交 Intent、查詢、審閱、批准。
- `Harness as Executor`：SiliconForge Runtime 在背景透過官方 Codex SDK 啟動 Domain Owner Thread/Turn，依自己的 Owner Policy 執行 P-Stack Skills 和 EDA 工具。未來再增 Claude Owner Adapter。

不要把「Codex 讀取 SiliconForge MCP」和「SiliconForge 呼叫 Codex Agent」混成同一個 API。

## 4.2 MCP Tool v1 契約

MCP 服務端必須將身分由連線驗證層提供；`actor` 參數僅作記錄，不能提升權限。所有工具回應至少有 `request_id`、`schema_version`、`ok`、`data` 或 `error_code`；修改狀態的工具需接受 Idempotency Key。MCP Tool 名稱預留：

| Tool | Mode | Input | Result | 強制政策 |
|---|---|---|---|---|
| `sf_get_status` | Read | project、ip、ticket filters | Ticket/Owner/Gate 摘要 | 依 User Scope 過濾 |
| `sf_list_events` | Read | cursor、filters | Event Pages | 不輸出 Secret |
| `sf_get_evidence` | Read | evidence_id | 可追溯 Metadata + 檔案 Locator | 只讀、版本檢查 |
| `sf_get_communication` | Read | ticket、cursor | Peer Request Timeline | 依權限遮罩 |
| `sf_get_notifications` | Read | cursor | Important Notices | 不能更改 Engine 狀態 |
| `sf_propose_intent` | Write | natural language + target + expected_rev | Intent Proposal / required_confirmation | 不直接修改 RTL |
| `sf_commit_intent` | Write | proposal_id + idempotency_key | Event Receipt | Policy、授權、Revision CAS |
| `sf_send_peer_message` | Write | target_owner + ticket + intent | Peer Message Receipt | 只作工程需求與上下文 |
| `sf_submit_approval` | Write | approval_id + decision + expected_rev | Approval Receipt | 必須是有權人類身分 |
| `sf_control_ticket` | Write | ticket + pause/resume/cancel | Command Receipt | 有權限定、可審計 |
| `sf_ack_notification` | Write | notification_id | Ack Receipt | 不覆蓋 Delivery 歷史 |

其中 `sf_propose_intent` 只是幫人類轉成結構化 Intent。對於已預先授權且內容無歧義的非敏感修改，可由 `sf_commit_intent` 自動提交；無授權或超出 scope 時需 Human Approval。不得把 model 產生的批准文字當作人類授權。

**重要**：`sf_submit_event` 對外僅供 Trusted CI、EDA Runner 或系統 Sensor 角色。一般 User Harness 不能任意偽造 `EDA.JOB_COMPLETED`、`SIM.REGRESSION_PASSED` 等工程事實。自由模擬器可有 Admin-only `inject_mock_event`，但與 Production namespace 嚴格隔離。

## 4.3 User Harness 安裝方式

### Codex

- 專案根目錄 `AGENTS.md`，可發現的 `skills/siliconforge/SKILL.md`。
- 使用 Codex 原生 MCP 設定加入 `siliconforge` Server。具體安裝指令由 Coding Agent 以當時安裝的 Codex 版本確認，不應在規格鎖死一個過期 Plugin Manifest。
- 人類用自然語言說「查 SiliconForge 的 CRC32 狀態」、「請提交新 Spec」，Skill 提醒工具操作序列。

### Claude Code

- `CLAUDE.md` 引用共用的行為契約；配置 Claude Code 支援的 Skill 與 MCP Server，確認可讀取。
- 支援的 Hooks 可用於 Session Start 時同步未讀通知；不能假設 Hook 在已退出的 Claude Process 中可以主動接收事件。
- 若某版本支援 MCP Push Channel，可作可選功能，必須 Feature Detect 與實測；不支援時仍能透過 Web／Outbox／Session Resume。

## 4.4 Codex Domain Owner Adapter v1

Interface：

```
start(owner_id, ticket_snapshot, harness_policy) -> run_id, thread_id
resume(owner_id, ticket_snapshot, saved_thread_id?) -> run_id
cancel(run_id, reason) -> CancelReceipt
stream(run_id) -> RunEventIterator
result(run_id) -> OwnerStructuredAction
```

適配層必須：

1. 以官方 Python `openai-codex` SDK 為優先實作，啟動／恢復 Thread，使用限定 Workspace / Sandbox。
2. 將外部 Event / Peer Message 當成較低權威的 External Input，而非把來自其他 Agent 或檔案的字串當成具批准權的人類指令。
3. 限定模型、reasoning effort、工具、Worker數、Timeout 與 Budget，以 Policy 為準；不可自行要求更高權限。
4. 將 Thread ID、Turn ID、Token/Cost（若 Harness 有可靠欄位）、開始結束、工具操作與證據關聯紀錄到 Run。
5. 將模型輸出轉成受 Schema 檢查的 `OwnerAction`，未通過合約或依據不足則拒絕寫入 Runtime。
6. 支援 Thread 遺失後以 Ticket Snapshot 重建新 Thread；Harness Session 不能成為唯一狀態。

預設 single Harness：Codex。Model policy 透過 `config/harness.yaml` 解析可用模型，不硬編不存在的模型名稱，也不假定所有使用者都有同等權限。對失敗原因分類：rate limit / auth / unavailable / timeout / policy violation / bad output。

## 4.5 Notification Contract

所有通知**先寫入 Durable Notification Outbox**。通道優先順序：

- 運作中：Dashboard SSE/WebSocket 與可用的 Harness Push。
- Harness 重新開啟：Skill/Hook 查詢 `sf_get_notifications(cursor)`，顯示上次之後的重要摘要。
- Harness 離線：保留 Outbox；可選擇傳至已授權的外部管道，不預設外送原始晶片資料。

預設 `notify_on`：`WAITING_FOR_HUMAN`、`BLOCKED_NO_PROGRESS`、`COMPLETED_WITH_EVIDENCE`、`SECURITY_POLICY_VIOLATION`、`BUDGET_NEAR_LIMIT`；一般 Agent Heartbeat、每個 EDA Job 完成及測試數量不通知人類，Dashboard 可查。

通知可去重且有 cursor、ACK、Retry；同一 ticket 同一 signature 及窗口可聚合，不吞掉重要關鍵變化。禁止以無限 LLM Loop 輪詢 Notification；允許非模型進程用短輪詢或 DB wake-up。

## 4.6 Human-in-the-loop 的精確邊界

需要批准：

- 需求衝突／缺少規格下無法推論的語意；改變公開接口、系統安全需求與原有合約。
- 寫入生產服務或對外發布、推送到不在授權範圍的遠端、取得新權限、擴展預算。
- 永久更改 Routing、Policy、Skills、Toolchain Profile、評估 Gate。
- 需要超過 scope 的新 Repository／Framework／大型測試擴張。

可以自治：

- 在已授權 Scope 內修改 RTL，重跑既有測試、建立新的必要 Reproducer、調整合法微架構。
- 在既定 Toolchain Profile 內執行 Sim/Formal/Synthesis/PPA。
- 已明確授權的設計需求變更與合法的局部 P-Stack Worker。
- 在預算內的重試／保守故障處理與版本化的紀錄保存。

Approval 一定綁定 `proposal_id + scope_digest + policy_version + expected_rev + approver_principal + expires_at`，不能任意套用到其他 IP 或新版本。

## 4.7 介面跨 Harness 的契約測試

- Codex User Harness 可以查詢同一 Ticket 並提交合法 Intent。
- Claude Code User Harness 可執行同樣操作，但可能有不同裝載方式，Gateway 的 Event Receipt 必須一致。
- 不安裝 SiliconForge 專有 CLI 也能操作。
- 關掉 Codex / Claude User Session，任務不中斷；再次登入後讀取未讀通知且不重複騷擾。
- Domain Owner 的 Harness 換成另一個 Session 時，Ticket / Evidence / Approval 不遺失。
- 來自模型偽造的 Approval / EDA_PASS 訊息遭拒絕。

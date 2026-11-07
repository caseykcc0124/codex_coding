# 10｜Coding Agent 模組實作藍圖、介面與資料模型

此份文件把 00 至 09 的規格轉成具體的模組骨架和實作順序。它是 Coding Agent 的實作建議，**不能覆蓋 00 的架構原則及 07 的驗收條件**。

## 10.1 Production Repo Layout（M0 即固定）

```
siliconforge/
  AGENTS.md / CLAUDE.md
  pyproject.toml / uv.lock / Makefile
  backend/
    app.py                  # FastAPI app, startup and shutdown
    auth/                   # Principal, roles, permissions, scopes
    ingress/                # Event parsing, idempotency, quarantine
    runtime/                # Durable queue, router, scheduler, leases, recovery, watchdog
    tickets/                # Ticket, run, revision, dependencies
    messaging/              # Peer request, subscription, notifications
    adapters/               # Codex SDK, future Claude Adapter, fake harness
    eda/                    # job registry, runner, artifact parser, fingerprint
    environment/            # toolchain profiles, install/build, compatibility
    evidence/               # immutable artifacts + manifest + gates
    telemetry/              # audit, traces, read models
    pdca/                   # proposal, experiment, promotion flow
    mcp_server/             # explicit tools and permission enforcement
    api/                    # REST / SSE / Web authentication
  frontend/                 # React Dashboard; read views and approval UI
  silicon_skills/           # owner-specific P-Stack-derived skills
  ip/apb_crc32/
    spec/ rtl/ tb/ formal/ golden/ scripts/ constraints/
  tests/
    contract/ runtime/ mcp/ harness/ eda/ e2e/ chaos/
  toolchains/
    lockfiles/ docker/ smoke/
  deployment/
    local/ docs/
  reports/
  SILICONFORGE_WORKING_SYNC.md
```

不允許任意把 Gateway、Router、Agent、EDA 重新拆成分散式叢集服務。以單機可運作的模組化單體先完成驗收。所有共用資料由後端擁有，Frontend 不能自己生成工程真假結果。

## 10.2 Database schema／必需唯一約束

```sql
CREATE TABLE event_journal (
 event_id TEXT PRIMARY KEY, namespace TEXT NOT NULL,
 source_id TEXT NOT NULL, source_event_key TEXT NOT NULL,
 payload_sha256 TEXT NOT NULL, event_type TEXT NOT NULL,
 project_id TEXT NOT NULL, ip_id TEXT NOT NULL,
 trace_id TEXT NOT NULL, causation_id TEXT,
 occurred_at TEXT NOT NULL, accepted_at TEXT NOT NULL,
 policy_version TEXT NOT NULL, payload_json TEXT NOT NULL,
 UNIQUE(namespace, source_id, source_event_key)
);
CREATE TABLE event_delivery (
 event_id TEXT NOT NULL, owner_id TEXT NOT NULL, route_version TEXT NOT NULL,
 state TEXT NOT NULL, attempt INTEGER NOT NULL DEFAULT 0,
 lease_epoch INTEGER NOT NULL DEFAULT 0, lease_until TEXT,
 PRIMARY KEY(event_id, owner_id, route_version)
);
CREATE TABLE tickets (
 ticket_id TEXT PRIMARY KEY, project_id TEXT NOT NULL, ip_id TEXT NOT NULL,
 owning_domain TEXT NOT NULL, current_spec_rev TEXT NOT NULL,
 current_candidate_sha TEXT, state TEXT NOT NULL,
 last_progress_evidence_id TEXT, updated_at TEXT NOT NULL
);
CREATE TABLE eda_jobs (
 job_id TEXT PRIMARY KEY, requesting_owner TEXT NOT NULL, ticket_id TEXT NOT NULL,
 toolchain_digest TEXT NOT NULL, spec_rev TEXT NOT NULL,
 candidate_sha TEXT NOT NULL, constraints_sha TEXT NOT NULL,
 status TEXT NOT NULL, result_event_id TEXT UNIQUE
);
CREATE TABLE outbox (
 outbox_id TEXT PRIMARY KEY, kind TEXT NOT NULL, subject_id TEXT NOT NULL,
 dedupe_key TEXT NOT NULL UNIQUE, payload_json TEXT NOT NULL,
 state TEXT NOT NULL, attempts INTEGER NOT NULL DEFAULT 0
);
```

另外要有 `peer_requests`、`run_attempts`、`owner_decisions`、`evidence`、`notifications`、`approvals`、`toolchain_profiles`、`pdca_cases`、`audit_log`，所有行關聯不能只靠自由文字。

## 10.3 Ingress transaction 原子性

一個事件接收 transaction 必須把 `event_journal`、確定的 `route_decision`、`event_delivery`、必要 `outbox` 同時 Commit，否則全部 Rollback。

相同 `source_id + idempotency_key`，如果 payload digest 不變回舊 Receipt；digest 不同回 409；未知類型／來源雖不進正式工作佇列，也要有隔離紀錄。來源本身必須來自已驗證的 Principal，不能相信外部輸入字串。

Runtime 不得呼叫 Main LLM 去評估所有事件，Router 是小而可版本化的確定性邏輯。跨領域依賴可以用訂閱，但 `Context Delivery` 不自動等於新工程工作授權。

## 10.4 Scheduler / Lease 與外部副作用

- Claim 過程 `BEGIN IMMEDIATE`、選擇可用 Delivery、增加 `lease_epoch`、寫入 deadline、建立 `run_attempt`，成功後啟動 Worker。
- 完成時要求 `event_id + owner_id + lease_epoch` 匹配最新狀態，舊 Attempt 不能寫入新 Ticket。
- 對 Peer Request、EDA Job、Notification 等副作用，用 Transactional Outbox + 受唯一鍵保護的 Operation Receipt；Consumer 可重送，Server 防重。
- Worker Crash 的不確定性必須被處理：若不能證明某外部操作是否已執行，先查 Operation Receipt／Job Registry 再重試，不能直接對外多建一份。
- 正常 `WAITING_FOR_EDA` 後不保留 LLM 進程；收到 Job Completed 事件再喚醒。

## 10.5 HarnessAdapter 接口與執行安全

```python
class HarnessAdapter(Protocol):
    async def start(self, owner_id: str, ticket_snapshot: dict, profile: dict) -> dict: ...
    async def resume(self, owner_id: str, ticket_snapshot: dict, thread_id: str | None) -> dict: ...
    async def cancel(self, run_id: str, reason: str) -> dict: ...
    async def events(self, run_id: str): ...
```

負責準備 `Owner Context Bundle`：最新批准的 Spec、當前 Ticket、可讀的 Peer Request、Evidence Summary、P-Stack Skill、Tool Budget。外部 Model/Agent 文字是低信任輸入。每次輸出先走 `contracts/owner_action.schema.json`，再由 runtime 進行權限/Quota/Revision 檢查。

模型名稱不能在程式碼到處硬編；Harness Registry 在啟動時查可用選項、紀錄選擇與推論配額。Thread 丟失仍能透過持久化 Snapshot 重啟。每個 Owner 應有隔離 Workspace、受限工具，以及可審查的 Worktree / Diff。

## 10.6 EDA Runner 從 Job Request 到新事件

1. 由 Owner 提交 `EDAJob`，必含 `tool`, `toolchain_profile`, `env_digest`, `spec_rev`, `rtl_sha`, `constraints_sha`。
2. Runtime 驗證 Toolchain Profile 是否 `VERIFIED`、版本匹配、Job Budget 尚可、Artifact 路徑受限。
3. Runner 使用已 pinned 的 immutable toolchain image，預設隔離網路與 Secrets，從明確的 Input Manifest 讀取 Source。
4. 將 command line、tool version、exit code、stdout/stderr 摘要、Report／Waveform／Netlist／SDF 等 Artefact SHA 存入 Evidence Store。
5. 只由受信任的 Parser 分析 Pass/Fail/Unknown，Report 缺失不能以 Exit Code 0 概括認定通過。
6. 用 `job_id` 反查 requesting_owner，發布 `EDA.JOB_COMPLETED`／`FAILED`，啟動下一輪 Event Loop。
7. Integration Owner 審查同 fingerprint 的各 Gate，產生 Release Manifest。

## 10.7 MCP / REST 操作共用 Command Handler

MCP Tool、Web REST Endpoint 都只作薄 Adapter，呼叫同一 `ApplicationCommandHandler`，不能兩套身份與驗收邏輯。

推薦 REST Endpoint：

```
GET  /api/v1/status
GET  /api/v1/events?cursor=&project_id=&ip_id=
GET  /api/v1/evidence/{evidence_id}
GET  /api/v1/tickets/{ticket_id}
GET  /api/v1/communications?ticket_id=&cursor=
POST /api/v1/intents/propose
POST /api/v1/intents/{proposal_id}/commit
POST /api/v1/approvals/{approval_id}
POST /api/v1/tickets/{ticket_id}/control
GET  /api/v1/notifications?cursor=
POST /api/v1/notifications/{notification_id}/ack
GET  /api/v1/activity/stream  # SSE; mock UI cannot mint production events
```

MCP 工具對應 `docs/04`，所有寫入有 `idempotency_key`、CSRF/Identity Scope（視 transport）及完整 Audit。私有資源不得匿名開放。

## 10.8 監控面板資料投影

`dashboard_read_model = project_by_sequence(event_journal, run_attempts, evidence, peer_messages, notifications)`，Projection 必須可重建。Dashboard 觀察主題用 SSE / WebSocket Streaming，另提供安全的逐頁 Event Query。Telemetry 故障時仍應寫入權威 Journal。

## 10.9 Failure Model 與最低可恢復性

- 指令已 Commit 但 Consumer 未收到：Outbox Retry。
- Consumer 收到多次：Idempotency Key 去重。
- Runner 完成但回報前 Crash：Job Receipt / Artifact Registry 重查。
- Owner 失聯／超時：Lease Expired + Fencing；新 Attempt 根據 Snapshot Resume。
- 新 Spec 在 Run 中：舊 Result 標示 Stale，不能驗收新 Baseline。
- 無進展：Watchdog Blocked；保存最小證據與 PDCA Case。

## 10.10 性能與可驗收性的合理邊界

本機單 Writer / SQLite WAL 是 MVP；須用 1,000 個 Mock Events 壓力測試，驗證吞吐、去重與恢復，不需承諾大規模多租戶生產級 SLA。若 Backend Service、Web、MCP 三者都在一台機器，仍需確保「User Session 關閉」不影響后台 Runtime Worker，不能用 Web JS 模擬 Loop 當作自主執行的證據。

## 10.11 實際啟動後必要的文件

- `deployment/LOCAL_SETUP.md`：WSL2／Docker／Python、Models 授權、MCP 設定、起停命令及故障排除。
- `deployment/TOOLCHAIN_LOCK.md`：工具版本、映像 Digest、合法來源、Smoke Tests。
- `reports/ACCEPTANCE_REPORT.md`：逐 Case 真實執行結果、證據檔與 SHA。
- `reports/ARCHITECTURE_DEVIATION.md`：如有必要架構修改，保留批准者與原因。
- `SILICONFORGE_WORKING_SYNC.md`：跨 Coding Agent 的單一進度同步入口。

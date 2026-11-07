# SiliconForge v3.0 正式規格與實作計畫書

文件基準：2026-11-07。此整合檔依 00 至 10 排列；以套件內個別文件與驗收矩陣為執行契約。



---

# 00｜設計主旨、脈絡與不可變更原則

## 0.1 原始問題

晶片研發的工程活動具有明確的可驗證工具鏈：Spec / SystemC → RTL → Simulation / Formal → Synthesis / Netlist → PPA → Report。現有 Coding Agent 擅長局部程式工作，但持續運行時容易出現：

1. 由人類持續驅動下一步，等待指示造成中斷。
2. 單一 Main Agent 包辦工作理解、派遣、工程判斷及最終仲裁，形成 Context 與決策瓶頸。
3. RTL／Verification／Formal／PPA 各自缺少真正的領域工作方法，P-Stack 只剩名稱。
4. Sim / Formal / PPA 的結果不能可靠形成下一輪事件，容易讓工作停在某次工具報告。
5. 多個 Agent 執行後缺少可比對版本與完整工程證據，出現「一直跑，但沒有進步」。
6. EDA 版本不一致，各 Agent 自行裝工具，使結果不可重現。
7. 當 Codex／Claude Code 使用者 Session 關閉時，工作遺失或無法自主恢復。
8. 無法解釋為什麼卡住，無法從紀錄形成下次流程改善，並容易過度打擾人類。

## 0.2 成功時的使用體驗

使用者在既有 Codex 或 Claude Code 說：「APB CRC32 新增 reset 期間不得回傳舊 CRC 的需求，其他條件不變。請讓 SiliconForge 自主完成設計與驗證。」

預期系統：人類入口經 SiliconForge Skill / MCP 提交具授權來源的 Intent，Runtime 將 `SPEC.CHANGE_REQUESTED` 直接投遞 Spec Owner。Spec Owner 將可驗收的規格增量與影響範圍寫入紀錄並發出新事件。RTL、Verification、Formal、PPA 各自決策，使用專業化 P-Stack Skills；EDA Runner 在鎖定的 Toolchain Profile 中執行。結果重新進入 Event Bus。若失敗則依 evidence 迴圈修正，若沒有可測量進步則停止。所有過程可在 Web Dashboard 追蹤。Codex 人類端關閉後流程仍可運作，最後只通知已完成、真正受阻或需要批准的事項。

## 0.3 唯一主要目標

**建立一套可長期持續、事件驅動、有限度自治、有工程證據、可恢復、可改進的晶片研發平台，先在單一 APB CRC32 IP 完成真實端到端驗證。**

## 0.4 十條硬性架構原則

- INV-01：Runtime 是普通持久化服務，可在沒有 Main LLM Session 的情況下工作。Main 不是工程仲裁者。
- INV-02：Runtime 根據既定規則直接 Router 到對應 Owner。只有意圖模糊或跨權限授權才需要人類／入口 Agent 協助。
- INV-03：每一個 Domain Owner 對自己專業領域有決策權和 P-Stack 工作方法。跨 Owner 透過有身份、期限、驗收物的事件／Peer Request 協作。
- INV-04：Engineered Evidence 是主要事實來源，模型文字不能宣稱 EDA Pass。
- INV-05：工程成果必須綁定 `spec_rev`、`rtl_sha`、`env_digest`、`constraint_sha`、`tool_versions`、`run_id`。
- INV-06：EDA Environment 由獨立 Owner 維護，其他 Owner 不能安裝、升級或修改正式 Toolchain Profile。
- INV-07：使用者入口優先是原生 Codex／Claude Code Harness + Skill + MCP + Instructions。Web 主要做監督與批准。禁止另造專用自然語言 CLI。
- INV-08：Ticket 與事件比 Harness Session 活得更久。切換模型或 Harness 不得遺失工程任務、證據與人類批准紀錄。
- INV-09：不存在無限自主任務。必須有工作範圍、可觀測進度、資源配額、超時、重試上限、Watchdog 與停止理由。
- INV-10：每一次執行都留下可回顧的過程證據，能將失敗／成功案例轉換成 PDCA 改善假說，改動正式策略需經隔離驗證與批准。

## 0.5 禁止的實作偏移

- `anti-1`：收到任何 Event 都先要求 Main Agent 思考如何派遣。
- `anti-2`：建立一套名叫 SiliconForge CLI 的新聊天工具，讓使用者捨棄原本 Harness。
- `anti-3`：讓 Verification Agent 在自己的 Session 下載或升級 Verilator。
- `anti-4`：以 Prompt 輪詢取代事件持久化佇列。
- `anti-5`：用 P-Stack `swarm` 建立多個沒有分工或檢查的子 Agent。
- `anti-6`：為解決某個簡單 CRC Bug，擅自新建一套大規模 Verification Framework 或引進第三方雲端服務。
- `anti-7`：改寫 Golden Model、Testbench 或 Formal Property 讓錯誤 RTL 通過，而缺少獨立的規格佐證及受控審查。
- `anti-8`：把新的 Commit 數、Token 消耗、測試數、Agent 活動量當成完成。
- `anti-9`：偷偷降低 Gate、修改約束或覆蓋歷史報告，讓 PPA 指標看似改善。
- `anti-10`：把改良建議直接併入正式政策或正在執行的 Ticket，未經版本比對或批准。

## 0.6 第一階段實驗邊界

一個 APB3 CRC32 Engine，使用 Python Golden Model、開源 RTL/EDA。必須至少驗證新 Spec、Sim Failure、Formal Failure、PPA Target、環境漂移、空轉停止、人類插入變更、多 IP 任務隔離等情境。APB CRC32 收斂後可增加 AES-128 或小型 Peripheral；不可擅自先擴張 MCU／SoC 全系統。

## 0.7 「少打擾人類」量測定義

人類介入指一次需要使用者選擇工程方向、授權、補充不可推知的需求或手動恢復流程。Dashboard 觀察、主動閱讀紀錄不算介入。預先授權範圍內的自主執行，目標中途干擾次數為零。需求歧義、正式政策擴權、預算上調、外部發布及安全敏感變更需批准。停止而提供完整證據與可選方案，也是正確成果。


---

# 01｜系統架構與決策權

## 1.1 精確的產品形態

SiliconForge 是一個「有 Web Dashboard 與原生 Harness 接入口」的長時間自主工程後端，第一版是可單機執行的 **模組化單體 + 獨立 Agent Worker + EDA Runner**，不是新的 Coding Agent Harness，更不是一群只靠 Prompt 互相聊天的 Bot。

```
Human Codex / Claude Code ── Skills + AGENTS.md / CLAUDE.md
          │
          └── MCP Gateway (Identity, Intent, Read, Approval, Notifications)
                            │
Web Dashboard ─────── REST / SSE ───┤
                                    ▼
              ┌─────────────────────────────────────────┐
              │ SiliconForge Super Agent Runtime       │
              │ Ingress / Policy / Durable Event Store  │
              │ Router / Scheduler / Lease / Watchdog   │
              │ Ticket / Command / Notification Outbox  │
              └────────────────┬────────────────────────┘
                               │ (owner-directed durable delivery)
       ┌───────────────────────┼─────────────────────────┐
       ▼                       ▼                         ▼
   Spec Owner              RTL Owner             Verification Owner
    [P-Stack]               [P-Stack]                [P-Stack]
       │                       │                         │
       ├───────────── Domain Peer Request ───────────────┤
       ▼                       ▼                         ▼
   Formal Owner             PPA Owner             Integration Owner
    [P-Stack]               [P-Stack]                [P-Stack]
       │                       │                         │
       └────────────┬──────────┴───────────────┬──────────┘
                    ▼                          ▼
           EDA Environment Owner       Process Improvement Owner
              [P-Stack]                     [P-Stack]
                    │                          │
                    ▼                          ▼
            Immutable Toolchains         PDCA Proposals
                    │
                    ▼
             EDA Runner (Container)
           Verilator / cocotb / Yosys / SBY / OpenROAD
                    │
                    ▼
       Evidence Store + Engineering Event Feedback → Runtime

Main Agent 是可選的人類對話介面角色，只存在於使用者選擇的 Harness；它沒有全域工程仲裁權。
```

## 1.2 模組邊界

| 元件 | Owns | 不擁有 | 永久狀態 |
|---|---|---|---|
| Ingress / Auth | 來源認證、Event Validation、Idempotency | 工程意圖與解法 | Event、Ingress receipt |
| Router | 規則、Owner 解析與交付結果 | RTL 修復、Formal 策略、PPA 選擇 | Route decision、Rule version |
| Scheduler | Queue、Fairness、Lease、Wake-up | Worker's 工程策略 | Claim、Attempt、Lease |
| Policy / Watchdog | 權限、配額、停止與復原 | 工程品質最終判斷 | Budget、Stop reason、Audit |
| Ticket Store | Ticket、Revision、Dependency、Supersession | LLM Session 歷史的唯一真相 | Ticket、Run、Artifact refs |
| MCP Gateway | 檢視、授權提案、事件提交、通知 | Domain 工程判斷 | Session、Principal、Receipt |
| Domain Owner | 該領域工程決策、P-Stack 執行 | Runtime 路由／全域權限／未經批准擴張 | Decision Record、Peer Request |
| EDA Environment Owner | Toolchain 建置、Pin／Release／退版 | 一般 RTL/Verification 策略 | Profile、Digest、Compatibility |
| EDA Runner | 執行已有 Job Contract、原始結果封存 | 變更 Spec、工具安裝或「口頭宣布 PASS」 | Job、Exit Code、Reports |
| Integration Owner | 關聯 Gate、合格版本交付 | 變更 Golden Model／Formal Property 避免失敗 | Release Manifest |
| PDCA Owner | 根因簇集、改善提案、對照實驗 | 直接修改 Production Policy | Proposal、Experiment Record |
| Dashboard | 讀取物化視圖、人工授權 UI | 唯一真相、Event 投遞 | UI Preferences 可選 |

## 1.3 Domain Owner 必要集合與權限

| Owner | 允許自主決策 | 不可自主擴權 |
|---|---|---|
| Spec | 將已授權需求拆成可驗收規格、分析 impact | 推測衝突或新增對外規格後自行當作批准 |
| RTL | 微架構、修復、候選 RTL、局部 Arena | 偷改 Testbench、Formal 或 Constraint；不准改工具安裝 |
| Verification | Test Plan、Reproducer、Regression、Coverage、Failure Triage | 降低 Coverage Gate 或刪除失敗案例 |
| Formal | Property mapping、Counterexample 分析、Assumption 檢查 | 當 Proof 不過時自行削弱 Property 得 PASS |
| PPA | 既定約束的最佳化、候選測量、提出 RTL 修改需求 | 變更 Timing Constraint、製程模型／Lib、允許劣化規格 |
| Integration | 檢查相同 Fingerprint 的 Gate、產出 Release | 接受 Mock Report 或混合不同版本 |
| EDA Environment | 建置／驗證固定 Profile、處理環境事件 | 直接替其他 Owner 修改 RTL 或覆寫舊 Environment |
| PDCA | 找出系統性失敗、提出 Skill／Policy 改善 | 直接改 Runtime Routing、正式 Skill 或系統預算 |

Main Agent 可查詢、彙整、把明確人類指令提交為 Intent、協助批准；不對 RTL/Verification 做工程仲裁。允許人類直接在原生 Harness 與某位 Owner 對話，但透過 Gateway 保持識別、權限及紀錄。

## 1.4 Runtime 的四層狀態

- `Intent`：誰提出什麼工程需求，經何種授權與規格確認。
- `Ticket`：跨多次 Run 持續存在的工作與責任 Owner，可在閉環收斂後保留。
- `Run / Attempt`：某次啟動、Harness Thread、Tool 與工作版本；可失敗重試。
- `Evidence`：EDA 結果、Golden Model、證明、Netlist、PPA 與其 Digest。

特別要求 `Ticket != Run`、`Run != Turn`、`WorkItem closure != Gate pass`。不能因一次 Agent Turn 結束就將 Ticket 設成 `VERIFIED`。

## 1.5 跨領域合作關係

- Verification 發現失敗，先由 Verification 判定重現與可能來源；如果是 RTL 修補，直接建立 `PEER.RTL_REPAIR_REQUEST` 交給 RTL Owner。
- RTL 發布 `RTL.CANDIDATE_READY`，Runtime 以不同 Delivery 分派 Verification、Formal，並讓 PPA 按有效規則訂閱；不經 Main。
- PPA 需要改變 Pipeline 時，直接建立帶 Critical Path、Constraint、Target 的 Peer Request 給 RTL；RTL 自行決定要不要 Arena。
- Formal 需要放寬 Property 或 Spec 衝突時，不直接修改，建立 `SPEC.CLARIFICATION_REQUIRED` 給 Spec Owner，後者必要時請人類確認。
- Environment Owner 不在每個 EDA Job 上即時批准。Profile 已驗證且 Digest 相符，Runner 直接使用；版本不相符才發 `ENV.PROFILE_BLOCKED`。

## 1.6 使用者入口與 Harness 分離

第一版人類使用者啟動 **現有 Codex / Claude Code**，裝 SiliconForge Skill、MCP、Repository Instructions。人類對話 Agent 可以走同一組 Gateway API。Domain Owner 的 Codex Sessions 由 Runtime 建立／恢復，與人類 Terminal 的生命週期完全獨立。

未來可選其他 Harness；不可從第一版就為跨 Harness 建立過度設計的 Service Mesh。先實作 `HarnessAdapter` 協定與 Codex 一個真實 Adapter；Claude Code 的使用者入口在 MCP 層驗證，Claude Domain Owner Adapter 列為後續能力，不應假設所有 API 相同。

## 1.7 第一版建議技術

- Python 3.11+、FastAPI、Pydantic、SQLAlchemy/SQLite WAL，單機 Worker Process。
- 第一版 Event Queue 用 SQLite Durable Inbox/Outbox，單 Writer / transactional claim，需加上 lease epoch fencing；多機才改 PostgreSQL。
- Codex Python SDK `openai-codex` 用於 Domain Owner 的啟動、恢復和結構化事件。不得再依賴已移除的 `codex mcp-server` 當作 Codex 的被呼叫端。
- 外部 Harness 使用 SiliconForge 自己的 Python `mcp` SDK Server，優先提供 stdio local 接入，後續加上受認證的 streamable HTTP。
- Web React + TypeScript。復用現有自由模式的畫面概念，不能把 mock frontend 當成 production logic。
- OSS CAD Suite／固定 Container Profile；Windows 主機可用 WSL2 + Docker Engine 進行 EDA。
- OpenTelemetry 可作檢索與視覺化，但 SQLite Event Journal 為權威記錄。

## 1.8 Nonfunctional Requirements

NFR-01：無使用者 Harness 時仍能從已授權 Event 自主工作。
NFR-02：Restart 後不能重複產生外部寫入結果；不能遺失已持久化事件。
NFR-03：不同 IP / Ticket 的失敗互不連帶；資源限制與公平排程可設定。
NFR-04：EDA 作業預設無不必要網路／密鑰存取權。
NFR-05：所有重要配置均需版號與 SHA；高風險變更需批准。
NFR-06：原始 Log 可保留、可彙整，但不得存 Token、Secrets、完整敏感對話作為預設。
NFR-07：通知重送可容忍，展示端以 notification_id 去重；不承諾不存在網路斷線下的 Exactly-once delivery。


---

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


---

# 03｜Domain Owner 的 P-Stack 實作規格與開源 EDA 工作流程

## 3.1 技術方向

P-Stack 的方法沉入**每個 Domain Owner**，不是建立一個全域 P-Stack Orchestrator。Super Agent Runtime 只負責事件／狀態／授權／資源。Codex Domain Owner 以其專屬的領域 Skill 組合，在限定工作區調用臨時 Worker 與 EDA Job。父 Owner 對局部產物和整合品質負責，不能由 Temporary Worker 自行跨 Owner 改其他領域。

原版參考：`$architect`、`$arena`、`$swarm`、`$tdd`、`$interrogate`、`$blast-radius`、`$show-me-your-work`、`$reflect`、`$correct`。這些在 pstack-for-codex 中要求明確調用，且平行 Writer 必須隔離。SiliconForge 的 Owner Policy 才決定何時執行相應專業化程序。不能假設安裝後所有 Skills 就會自動生效。

## 3.2 Skill Contract 的統一界面

每個 Skill 必須提供：

```
name, owner, version, description,
trigger_criteria, input_schema, required_evidence,
allowed_tools, allowed_writes, allowed_workers,
procedure_steps, exit_predicate, failure_codes,
max_iterations, budget, telemetry_fields, output_schema
```

流程內的工具調用必須是透過 `EDA Job Contract`、`Peer Request` 或受控 Workspace 操作；Skill 不可以任意修改 Runtime 的 Route/Policy/Env。執行結果必須對應 `skill_run_id` 與 Evidence 或 `blocked_reason`，不能以完成一段思考作為 Skill Success。

## 3.3 P-Stack 對各 Domain Owner 的具體適配

| Owner | 內嵌方法 | 何時啟動 | 必須交付 |
|---|---|---|---|
| Spec | `silicon-architect`, `design-impact`, `interrogate` | 新 Spec／Change／Clarification | 版本化 Requirement、Latency、Protocol、可測試 Acceptance、Impact Graph |
| RTL | `rtl-arena`, `waveform-tdd`, `blast-radius`, `interrogate` | Spec 改動、RTL Repair、PPA Alternative | Candidate RTL、實作假說、變更 Diff、局部 Reproducer、選擇理由 |
| Verification | `verification-swarm`, `waveform-tdd`, `interrogate` | Regression Failure、新 RTL、Coverage Gap | Seed、Test ID、Waveform、Golden Model Comparison、Bug Signature、Coverage Evidence |
| Formal | `formal-triage`, `interrogate`, `blast-radius` | Candidate Ready、Property 變更、Proof Failed | Property-Requirement Mapping、Assumption、Proof Status、Counterexample |
| PPA | `ppa-arena`, `benchmark-checklist`, `design-impact` | Clock / Area Target、Candidate Ready | 同一環境與 Constraints 的可比 PPA Report、Critical Path、候選排名 |
| Integration | `show-me-your-work`, `interrogate`, `release-gate` | 全部必要 Gate 到齊 | Evidence Manifest、版本一致性、Release Decision、未解風險 |
| EDA Environment | `environment-reproduce`, `interrogate`, `correct` | Profile 缺失、Version Drift、Runner Error | Immutable Profile、Environment Digest、Smoke Test、兼容清單 |
| PDCA | `reflect`, `correct`, `interrogate`, `benchmark-checklist` | 重複失敗、停滯、成本異常 | Case、根因假說、隔離 A/B 實驗、差異報告、建議版本 |

### 範例 A：`rtl-arena`

1. Frame：接收同一 Approved Spec、Interface、Latency Bound、Toolchain Profile、Constraints。
2. Fan out：預設最多 3 個候選 Worker，分別在隔離 Worktree 中實作，各自提出 PPA 假說。
3. Pre-filter：執行 Lint、既有 Reproducer／Directed Tests；功能不過直接淘汰。
4. Cross-judge：獨立審查相同目標、約束有無偷換。模型評審只產生質疑，不能自行宣布最佳設計。
5. Evaluate：Verification／Formal 通過後執行 Yosys/OpenROAD，對同一 Fingerprint 比較可量測 PPA。
6. Pick：在硬約束全數滿足的候選中，根據明確排序規則選擇；不合格者不參賽。
7. Graft：如從淘汰方案採用部分概念，必須重新建立 Candidate 並完整再驗證。
8. Verify：輸出 Candidate SHA、Evidence、Loss / Tradeoff、Rejection Reasons，向 Owner Ticket 回報。

### 範例 B：`verification-swarm`

1. 先建立一個共同的 Golden Model／接口版本。
2. 對 Test Slice（APB Setup/Access、Reset、CRC32 reference、Random Sequence、Back-to-Back、Corner）平行處理；每個 Worker 有獨立 seed、work dir 和輸出路徑。
3. Aggregator 僅合併受檢驗的 test results，記錄失敗簽章、Test Coverage 和 Source SHA。
4. 若 Test 失敗，先最小化 Reproducer，再判斷是 RTL、Golden Model、Testbench 還是環境。
5. 可疑 Testbench 修正應由 Verification Owner 以 Spec Evidence 說明；不得因 RTL 不過就無依據地改 Expected Result。

### 範例 C：`formal-triage`

- Property 由 Requirement ID 追溯，明列假設和作用範圍。
- `PROVED`、`COUNTEREXAMPLE`、`UNKNOWN`、`TIMEOUT` 分離，後兩者不是通過。
- Counterexample 必須輸出可閱讀 Trace 或可重現資料；Property 弱化需新審查，不能私自放行。

### 範例 D：`ppa-arena`

- 比較必須 pin 同一 `lib_sha`、`constraint_sha`、`env_digest`、clock、corner、utilization 設定。
- `PPA_PASS` 至少包括 Timing Constraint 是否達標與標準化面積；有功耗資料時明列功耗的量測依據／品質。
- 若只使用 Yosys 面積和 OpenROAD Timing，應標示為 `ESTIMATED_PPA`，不得冒稱 Signoff 或實際功耗。

## 3.4 APB CRC32 Golden Design Contract

第一個 IP 使用 APB3 Slave + CRC-32/ISO-HDLC（反射 Polynomial `0xEDB88320`，Init `0xFFFFFFFF`，Final XOR `0xFFFFFFFF`，資料依 Byte 低位先處理）。標準 Check Vector `"123456789" → 0xCBF43926`，作為 Golden Model 與 RTL 必過的定值。

**Registers (可依文件實作，變更需修訂 Spec)**

| Offset | Name | Behavior |
|---|---|---|
| `0x00` | `CONTROL` | bit0 START 清除 CRC 到 Init；bit1 FINISH 鎖存可讀結果；bit2 CLEAR 清 status |
| `0x04` | `STATUS` | bit0 VALID，bit1 ERROR；Reset 全清 |
| `0x08` | `DATA` | APB Write 接收低位 `BYTE_COUNT` 個 byte，僅 Access Phase 生效 |
| `0x0C` | `BYTE_COUNT` | 1、2、3、4 有效；其他值回報 ERROR，不能變更 CRC |
| `0x10` | `RESULT` | FINISH 後回傳 Final XOR 的 CRC，VALID 未置位時固定回零 |

APB 時序：單一 `PCLK`，`PRESETn` 低有效，PSEL/PENABLE 規則；Access Phase 且 PWRITE 時才產生 Side Effect；APB Setup Phase 不得寫入資料。第一版可固定 `PREADY=1`，可透過後續 Spec 演進增加 Wait State，但不在 MVP 自行擴張。

Reference Model：純 Python，可接受 Byte Stream；每筆 APB Write 對應 1~4 bytes；Reset 中斷操作必須清除 VALID 與 CRC State，不得讀出上筆 RESULT。

**封閉的 MVP 範圍**：單 clock domain，單 APB slave，無 DMA、中斷、bus bridge、AXI、AES、SystemC 全 SoC 與多時鐘 CDC。在 APB CRC32 取得真實驗收後，才將 SystemC Reference 接為第二階段可選工作。

## 3.5 最低必要 EDA Matrix

| 類別 | Tool | Gate | 必存證據 |
|---|---|---|---|
| Syntax / Lint | Verilator | 0 errors，不可吞掉會影響功能的警告 | source_sha、指令、exit code、輸出 |
| Simulation | Verilator + cocotb | Directed + Random tests，全數 pass | Test ID、Seed、Waveform、Report |
| Golden Reference | Python CRC32 | 123456789 與額外 Corner | expected/actual、Model SHA |
| Formal | SymbiYosys（搭配開源 Solver） | 必要 Properties 證明或 bounded 結果明確標示 | Property File、Engine、Assumptions、Result |
| Synthesis | Yosys | Netlist 可產生、無 latch（除非 Spec 允許） | Netlist SHA、Cells、Warnings |
| PPA | OpenROAD + 可用 Open PDK / lib | 固定約束、可比較實測數據 | SDC SHA、Lib SHA、Timing、Area、Environment |

部分 PDK／Lib 在開源工具上可能有授權及流程差異。Environment Owner 應選可合法使用的公開流程，並把限制記錄於 manifest。若某公開實體設計套件不可用，先完成 Synthesis 的可量化 Target，PPA Gate 暫列 `NOT_IMPLEMENTED` 並保留正式最終 Gate，不能把「無 PPA」當作成功。

## 3.6 必備 Verification Case

- T01：復位初始值、STATUS / RESULT 清零。
- T02：單 byte 及多 byte CRC32 定值。
- T03：資料 `123456789` 的標準向量。
- T04：APB setup 不產生 side effect。
- T05：Back-to-back APB 寫入，結果順序正確。
- T06：Reset in-flight：VALID 清除、不回報舊結果。
- T07：非法 BYTE_COUNT 不改 CRC 且 ERROR 置位。
- T08：FINISH 後 RESULT 穩定，直到下一次 START。
- T09：Random seed 可保存並重播，至少 10 組固定種子。
- T10：故意植入 Bug，使 Directed Regression Fail；修復後同一 Reproducer Pass。

Formal：針對 reset、setup side effect、非法 Byte Count、VALID/RESULT、不可越界讀取等性質，建立清楚的 Property ↔ Requirement mapping；涉及資料正確性的完整等價性，可採 Reference Equivalence 或 bounded proof，明確說明證明邊界。

## 3.7 EDA Environment Owner 的工作契約

- 所有 Runner 必須指定 `profile_id`、`image_digest`、tool versions、lib/PDK SHA、可用工具、`profile_status=VERIFIED`。
- 只有 Environment Owner 可以提交新 Profile，必須先 smoke test，並由既定 Policy 准予 promote。
- Profile 舊版不覆寫。正在執行的 Job pin 舊 Digest，後續版本切換不影響已跑的實驗。
- 缺 Tool／版本漂移回傳 `WAITING_FOR_ENV`，Environment Owner 修復完成產生 `ENV.PROFILE_READY`，Runtime 恢復原 Job。
- 不同 Domain Owner 不得執行 `pip install`、`apt install`、更改 Dockerfile、替換 Solver 來直接通過當前 Job。

## 3.8 整合 Release Gate

對相同有效 Baseline 的 `spec_rev + rtl_sha + env_digest + constraints_sha`，Integration 必須取得下列必要 Gate：Lint、Directed、Random Regressions、Formal 必要性質、Synthesis、PPA Target（後期里程碑）。任何 Gate `MISSING`、`FAIL`、`UNKNOWN`、`TIMEOUT` 或 Fingerprint 不一致，不得產出 `RELEASE_ACCEPTED`。

必須能看到可下載的 `release_manifest.json` 與每個原始報告的 SHA。最終「成功」只在同一 Commit 有完整 Evidence 且 Exit Criteria 全數通過時成立。


---

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


---

# 05｜Observability、Communication、PDCA 與 Dashboard

## 5.1 必須有五種權威資料

1. `Event Journal`：事件收到、驗證、路由、Fan-out、完成或隔離的不可變事實。
2. `Communication Ledger`：Peer Request、意圖、問答、拒絕、Human Approval 與任務關聯。
3. `Execution Traces`：Owner Turn、Harness、Skill、Worker、EDA Job、耗時、資源與退出碼。
4. `Decision / Evidence Records`：選了哪個方案、為何選擇、假說、驗證方式與工程原始證據。
5. `PDCA Improvement Records`：錯誤模式、重現條件、A/B 比對、版本變更、批准與回滾。

這些共同引用 `trace_id`、`ticket_id`、`run_id`、`event_id`、`parent_event_id`、`peer_request_id`、`skill_run_id`、`evidence_id`、`policy_version`、`harness_version`、`model_id`。

## 5.2 使用者要能從 Dashboard 看到

- Mission Overview：每個 IP 的 Current Revision、Active Ticket、Waiting Reason、最後有效成果、Stop Reason。
- Event Flow：Event Received → Route Decision → Owner Claimed → Skill → Peer Request / EDA Job → Next Event，具時間軸與因果圖。
- Agent Activity：Owner 啟動／等待／停止、Skill、Harness、模型、Token／成本（若可讀）、Lease、Heartbeat。
- Engineering Evidence：同一 Candidate 的 Simulation / Formal / Synthesis / PPA、有效期、指紋與不合格原因。
- Communication：所有 Owner 直接互通的工程請求與狀態，以及 Human 對話的正式操作摘要。
- Failure Analytics：同一 Bug Signature 被修了幾次、多少實際改善、無效迭代原因、成本與停滯時間。
- PDCA Board：待分析、提案、隔離實驗、待批准、已推出、已回滾。
- Approval Inbox：需要人類做決策的少量問題，附最小必要背景與選項。

Dashboard 是投影／Read Model，可用 Event Journal 重新建立；Dashboard 停止或刷新，不影響 Runtime。

## 5.3 量測指標

主要工程指標：`accepted_verified_releases`、`time_to_verified_release`、`reproducible_failure_resolution_rate`、`formal_property_validity_rate`、`ppa_target_achievement`。

自主性：`human_interventions_per_ticket`、`autonomous_completion_rate`、`resume_success_rate`、`stalled_runs_prevented`、`routing_without_main_rate`。

成本效率：`tokens_per_verified_release`、`eda_cpu_minutes_per_verified_release`、`wasted_retry_ratio`、`cost_per_progress_delta`。

品質／治理：`stale_evidence_rejection_count`、`scope_violation_block_count`、`unapproved_external_action_count`、`blocked_ticket_explanation_completeness`。

不能把 `agent_messages_sent`、`skills_used`、`commits_created`、`test_count_increased` 當成核心成功指標。

## 5.4 PDCA 工作流

- **Plan**：Process Improvement Owner 觀察到一種重複錯誤，形成可驗證假說，引用至少一個實際事件與工程證據。
- **Do**：在 Sandbox／版本化分支提出一個 Skill、Policy、Routing、Harness 或流程修正；不能同時改多個可歸因的變因。
- **Check**：固定相同案例、工具、規格與資源上限，執行舊版／新版對照，計算收斂率、成本、正確性，確認沒有退化。
- **Act**：符合量化門檻並經核准後推進版本；保留可回滾版本。結果失敗也保留，成為下一輪反例。

PDCA Owner 只有提案與隔離實驗權限，不可自行修改運行中的 Routing、正式驗收 Gate、已被批准的 Spec 或 Env Profile。

## 5.5 預設保存與安全

- 原始事件與批准紀錄為追加式；更正以新事件與前一紀錄建立關聯，不覆寫歷史。
- 長期保存 Policy、Decision、Evidence Manifest、摘要與 Failure Signature；巨大波形／原始 Token 記錄採設定化保留期限與 Artifact Store，不強求永不清理。
- 所有敏感路徑、憑證、使用者訊息等應使用最小化、可遮罩、權限內可追溯；不得在公開 Repo 自動上傳機密 RTL、PDK、完整 Prompt。
- 對外遙測與第三方服務預設關閉，獲授權才可啟用。
- 任何觀測服務故障不應阻止 Event Journal 的正確交易與 Owner 工作。

## 5.6 最低驗收示例

從一個 `SIM.REGRESSION_FAILED` 在 Dashboard 點開，應能看到：收到來源、Router 規則版本、Verification Owner 認領、使用的 Skill、失敗 Reproducer、Peer Request 目標 RTL、RTL Candidate SHA、EDA Run 的環境 Digest 與結果，以及 Integration 的最終接受或阻擋理由。重啟 Backend 後，這些關聯仍完整。

在「無效修復迴圈」情境，必須可以回答：為何 Runtime 判定沒有進展、嘗試了幾次、使用多少資源、下一輪 PDCA 的提案為何、誰有權批准，以及哪一版 Skill / Policy 對應這段歷史。


---

# 06｜實作計畫、依賴與交付順序

## 6.1 開發模式

由另一個 Coding Agent 自主完成規格內工作，盡可能連續推進，避免每個小步驟都要求人類接力。但**不能將規格擴張、未授權外部寫入、公開 GitHub Repo 建立、Budget 擴張、驗收降低**當成可自行批准事項。新功能要先對照 00／07 的 Requirement ID。相容的工程選擇可以自行決定並留下 ADR。

預設開發主機為 Windows，建議 WSL2 + Docker 執行開源 EDA；Backend 可在本機服務運作，未來再做跨主機。不要為了第一版導入 Kubernetes、Kafka、分散式資料庫或自建 CLI。

## 6.2 依賴圖

```
M0 Contracts & Bootstrapping
  ↓
M1 Durable Super Agent Runtime + Event Router + Watchdog
  ├───────────→ M2 MCP Gateway + Codex/Claude User Integration
  ├───────────→ M3 Domain Owner + P-Stack Skills + Codex SDK
  └───────────→ M4 EDA Environment Owner + Container Runner
                       └──────────────┐
M2 + M3 + M4 ─────────────────────────┴→ M5 APB CRC32 Real Closed Loop
                                          ↓
                                     M6 Spec / PPA / Formal / Multi-IP / Chaos
                                          ↓
                                     M7 Dashboard + PDCA + Release Candidate
```

M7 的 Dashboard Read Model 可在 M1 開始同步開發，但正式宣稱成功必須到 M7。每個 Milestone 單獨有測試，不能因為後續 EDA 還沒做好就跳過較早 Contract Gate。

## 6.3 可執行階段表

| Gate | 交付最小範圍 | 實際驗收 | Blocker 應對 |
|---|---|---|---|
| M0 | 目錄、ADR、Schema、Policy、路由表、Testing Harness、Mock Owner | CI 可跑 Schema + Architecture Contract Tests | 依 Source Pin 版本；不得自行換方向 |
| M1 | SQLite Event Journal、Inbox/Outbox、Router、Scheduler、Lease Epoch、Ticket、Watchdog、Restart、Crash Recovery | 多次投遞、重啟、舊 Attempt 隔離、Main Offline 等測試 | Worker 不穩先用純 Mock；決定性內核要先完整 |
| M2 | SiliconForge MCP Server，Codex 與 Claude Code 的 User Harness 裝載，Skill、Instructions、Approval、通知 Outbox | 從原生 Harness 讀寫同一 Project；關掉 Harness Runtime 仍處理事件；權限可驗證 | 版本不兼容使用官方 MCP SDK / 支援的 transport，不另寫對話 CLI |
| M3 | 3 個真實 Codex Owner（Verification/RTL/Environment），再擴 Spec/Formal/PPA/Integration/PDCA；領域 P-Stack Skills | 有結構化 Action、Peer Request、隔離 Worker、完整 trace | 模型或訂閱不可用，用顯式 Fake Harness 保留 M1；真實項列未完成，不冒稱 |
| M4 | EDA Environment、固定 Docker Profile、Verilator/cocotb/Yosys/SBY、證據 parser，後補 OpenROAD | 真實 Runner 執行並保存結果與版本；環境漂移阻擋／修復 | 缺 PDK 可先完成開源 RTL/Sim/Formal/Synthesis，不宣稱 PPA Gate 通過 |
| M5 | APB CRC32 Spec、Python Golden Model、RTL、Simulation Failure → RTL Fix → Regression / Formal / Synthesis | 真實注入 Bug，在使用者 Harness 離線時自主修復並通過 Gate | 若模型能力不足可給有證據的 BLOCKED，不能用假 EDA Pass |
| M6 | Spec Change、PPA Target、multi-IP、長時間／故障注入、OpenROAD 可比 PPA | 真實三條閉環 + Guardrail／Restart／並行隔離 | PPA 限制明列，合法 target 要能通過或有可重現理由 |
| M7 | Dashboard、Communication Trace、PDCA、Read Model 重建、正式 Release/Evidence Manifest | 功能全矩陣，E2E Demo，正式驗收報告與部署說明 | 任何關鍵 Gate 不過視為未完成 |

## 6.4 每個 Gate 的固定輸出

1. `git commit` 與 commit SHA。
2. 更新 `SILICONFORGE_WORKING_SYNC.md` 的 timestamp、milestone、mission_state、last_progress_at_utc、已測、未測、blocked、下一步。
3. 自動測試命令、Passed/Failed/Skipped 的精確數量、Runner Log 路徑與原始 Evidence SHA。
4. 何者為 Mock、何者為真實 Codex、何者為真實 EDA；隔離／正式環境區分。
5. 影響範圍、風險、是否需要人工核准。
6. 下一 Gate 所需最短路徑與保留的失敗重現。

建議 Worker 每有狀態變更或證據變更時即提交 Sync；長時間工作至少每 15 分鐘寫一次 heartbeat / `last_progress_at_utc`，但**Heartbeat 本身不算有效工程進展**。

## 6.5 工程實作策略與避免 Blocker

- **先用 v3 契約固定架構**：參考 v2.2 舊 Kernel 只用作原型證明，正式結構依 v3 改寫，禁止把 Hardcoded Routes 當 production 實作。
- **依賴套件不符**：先確認官方支持版本並 Pin，寫 Compatibility Matrix；不准靜默降級與驗收閘門。
- **Codex SDK 不可用**：可用官方 Codex `exec` 作為有界過渡 Adapter，正式 SDK 能力列缺口；不可改為自建 Agent 模型 Loop。
- **Claude Code 無法主動 Push**：Notification Outbox + Session Resume Sync 仍為基本正式能力，Push 是 Optional Feature。
- **開源 EDA 環境建立失敗**：優先由 Environment Owner 修 Dockerfile，跑 Smoke Test，產生可比版本；不讓 RTL/Verification Owner 自行安裝。
- **Regression 不收斂**：記錄 reproducible failure、停止 reason、提出方案，不能一直重建 Project。
- **PPA 無可用公開 PDK**：以可用的 OpenROAD / open library 建立有限範圍可比流程。若做不到，M6 不得宣稱通過，可保留其他通過階段。

## 6.6 推薦首輪任務分解（依序）

- Phase 1：Schema、AuthZ、Idempotent Event、Router、Lease Epoch、Ticket、日志。
- Phase 2：MCP Tool Surface + Codex / Claude User Integration Smoke Test。
- Phase 3：Codex Owner Adapter、P-Stack Skill Contract、Peer Request。
- Phase 4：EDA Profile + Runner + Golden Model + CRC32 RTL。
- Phase 5：實際 Simulation Failure Repair、Formal、Netlist、PPA。
- Phase 6：Dashboard、Chaos、PDCA、正式 Release。

各 Phase 可並行撰寫文件、測試與相互不干擾模組，但對共享 DB / API 的寫入需先結束 Contract Review，避免多 Worker 修改同一檔案衝突。階段門檻不可因趕進度而取消。

## 6.7 退出條件與交付評語

只有 M0 至 M7 的每個 Required Acceptance ID 都具備可重跑證據，才標記 `ACCEPTED`。如部分完成，狀態必須是 `PARTIALLY_IMPLEMENTED` 並清楚說明缺什麼。任何外部工具不可用時交可操作部署說明、有限證據與準確 Blocker，不可說「全部完成」。


---

# 07｜硬性驗收矩陣與證據規格

## 7.1 驗收基本規則

每個 Acceptance Case 必須有 `case_id`、`feature`、`preconditions`、`steps`、`expected`、`observed`、`status`、`evidence_paths`、`commit_sha`、`environment_digest`、`test_command`。可接受的狀態：`PASS`、`FAIL`、`BLOCKED`、`NOT_RUN`。不得用 `SKIP`、`NA` 或文字報告將 Required Case 偷偷當成 PASS。

驗收分層：A 類使用 Stub/Mock 驗證 Deterministic Runtime；B 類使用真實 Harness；C 類使用真實 EDA；D 類長期可靠性／治理。**同一 Case 只能宣稱自己實際驗證的層級**。Mock 19/19 Pass 不能替代 C 類 EDA。

## 7.2 A 類：Runtime / Event Contract（M0/M1 必過）

| ID | 必驗收行為 | 核心證據 |
|---|---|---|
| A01 | Main Agent 沒啟動時，trusted CI 送 `SIM.REGRESSION_FAILED` 直接 route Verification | Event → Delivery Owner、無 Main Activity |
| A02 | 事件持久化與 Delivery 同 transaction；模擬 Crash，不遺失 | DB Restart Record |
| A03 | 同 Idempotency Key + 同 Payload 不重複產生 Event | Receipt 等值與唯一數 |
| A04 | 相同 Key、不同 Payload 被 409 拒絕 | Conflict Log |
| A05 | Unknown Event / spoofed producer 進 Quarantine，不呼叫 LLM 自由判定 | Reason Code |
| A06 | Fan-out 到 Verification、Formal，各自獨立 Ack / Retry | 兩個 Delivery ID |
| A07 | Claim Lease 到期恢復、`lease_epoch` fencing，舊 Attempt 不得完成新結果 | Restart + Stale Worker 測試 |
| A08 | Ticket 一次 Turn 結束後仍可由新事件續跑 | Ticket ID 同一、Run ID 不同 |
| A09 | Backend / Worker Restart 之後繼續工作且不重複外部 Side Effect | Operation Receipt |
| A10 | 同時存在兩個 IP，A 卡住 B 仍能完成 | Parallel Trace |
| A11 | 新 Spec 覆蓋舊 Revision 後，舊 EDA Result 不能成為 Release Gate | Fingerprint Rejection |
| A12 | 相同 Failure Signature 反覆發生，第三次無有效進展後 Blocked | Watchdog Stop Reason |
| A13 | Agent 申請自行擴建不相干 Framework／外部 Repo 被拒絕 | Policy Violation |
| A14 | EDA Job 指回 registered requesting_owner，不能用事件 Payload 偽造 Owner | Job Registry Lookup |
| A15 | Runtime Budget 變更需要 Policy Version + AuthZ；Agent 不能改自己的限制 | Denied Change Audit |
| A16 | 實驗 Event Injection 與正式 Namespace 完全隔離 | Domain Isolation Log |

## 7.3 B 類：原生 Harness、MCP、Domain P-Stack（M2/M3 必過）

| ID | 必驗收行為 | 核心證據 |
|---|---|---|
| B01 | 從原生 Codex 透過 SiliconForge Skill/MCP 查詢 Ticket | Tool Call Transcript / Receipt |
| B02 | 從原生 Claude Code 查詢相同 Ticket，結果一致 | Tool Call Transcript |
| B03 | 從原生 Harness 提交已授權 Spec Intent，Runtime 記錄 Event 與 Scope | Event Receipt |
| B04 | User Harness 退出後，Owner 仍由 Runtime 喚醒 | Worker Run vs User Session Timeline |
| B05 | Codex Owner 使用結構化 Action 提交 EDA Job / Peer Request，未經 Schema 驗證則拒絕 | SDK trace + validation errors |
| B06 | Verification Owner 直接 Peer Request RTL，無 Main 介入 | Peer Ledger + Event Path |
| B07 | RTL Owner 的 `rtl-arena` 以隔離 Worktree 產生候選，候選功能不過不能選勝 | 3 Candidate Dir、Decision Evidence |
| B08 | Verification Owner 的 `verification-swarm` 可平行分工且獨立 Seeds，可合併結果 | Worker Receipt + Test Matrix |
| B09 | Formal Owner 對 `UNKNOWN/TIMEOUT` 不得宣布 Formal Pass | Gate Rejection |
| B10 | Harness Thread 遺失後以 Ticket Snapshot 啟新 Session，不遺失工作與批准 | Resume Trace |
| B11 | AI 回傳偽造 `HUMAN.APPROVED` 或 EDA_PASS 被拒 | AuthZ Audit |
| B12 | Notification 重要事件可去重，離線可讀、重新登入可續讀 | Cursor/ACK Test |
| B13 | Human Chat / direct Owner Chat 皆留下可追溯訊息與操作界線 | Communication Ledger |
| B14 | 無自建的 SiliconForge 自然語言 CLI 也可執行完整人類操作 | Install & Smoke Test |

## 7.4 C 類：開源 EDA 與晶片工程（M4/M5/M6 必過）

| ID | 必驗收行為 | 核心證據 |
|---|---|---|
| C01 | Env Owner 建立固定 Profile，Runner 可重現 tool versions、image digest | Toolchain Manifest + Hash |
| C02 | 普通 Owner 無法自行安裝／修改正式 Env | Denied Permission |
| C03 | Verilator + cocotb 真實執行 APB CRC32 定值和完整 Directed Tests | Real Runner Log、Seed、Waveform |
| C04 | Python Golden Model `123456789` 等於 `0xCBF43926` | Reference Unit Test |
| C05 | 修復之前某一故意 Bug 有可重現 Regression Fail | Test ID / Source SHA / Waveform |
| C06 | Verification → RTL → Verif／Formal 循環在 Main Offline 下真正自主修復並重新驗證 | Complete Trace + All Evidence |
| C07 | Reset 中途測試與 Formal 性質通過，不能回傳舊結果 | RTL SHA、Waveform、Property Proof |
| C08 | Yosys 真實產生可保存 Netlist 和 Cell Stats | Netlist SHA、Tool Log |
| C09 | 必要 Formal Proof 結果為 `PROVED`，或明確在限制下標示 Bounded Scope | Proof Report + Assumptions |
| C10 | OpenROAD 使用固定 Constraints/Library/Environment 得到可比 PPA | Timing、Area、SHA、setup path |
| C11 | PPA 目標修改後能自主發出 RTL Alternative，再完整驗證並比對 | Arena Evidence + new PPA Report |
| C12 | 新 Spec 運行中注入，舊 Candidate 不能混入新 Gate | Revision Transition Trace |
| C13 | Env Drift 擋下 Job，Env Owner 修復後自動恢復 | WAITING_FOR_ENV → READY → EDA_PASS |
| C14 | Release Manifest 僅採同版本、同環境、同約束且通過的報告 | Manifest Verifier |
| C15 | CLI 人類入口完全關閉時，仍能完成真實 EDA 交付 | User Session Closed Evidence |
| C16 | 真實 EDA 失敗不能被 mock 版本替代，Mock 模式有顯眼旗標與隔離 Namespace | Mode Stamp / Test |

## 7.5 D 類：自由事件、可靠性、觀測、PDCA（M6/M7 必過）

| ID | 必驗收行為 | 核心證據 |
|---|---|---|
| D01 | IDLE 之後注入新 Event，仍可恢復同 IP 的工作 | Ticket Revision 變遷 |
| D02 | AUTO 運行期間連續注入 Spec、Sim Fail、PPA Target，均被持久化、正確排序與交接 | Timeline / Replay |
| D03 | Main/User Harness 離線、Runner Crash、Backend Restart 組合之後可繼續 | Chaos Test Evidence |
| D04 | 完成及 Blocked 都只在重要事件通知人類，一般 Heartbeat 不騷擾 | Notification Audit |
| D05 | 從 Dashboard 任何失敗事件可追至 Owner、Skill、Harness、EDA Report、下一事件 | Trace Graph |
| D06 | Event / Peer / Decision / Evidence 重啟後可完整重建 Dashboard Read Model | Deterministic Rebuild |
| D07 | 重複失敗產生 PDCA Proposal，對照舊版／新版可比，不能擅自發布改善 | Proposal + A/B Log |
| D08 | Skill / Policy 改版可 Rollback，舊 Ticket 保留版本歷史 | Versions / Rollback Receipt |
| D09 | 事件壓力測試至少 1000 件 Mock Event 無資料遺失、無重複外部效果 | Fuzz/Stress Report |
| D10 | 測試失敗明確顯示 FAIL，不能以 Agent 自我聲明覆蓋結果 | Test Harness Anti-cheat |
| D11 | Token / EDA 用量超過預算時阻擋新工作，其他 Ticket 不受無關阻擋 | Budget / Fairness Report |
| D12 | 產物沒有自動發布公開 repo、敏感 RTL、PDK 或任何秘密 | External Side Effect Audit |

## 7.6 完成判定

- M0 Gate：Contracts Schema、配置校驗、A0 參考測試通過，且建立 A01 至 A16 的正式測試空殼與執行計畫；M1 Gate：A01 至 A16 以真正 Runtime 實作的自動測試全部通過。
- M2 / M3：B01 至 B14 通過，是真實 Harness，不是 mocked Console。
- M4 / M5：C01 至 C09、C13、C14、C16 通過，其中 C06 是首要里程碑。
- M6 / M7：全部 C、D Required Case 通過，A/B regression 仍全綠。

**最終不可減少的三個 Demo**：

1. `Spec Change → RTL → Simulation + Formal → Synthesis + PPA → Release`，中途人類無需反覆催促。
2. `Simulation Bug → Verification Triage → RTL Fix → Same Reproducer Pass → Release`，Main 關閉。
3. `PPA Miss → RTL Arena → 功能等價與時序重驗 → 可比 PPA`，若不可達可正確 Blocked 並給證據。

另外必備負面 Demo：無效迴圈被停、擅自框架擴張被拒、環境故障恢復、舊 Evidence 不可混用、人類批准不被模型偽造。

## 7.7 Acceptance Report 格式

最終需提供 `reports/ACCEPTANCE_REPORT.md` 及機器可讀 `reports/acceptance.json`；逐 Case 包含 `id, layer, result, test_command, evidence_sha256, commit, elapsed, notes`。任何 Required Case 未跑、沒有檔案路徑、沒有實際 Runner / Harness 證據，都不得稱總驗收通過。Mock 的 19／19 或瀏覽器 28／28 只是既有示意原型，**不繼承為本版真實整合 PASS**。


---

# 08｜交付給 Coding Agent 的完整工作命令

## 直接執行指令（可直接複製到 Codex / Claude Code）

> 你是 SiliconForge 的 Coding Agent Implementation Lead。請將這個 Repository 內 `README.md` 與 `docs/00` 至 `docs/09`、`contracts/`、`config/`、`skills/` 視為完整需求與驗收契約。先讀主旨、不可變更架構、驗收矩陣，再實際實作。不要再提出另一套自主 Agent 架構、另外開發聊天 CLI、把 Main Agent 做成中央工程仲裁者，也不要因為要快速展示，就把 Mock EDA 當成真正工程完成。
>
> 請在現有 Repository 直接推進 M0 至 M7。主優先順序：正確的 Event Runtime、Owner 決策權、Harness 原生整合、EDA 環境隔離、真實 CRC32 自主閉環與實際驗收。你有權在已授權專案範圍內自行進行一般檔案修改、測試、局部分工與重跑，但不得未經人類批准新建公開 Repository、對外發布、擴權、變更正式驗收標準、擴張產品範圍或任意增加持久監控任務。
>
> 第一個交付是讓 `tests/` 和機器可讀 Contracts 正常通過，接著完成真正 Codex / Claude Code Client 的 MCP 連接與 Agent Owner 的運行，再進入真實開源 EDA。可用平行 Worker 但需 Worktree 隔離，不能為了產生更多 Activity 而建立無用任務。任何 Blocker 都必須先分類為 Harness / Environment / EDA / Design / Spec / Permissions，至少自主嘗試允許的修復，不要把人類當作每一步中繼站。
>
> 每個里程碑都要回報狀態、commit、測試精確數量、驗證命令、證據 SHA、未驗收部分、風險、需核准事項與下一步。持續更新 `SILICONFORGE_WORKING_SYNC.md`，讓人類能不依賴聊天知道真實狀態。原有 v2.2 與 v2 自由模擬器只作參考，v3.0 文件優先。
>
> 最終驗收是實際的三條 E2E 工程閉環、負面 Guardrail、Main 離線、Crash Recovery、可重放的 Report、同 Fingerprint Evidence Gate，所有必要 Acceptance ID 全 PASS。若遇到無法在本機完成的必要 EDA／權限／模型環境，保留清楚部署步驟及失敗日誌，標示 `PARTIALLY_IMPLEMENTED`，不得自行宣稱完成。

## 不准忽略的驗收重點

1. A01 / B04：沒有 Main Agent 仍能分派並執行。
2. A07 / A09：Backend Restart + Lease Epoch Fencing，不能重複副作用。
3. A12 / A13：無效迴圈和框架擴張必須被阻擋。
4. B06 / B07 / B08：P-Stack 是 Domain Owner 的實際工作方法，真有隔離候選與證據。
5. C06：真實 Bug 在 Main 關閉時可以自動修復、重跑、交付。
6. C13：EDA Profile 漂移由 Environment Owner 修復，其他 Owner 不能各自安裝工具。
7. D02 / D05：自由注入事件時能看見因果關係和完整 Dashboard／PDCA 紀錄。

## 每個 Milestone 的回覆格式

```
Status: IMPLEMENTING | VERIFIED | BLOCKED | PARTIALLY_IMPLEMENTED
Milestone: Mx
Commit: <sha>
Implemented: <what changed>
Executed Tests: passed N / failed N / not-run N
Real vs Mock: <distinguish explicitly>
Engineering Evidence: <paths + SHA256 + tool/version>
Runtime Evidence: <event/trace/ticket IDs>
Risks and Unresolved: <specific>
Approval Needed: <none or exact scoped decision>
Next: <work that can be completed without further human relay>
SYNC Updated: <UTC timestamp>
```

## 終止條件

應持續自主推進至正式可驗收成果，或遇到真正需要人類權限／外部資訊的 Blocker。不能以「已寫好 Spec」、「完成 50 個 Unit Tests」、「Demo 動畫可以播放」作為正式完成。失敗需要可重現證據，不應藏掉。


---

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


---

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
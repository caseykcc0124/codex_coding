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

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

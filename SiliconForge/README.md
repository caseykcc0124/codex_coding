# SiliconForge v3.0：Autonomous Chip Engineering Framework

這是可交付 Coding Agent 的正式規格基準，並非已完成的 Super Agent 或 EDA 平台。

**GitHub 基準：** `caseykcc0124/codex_coding` 的 `main` 分支，`SiliconForge/` 專案目錄。此目錄與 KA-DMM 隔離。

## 立即開始

1. 閱讀 [CODING_AGENT_START_HERE.md](CODING_AGENT_START_HERE.md) 及 [AGENTS.md](AGENTS.md)。
2. 閱讀 [主旨與不可變更原則](docs/00_MISSION_AND_BOUNDARIES.md) 和 [58 項驗收矩陣](docs/07_ACCEPTANCE_MATRIX.md)。
3. 依 [工作指令](docs/08_CODING_AGENT_WORK_ORDER.md) 和 [里程碑](docs/06_IMPLEMENTATION_ROADMAP.md) 自主實作 M0 至 M7。
4. 每 15 分鐘與重大 Gate 即更新 [SILICONFORGE_WORKING_SYNC.md](SILICONFORGE_WORKING_SYNC.md)，附 commit、真實測試數、證據與下一步。
5. [機器可讀驗收追蹤表](manifests/ACCEPTANCE_TRACKER_TEMPLATE.json) 所有正式 Case 預設 NOT_RUN，必須有真實證據才能標 PASS。

## 不可違反

* Super Agent Runtime 由持久化事件、路由、Watchdog 與 Recovery 管理自主性，不需要 Main Agent 常駐。
* P-Stack 方法沉入 Spec、RTL、Verification、Formal、PPA、EDA Environment 等 Domain Owner。Main 只做人類介面、資訊與協調。
* 使用者使用原生 Codex／Claude Code，採用 AGENTS.md、Skills、MCP 與 Hooks；**不可自造聊天 CLI**。
* EDA 環境由專職 Environment Owner 管理。Simulation、Formal、Netlist、PPA 的結果必須是同一 Fingerprint 的可重現證據。
* 零有效進展、重複失敗、框架擴張、預算／工具權限越界時必須停止，保留原因和 PDCA 資料。

## 文件與目前狀態

[整合規格（完整 00–10 章）](spec/SiliconForge_v3_0_Full_Implementation_Spec.md)，[詳細的事件生命週期](docs/02_EVENT_RUNTIME_PROTOCOL.md)，[Owner P-Stack 規格](docs/03_OWNER_PSTACK_EDA_WORKFLOWS.md)，[MCP／Harness](docs/04_HARNESS_MCP_HUMAN_INTERFACE.md)，[Dashboard／PDCA](docs/05_OBSERVABILITY_PDCA_AND_DASHBOARD.md)。

本次 GitHub 基準僅發布規格、協定配置、正式驗收資料與交付入口。先前 A0 參考程式在本地測得 25/25 PASS，但**不等於正式 Runtime 或真實 EDA 的驗收**。正式驗收請看 Status Sync。

推送日期：2026-11-07T08:04:27.510Z。同步檔將記錄實際進展；Heartbeat 不視為 Engineering Progress。

# SiliconForge v3.1 正式規格增補：Parallel Exploration / Multi-Owner Instances

本文件與 v3.0 完整規格書共同構成正式實作基準。**v3.1 為最新有效架構補充**，v3.0 的主旨、Super Agent Runtime、EDA Environment Owner、Harness-native integration、P-Stack 專業 Skill 仍全部有效；若先前文字暗示單一 Role 只能有一個 Owner，改以 v3.1 的多 Owner Instance 模型為準。

## 主要規格

1. Role、Owner Instance、Branch、Candidate、Agent Run 使用獨立身份和可持久化生命週期。
2. 同一 Requirement 可以平行探索 Performance、Low Power、Area 等分支，並在已授權的 Depth/Quota 內再次 Fork。
3. Super Agent Runtime 是事件路由、Admission/Quota、Lease/Recovery、Branch Registry 的權威服務，但不替各 Domain Owner 進行工程設計決策。
4. Domain Owner 以自己的 Codex/Claude Harness 和領域 P-Stack Skills 工作；各候選 Worktree 和 EDA Evidence 隔離。
5. 受控 Git Merge 或 Cherry-pick 使用正式 Merge Proposal，新 Merge SHA 必須重新通過 Required Simulation/Formal/Synthesis/PPA Gate。
6. 多目標比較必須先通過硬性 Gate，PPA 条件一致才比較 Pareto；未授權權重不由模型自行創造。
7. Event Journal、Owner Instance、Branch Lineage、Artifact Fingerprint、Decision/Stop/PDCA 必須可以在 Dashboard 完整追溯。
8. Branch Fork/Iteration 有 Budget 和 Watchdog，單 Branch 失敗不得停掉所有探索。

## 權威實作文件

- [12｜並行探索架構、資料模型與事件、Git 治理](../docs/12_PARALLEL_EXPLORATION_ARCHITECTURE.md)
- [13｜20 項新增 Required Acceptance](../docs/13_PARALLEL_EXPLORATION_ACCEPTANCE.md)
- [14｜M1X、M3X、M6X 實作工作藍圖](../docs/14_PARALLEL_EXPLORATION_IMPLEMENTATION.md)
- [06｜完整實作路線](../docs/06_IMPLEMENTATION_ROADMAP.md)
- [07｜正式驗收矩陣](../docs/07_ACCEPTANCE_MATRIX.md)
- [08｜Coding Agent 指令](../docs/08_CODING_AGENT_WORK_ORDER.md)
- [Exploration Policy](../config/exploration.yaml)
- [機器可讀 Acceptance Tracker](../manifests/ACCEPTANCE_TRACKER_TEMPLATE.json)
- [開發狀態權威同步檔](../SILICONFORGE_WORKING_SYNC.md)

## 驗收與版本

原有 A01–D12 共 58 個 Required Cases，新增 E01–E20 共 20 個 Required，**總計 78**。規格發佈不意味任何實作或工程驗證已完成。E 類需要真實分支／Harness／EDA 的項目均不可由模擬結果取代。

GitHub：caseykcc0124/codex_coding，main，SiliconForge/。不可另開專案。

# SiliconForge v3.1 正式實作基準：多 Owner Instance／平行設計探索

本檔是 SiliconForge 最新正式交付規格入口。原 [v3.0 完整實作規格](SiliconForge_v3_0_Full_Implementation_Spec.md) 保留為基礎與歷史快照，v3.1 新增的條款對 Owner 單例、Branch、Merge 與驗收項目有優先效力，未被修改的 v3.0 條款全部仍有效。

## 核心新增要求

同一 Requirement 可以同時展開 Performance、Low Power、Area 等多條獨立設計方向，每條 Branch 綁定不同 Owner Instance、Git Worktree、事件流、資源配額與獨立 Verification、Formal、PPA Evidence；分支可以再 Fork、淘汰、比較與受控 Merge。Merge 後必須在新的 SHA 上跑完整 Gate。

Super Agent Runtime 維護 Exploration DAG、事件路由、Budget、Lease、Crash Recovery 和 Watchdog；P-Stack Skills 沉入每個實際工作的 Owner Instance；Main Agent 只負責人類對話與資訊查詢，不能作工程裁決。

## Coding Agent 必讀

1. [原始任務主旨及禁則](../docs/00_MISSION_AND_BOUNDARIES.md)。
2. [Parallel Exploration 架構規格](../docs/12_PARALLEL_EXPLORATION_ARCHITECTURE.md)。
3. [E01 至 E20 新增硬性驗收](../docs/13_PARALLEL_EXPLORATION_ACCEPTANCE.md)。
4. [M1X、M3X、M6X 詳細實作藍圖](../docs/14_PARALLEL_EXPLORATION_IMPLEMENTATION.md)。
5. [完整 78 項驗收規格](../docs/07_ACCEPTANCE_MATRIX.md) 和 [機器可讀驗收表](../manifests/ACCEPTANCE_TRACKER_TEMPLATE.json)。
6. [探索政策](../config/exploration.yaml) 與 [事件契約](../manifests/EXPLORATION_EVENT_CONTRACT.json)。
7. [正式 Coding Agent 指令](../docs/08_CODING_AGENT_WORK_ORDER.md) 與 [唯一進度同步](../SILICONFORGE_WORKING_SYNC.md)。

## 驗收與任務範圍

既有 58 項 A01–D12 全保留，新增 E01–E20 共 20 項，**正式 Required Cases 為 78 項**。新規格尚未通過實作驗收，不得將文檔完成或 A0 Mock 測試當作真實 EDA／Harness／Branch 成果。

沿用現有 Repository 的 `SiliconForge/` 專案，不新建獨立 Repo，不重建專用對話 CLI，不擅自擴充 Scope、設計目標或 Budget。

初始 MVP 的同一 Requirement 應有三條同時進行的 Performance、Low Power、Area Branch，且其中一條再分叉；三路的 RTL、Simulation、Formal、PPA 證據必須獨立，同時可管理血緣、選擇、合併和失敗恢復。
# 14｜Parallel Exploration 實作藍圖、狀態機與交付順序

## 14.1 產品責任切割

- **Super Agent Runtime**：`ExplorationCoordinator` 是一個**確定性的後端 Domain Service**，持久化 Explorer Graph、發 Fork command、建立 Owner Instances、分配 branch budget、排工作與恢復。它不能替 RTL 或 PPA 作工程判斷。
- **Domain Owner Instances**：對特定 Branch + Ticket 自主工程判斷。相同 Role 可並發多個 Instance，P-Stack 專業 Skills 留在每個 Instance 裡，可於其分支中再 Spawn Workers 和提出 Fork。
- **EDA Environment Owner**：唯一管理 Verified Toolchain Profile 與版本切換。不同 Branch 可 pin 不同已批准 Digest 做探索，但跨 Profile 的 PPA 比較必須標 `INCOMPARABLE`。
- **Git Workspace Service**：受權限、quota 和 expected_sha 控制的 `fork/create_worktree/commit/propose_merge/merge/archive`，不允許 Owner shell 直接操作 main。
- **Comparison Projector**：讀取不可變 Evidence，生成可比性矩陣與 Pareto frontier；不冒充技術仲裁者。
- **Spec / PPA Domain Decision Owners**：各自處理需求語義和 objective trade-off；Integration Owner 對 merge SHA Gate 負責。
- **Dashboard / External Harness**：可查詢探索圖、同步狀態、提交經授權的探索意圖；Human／Main 不需保持 Session。

## 14.2 M3X 與 M6X 插入點

在現有 M0–M7 路線中，不另起平行專案，不延後現有 Runtime 核心：
- **M1 後立即做 M1X**：DB Migration、Exploration/Branch Registry、Instance Router、Git Workspace Service、append-only lineage + transactional outbox。驗收 E01–E08、E09 的隔離部分。
- **M3 後做 M3X**：多 Instance Codex Owner、每分支 P-Stack Skill、EDA Job Branch Fingerprint、Graph resume、對外 MCP query。驗收 E01–E10、E17、E19。
- **M5/M6 整合做 M6X**：3 分支真實 CRC32 測試、Formal、PPA 比較、Pareto、merge 後 re-gate、故障注入及 E20。
- **M7**：Dashboard 的 cohort/branch timeline、並行資源花費與 PDCA 策略比較。

原 M0–M7 全部仍須完成，且不可把增加的並行測試無限制擴張成另一個 Framework。

## 14.3 REST/MCP/內部 Command 最小集合

- `request_exploration(requirement_id, spec_revision, objectives[], constraints_sha, budget_scope_id, initial_fanout, policy_version)`。
- `fork_branch(exploration_id, parent_branch_id, expected_parent_head_sha, objective, reason, scope)`。
- `list_explorations(project_id?, requirement_id?)`、`get_lineage(exploration_id)`、`list_owner_instances(branch_id?)`。
- `submit_candidate(branch_id, source_sha, spec_sha, design_contract_sha)`。
- `request_branch_comparison(exploration_id, candidate_ids[], comparison_policy_sha)`。
- `propose_merge(target_branch_id, source_branch_ids[], expected_heads[], rationale)`、`evaluate_merge(merge_id)`、`apply_merge(merge_id, approved_authorization)`。
- `archive_branch(branch_id, reason)`，只有不再有活躍 Lease 且完成保留政策時允許釋出 Worktree。

所有 mutating Command 都有 `operation_id`、`actor_identity`、`expected_revision`、`idempotency_key`，經單一 AuthZ/Policy handler 寫入 Transactional Outbox，並回傳 Event/Command IDs。MCP 不得直接開放任意 `git push` 或 `shell exec`。

## 14.4 必須支援的 Branch Event Family

`EXPLORATION.REQUESTED`、`EXPLORATION.STARTED`、`BRANCH.FORK_REQUESTED`、`BRANCH.CREATED`、`BRANCH.OWNER_ASSIGNED`、`BRANCH.CANDIDATE_READY`、`BRANCH.EVIDENCE_READY`、`BRANCH.BLOCKED`、`BRANCH.STALE`、`BRANCH.ARCHIVED`、`BRANCH.COMPARISON_READY`、`BRANCH.MERGE_PROPOSED`、`BRANCH.MERGE_CONFLICT`、`BRANCH.MERGED`、`BRANCH.MERGE_REVERIFY_REQUIRED`、`BRANCH.MERGE_REVERIFIED`。

所有事件使用既有 `event_id, type, producer_identity, correlation_id, causation_id, idempotency_key, policy_version`，新增 `exploration_id, branch_id, candidate_id, owner_instance_id, expected_head_sha`；對 EDA 事件還需 `job_registry` 反查，以阻止偽造。Branch 層級的 Event 在路由前需先驗證 Registry 以及 Actor scope。

## 14.5 典型資料庫交易

`request_exploration`: 驗證 Spec、Scope、Quota → insert exploration + initial branches + reservations + events + outbox 同一 transaction → 工作佇列創建 instances → Git Service 建 Worktrees → ready ack。

`submit_candidate`: 取 branch write lease + expected_head_sha compare-and-swap → Git commit → immutable candidate registry → 發 `RTL.CANDIDATE_READY` (branch scoped) → Verification/Formal/PPA fanout。

`merge`: 取得 targets 的租約、驗證 source/target current heads，Git 執行受控 merge → 註冊新 SHA + lineage edge → 發 `MERGE_REVERIFY_REQUIRED` → 重新排所有必需 Gate → Integration 驗證完畢才允許 Release。中途 crash 可由 operation receipt 恢復，不可重複 merge / overwrite。

## 14.6 與現有資料相容的 Migration

現有 `owner_registry` 的 `role` 區分新增 `owner_instance_id`；所有已存在 Ticket、Event、EDA Job 要有對應 `exploration_id`、`branch_id`；對歷史單分支項目可以建立 `legacy-singleton` Cohort，但不能把 legacy 邏輯留在新 Router 的主要執行路徑。提供向後相容的讀取及 migration test；不得把未標 branch 的舊證據視為跨分支可共用。

## 14.7 操作與 Dashboard

要求有 Exploration Graph（可折疊 Branch Tree / DAG）、每分支 Timeline、Owner Instances（役別與身份不同）、Git head、證據 Gate、PPA Pareto 圖、Resource Budget、Active / Blocked / Stale / Merged，以及比較與合併決策紀錄。Web 是觀測與授權入口；自然語言仍用 Codex／Claude Code + SiliconForge MCP，不建立新聊天 CLI。

## 14.8 不能聲稱完成的情況

三個 Prompt 異步生成幾份 RTL，沒有分支和 Repo Worktree，不能宣稱完成。
三個 Git Branch 共用一份驗證報告，不能宣稱完成。
三條獨立分支已 Pass，但合併後未重驗，不能宣稱完成。
每個 Branch 都有 token heartbeat，但沒有更好的 Evidence，不能宣稱工程進展。
Dashboard 有漂亮的 Branch 圖卻無法查出 Git SHA、Event 與 Evidence，不能宣稱完成。

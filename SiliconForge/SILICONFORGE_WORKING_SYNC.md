# SiliconForge Working Sync

```yaml
project: SiliconForge
architecture_baseline: v3.1
repository: caseykcc0124/codex_coding
repository_path: SiliconForge/
branch: main
status_updated_at_utc: 2026-11-07T15:07:21.796Z
last_progress_at_utc: 2026-11-07T08:04:27.510Z
mission_state: SPEC_PUBLISHED_AWAITING_CODING_AGENT
milestone: M0
current_owner: UNASSIGNED_CODING_AGENT
latest_baseline_commit: b376c89ff00daf627c2db93456243203d1706703
latest_agent_commit: null
latest_pr: null
acceptance_total_required: 78
acceptance_parallel_exploration: {passed: 0, failed: 0, not_run: 20, layer: E}
exploration_phase: SPEC_PUBLISHED_NOT_IMPLEMENTED
exploration_groups: 0
active_branches: 0
owner_instances_active: 0
pending_merge_proposals: 0
latest_exploration_event: null
tests_reference: {passed: 25, failed: 0, kind: MOCK_A0_ONLY, source_archive: source/A0_REFERENCE.tar.xz}
required_acceptance_total: 78
baseline_previous_required: 58
tests_parallel_exploration: {passed: 0, failed: 0, not_run: 20, kind: REQUIRED_REAL_GIT_AND_EDA}
exploration_implementation_state: NOT_STARTED
active_explorations: 0
active_branches: 0
blocked_branches: 0
merged_branches: 0
branch_lineage_evidence: []
tests_real_runtime: {passed: 0, failed: 0, not_run: 16}
tests_real_harness: {passed: 0, failed: 0, not_run: 14}
tests_real_eda: {passed: 0, failed: 0, not_run: 16}
tests_reliability_pdca: {passed: 0, failed: 0, not_run: 12}
real_codex_owner_integrated: false
real_claude_mcp_connected: false
real_eda_executed: false
web_dashboard_integrated: false
approval_needed: none
blocking: none_for_M0_development
next_action: Read spec/SiliconForge_v3_1_Implementation_Baseline.md; implement M0-M1 then M1X, M3X and M6X; run and update evidence for all 78 cases.
```

## 同步要求

- **每 15 分鐘至少更新一次 heartbeat**（僅活躍工作期間）；任何 Gate、阻礙、驗收變更、重要 Commit 應立即更新，並推送 GitHub。
- 每次更新明確區分 *Heartbeat* 與 *Effective Engineering Progress*。失敗與無進展須原樣保留。
- 必須記錄 `updated_at_utc`、`last_progress_at_utc`、`mission_state`、`milestone`、`latest_agent_commit`、`passed/failed/not_run`、Evidence SHA256、環境 Fingerprint、Blocking、需授權事項、Next。
- 更新前讀取 GitHub 當前內容／版本；不可無條件覆蓋其他 Writer 的進展，衝突應先合併。Coding Agent 對此檔負責，Main 不應代替工程判斷。
- 僅 78 個 Required Case 與實際報告符合時才可標整體 VERIFIED。
- **人類監督入口**：`SILICONFORGE_WORKING_SYNC.md` 及 `manifests/ACCEPTANCE_TRACKER_TEMPLATE.json`。

## v3.1 多分支同步要求（規格發布，尚未完成實作）

- 新增 E01–E20 共 20 項 Required Acceptance，全部 NOT_RUN；原 58 項不降低，總 Required 78。
- 每次 Fork/Merge/Compare/Stale/Blocked/Progress 記錄 exploration_id、branch_id、parent_branch_id、candidate_id、owner_role、owner_instance_id、Git ref、Head SHA、環境/Spec/Constraints Fingerprint、EDA Job/證據 ID 與實際 Outcome。
- 維持 branch/owner instance DAG；直接路由給同 branch 的領域 Owner，不透過 Main Agent 仲裁工程選擇。
- 主要進度欄位應可由機器讀取：active_branches、owner_instances_active、pending_merge_proposals、acceptance_parallel_exploration、latest_exploration_event；在正式系統建立後同步真實數字，不要以預設零代表取得進展。
- 只有新 Merge SHA 通過全部 Required EDA Gate 才能視為合併完成；任何來源分支的 Pass 不能重用。
- 需要人類協商的未定權重／授權修改應精確記錄 approval_needed，不得把人類當每日輪詢者。

## v3.1 Parallel Exploration 補充同步要求

- 規格更新只代表設計基準發布；目前 `mission_state`、`milestone`、原有 `last_progress_at_utc` 仍保持原值，不能誤報為 Coding Agent 已開始開發。
- 活躍工作時同步每個 `exploration_id/branch_id/owner_instance_id` 的 Git head SHA、狀態、證據、Stale、Merge、資源與 Blocker；匯總表可從 Event Journal 與 Branch Registry 重建。
- E01–E20 新增 20 項全為 NOT_RUN。只有真實執行符合驗收契約，才允許改為 PASS；工作檔不宣稱任何 EDA 改善數據。
- 請先閱讀 `spec/SiliconForge_v3_1_Implementation_Baseline.md`、`docs/12`、`docs/13`、`docs/14`，不得繼續按 Role Singleton 或舊 58 項標準實作。

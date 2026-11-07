# SiliconForge Working Sync

```yaml
project: SiliconForge
architecture_baseline: v3.0
repository: caseykcc0124/codex_coding
repository_path: SiliconForge/
branch: main
status_updated_at_utc: 2026-11-07T08:04:27.510Z
last_progress_at_utc: 2026-11-07T08:04:27.510Z
mission_state: SPEC_PUBLISHED_AWAITING_CODING_AGENT
milestone: M0
current_owner: UNASSIGNED_CODING_AGENT
latest_baseline_commit: SEE_GIT_HISTORY
latest_agent_commit: null
latest_pr: null
tests_reference: {passed: 25, failed: 0, kind: MOCK_A0_ONLY}
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
next_action: Read CODING_AGENT_START_HERE.md and implement M0; run tests and update this file with evidence.
```

## 同步要求

- **每 15 分鐘至少更新一次 heartbeat**（僅活躍工作期間）；任何 Gate、阻礙、驗收變更、重要 Commit 應立即更新，並推送 GitHub。
- 每次更新明確區分 *Heartbeat* 與 *Effective Engineering Progress*。失敗與無進展須原樣保留。
- 必須記錄 `updated_at_utc`、`last_progress_at_utc`、`mission_state`、`milestone`、`latest_agent_commit`、`passed/failed/not_run`、Evidence SHA256、環境 Fingerprint、Blocking、需授權事項、Next。
- 更新前讀取 GitHub 當前內容／版本；不可無條件覆蓋其他 Writer 的進展，衝突應先合併。Coding Agent 對此檔負責，Main 不應代替工程判斷。
- 僅 58 個 Required Case 與實際報告符合時才可標整體 VERIFIED。
- **人類監督入口**：`SILICONFORGE_WORKING_SYNC.md` 及 `manifests/ACCEPTANCE_TRACKER_TEMPLATE.json`。

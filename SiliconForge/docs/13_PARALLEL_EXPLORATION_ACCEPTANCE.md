# 13｜平行探索與合併驗收案例 E01–E20（v3.1 REQUIRED）

本章為 v3.0 原 A01–D12 共 58 個 Required Cases 的**增量**。總數變為 **78**。既有 PASS / NOT_RUN 狀態不由規格發布自動改變。E 類皆 `required=true`，並須加入兩個機器可讀 Tracker。

## 必要執行條件

1. A0/M1 可用 Stub Harness、Fake EDA 驗證路由、交易、隔離與恢復；這類執行只能標記為 `MOCK_PASS` 的開發備註，正式 E 類仍為 `NOT_RUN`。
2. 正式 E 類除 E01–E08 的 Runtime contract 測試外，E09–E20 必須使用真實 Git Branch/Worktree；E11、E12、E14、E16、E20 需真實 EDA 和源資料一致性證據，不得使用在瀏覽器規則模擬生成的 Pass。
3. 最低 `requirement_id=R_CRC_01`，Spec/Golden SHA 固定；建立 `performance`、`low_power`、`area` 三個並發 Branch，另由 performance 再 Fork 一個衍生 Branch。需要記錄所有 EDA Environment Digest 和約束 SHA。
4. 驗收紀錄須含 `test_command, branch_id, owner_instance_id, git_ref, head_sha, evidence_paths, evidence_sha256, env_digest, event/trace_id, result, elapsed, notes`；若 `NOT_RUN`，不能有虛構證據。

## Runtime／Graph（E01–E08）

| ID | 強制驗收項目 | 可觀測斷言 |
|---|---|---|
| E01 | 同 Requirement 3 條路線並行 | 3 個不同 branch_id、git refs 和 Owner Instance，同時處於 ACTIVE，至少 2 條在相交時間窗執行 |
| E02 | 同一 `owner_role` 有多個活躍 Instance | 同一時刻 ≥3 個 `rtl` Owner Instance，不會被 Role singleton 覆寫 |
| E03 | 父子分叉可再次分叉 | B1→B1a 保留 fork SHA、parent edge、depth，Graph 無環 |
| E04 | Event 按 Branch 路由 | Branch B1 的 `RTL.CANDIDATE_READY` 僅分派給 B1 的 Verification/Formal/PPA Instances |
| E05 | Runner Completion 回到原 Instance | `EDA.JOB_COMPLETED` 使用受信任 Job Registry，即便 Payload 假造 B2 也回 B1 |
| E06 | Branch 状态與事件重啟後無損 | SIGKILL / restart 之後 graph、pending jobs、lease epoch 均一致，舊 lease 不得 ACK |
| E07 | 同 Branch 同 Worktree 寫入排他 | 並發搶 Lease 只有 1 位成功；不同 Branch 可同時寫不同 Worktree |
| E08 | Fanout 重送與去重 | 相同 idempotency key 的 Fork/Event 只產生一次 Branch；各 subscribers 獨立 ACK / Retry |

## Git／EDA／選擇（E09–E14）

| ID | 強制驗收項目 | 可觀測斷言 |
|---|---|---|
| E09 | 受控 Git Worktree 建立及隔離 | 至少 3 個真實工作樹和獨立 Commit；B1 變更不影響 B2，拒絕跨 project checkout |
| E10 | 快照與血緣查詢 | API / Dashboard 可從 Requirement 追至每個子 Branch、Owner、Commit、Merge、EDA Evidence，且無孤兒 |
| E11 | 每 Branch 獨立驗證 | 三條路線各自有相同 Spec SHA 但不同 Candidate SHA 的真實 Simulation / Formal 結果 |
| E12 | PPA 可比性／Pareto | 相同 corner、constraints、toolchain、power assumptions 下完成 ≥3 候選對照；不具可比性則顯示 INCOMPARABLE |
| E13 | 受控 Merge／Conflict | 僅在合法權限與 head SHA 相符時進行 merge；衝突不會由 Agent 強制略過；產生 merge_event |
| E14 | Merge SHA 重新 Gate | 來源兩 Branch PASS 仍不足；在新 merge commit 上重新跑 Simulation、Formal、Synthesis、PPA 才能 Release |

## 自治、失敗與監督（E15–E20）

| ID | 強制驗收項目 | 可觀測斷言 |
|---|---|---|
| E15 | 一支 Branch 卡住不拖垮其他 Branch | B1 進入 BLOCKED，B2/B3 的 Job 繼續直到各自 Terminal |
| E16 | Spec Rev 更新使舊證據過期 | 注入新 Spec 後舊 Candidate/EDA Evidence 標 STALE，不能組成新 Release |
| E17 | 配額限制與禁止無限 Fork | 用滿 depth / fanout / shared budget 時拒 Fork，有事件與原因，不能自行提額 |
| E18 | 比較與選擇權限 | 未設定 tradeoff 權重時保留 Pareto 多方案或要求 Human，而不偷偷指定 Winner；Main 無合併權 |
| E19 | Dashboard／Event Trace 完整性 | 用 branch_id 能看到各 Owner/Skill/Token/EDA/Peer/子分支/失敗/選擇/merge 的完整因果圖 |
| E20 | 綜合自主驗證 | Main 與 User Harness 關閉，同一 Requirement 完成 3 路探索、至少 1 次二級 Fork、含真實 EDA、受控選擇與 Merge 後重驗，且通過 policy limits |

## 完成門檻

- `E01–E20` 每一項都要 `PASS`，若有任何 `NOT_RUN/FAIL/BLOCKED`，整體不得標 `VERIFIED`。
- 既有 A01–D12 58 項仍然有效，任何修改不能減少既有範圍。
- 1 個真正完整的多分支自主 Demo，且有 fail-injection 實驗（B1 故障、證據污染、過期 Lease、Merge Conflict、資源耗盡）。
- 不得把單一 Candidate 的 EDA Pass 計入另兩個 Candidate；不得因 LLM 給出「很可能合格」而略過正式 Gate。

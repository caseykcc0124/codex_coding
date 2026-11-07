# 12｜多 Owner Instance、並行探索圖與 Git Branch 治理（v3.1 REQUIRED）

## 12.1 為何新增這一層

SiliconForge 不是單一路徑的 `Spec → RTL → Verify → PPA` 線性迴圈。同一個 Requirement 在不改變其語義的前提下，可以同時展開 Performance、Power、Area、Balanced，甚至研究多個不同的微架構，且各自再分叉成新的候選。不同領域的 Owner 也可能同時有多個 Instance。**每一條路線具備完整、獨立、可驗證、可停止的工程生命週期。**

這是 v3.1 的核心要求，任何以「每個 Role 僅有一個 Owner Session」或「先選一條設計再開始驗證」取代多路探索的系統都不合格。P-Stack `arena` 是 Owner **內部**的候選探索方法，但跨 Role、跨分支與跨事件的長期並行探索由 Super Agent Runtime 統籌追蹤，不得把 P-Stack 誤當全域排程器。

## 12.2 不可混淆的五層 ID

| 名稱 | 唯一性、生命週期 | 作用 |
|---|---|---|
| `requirement_id` / `spec_revision` | Spec 主張與其不可變版號 | 說明各候選要滿足的共同功能契約 |
| `exploration_id` | 一組共同目標與預算的探索群組 | 保存比較基準、策略與 Pareto frontier |
| `branch_id` | 一條不可變血緣的設計路線；父子關係保留 | 原始碼分叉、比較、淘汰、整合 |
| `owner_instance_id` | `role` 於該 branch/ticket 的實際執行身分 | 可有多個 `rtl`、`verification`、`formal`、`ppa` 同時執行 |
| `agent_run_id` / `eda_job_id` | 每次具體 Harness / EDA 執行 | 可中止、重試、換模型、但不取代 Owner 身分 |

`owner_role` 是能力與權限集合，**不是單例執行個體**。相同 `role` 的 N 個 `owner_instance_id` 必須各自具備狀態、Inbox、lease、Skill 版本、模型決策、代碼工作區和 Trace。Owner Instance 並不必固定佔用一個 LLM Process。

## 12.3 參考 Exploration Graph

```text
Requirement R42 / Spec S7 / Constraints C3 / Env E5
  Exploration X12 (objective policy OP4, shared budget B7)
  ├─ Branch B0: approved baseline @ commit A1
  ├─ Branch B1: performance / Owner RTL#1
  │   ├─ Candidate C11 : pipelined CRC / RTL SHA P11
  │   │   ├─ Verification#1 job V11, Formal#1 job F11
  │   │   └─ PPA#1 job P11
  │   └─ Branch B1a: deeper pipeline / RTL#4
  │       └─ V1a, F1a, P1a, all pinned to B1a head
  ├─ Branch B2: low power / Owner RTL#2
  │   └─ Candidate C21 : clock-enable architecture / V21 F21 P21
  └─ Branch B3: area / Owner RTL#3
      └─ Candidate C31 : iterative datapath / V31 F31 P31

Comparison: only qualified, coherent evidence → Pareto frontier
Selection: authorized domain strategy + Integration Gate
Integration: controlled merge/cherry-pick → NEW SHA M1 → mandatory re-verification
```

同一 Requirement 在 3 條或更多路線同時探索，允許按政策再建立二級分叉。系統以圖追蹤依賴，不能靠 branch name 猜測對應關係。每個 Candidate 的驗證可以平行進行；每個 EDA Job 需保留自己的 Source/Spec/Test/Constraints/Env 指紋。

## 12.4 Exploration graph 的權威資料模型

第一版使用 DB Referential Integrity、append-only `exploration_events` 與快照投影：

- `explorations(id, requirement_id, spec_revision, objective_policy_sha, baseline_branch_id, constraint_sha, environment_profile_digest, budget_scope_id, status, created_by, created_at)`。
- `branches(branch_id, exploration_id, parent_branch_id?, fork_commit_sha, branch_ref, current_head_sha, depth, branch_objective, status, created_event_id, selected_at?, archived_at?)`。同一個探索群組內 `branch_id` 永不重用，parent 不能改寫，禁止環。
- `owner_instances(owner_instance_id, owner_role, branch_id, ticket_id, assigned_skills_sha, harness_policy_sha, status, lease_epoch, last_progress_at, checkpoint_ref)`。同 Role 多 Instance 合法。
- `candidates(candidate_id, branch_id, source_sha, design_contract_sha, changeset_sha, lifecycle_state)`。
- `eda_jobs(job_id, candidate_id, branch_id, requesting_owner_instance_id, source_sha, spec_sha, testbench_sha, property_sha, constraints_sha, env_digest, tool_versions_sha, seed, run_type, lease_epoch, status)`。
- `evidence(evidence_id, job_id, candidate_id, fingerprint_sha, pass_kind, result, artifact_sha256, immutable_uri)`。
- `merge_requests(merge_id, exploration_id, source_branch_ids[], target_branch_id, base_sha, source_heads[], proposed_merge_sha, review_evidence_ids[], authorization_ref?, status, merge_commit_sha?)`。
- `lineage_edges(edge_id, exploration_id, from_branch_id, to_branch_id, relation{FORK,DERIVE,CHERRY_PICK,MERGE,SUPERSEDE}, event_id, commit_sha?)`。
- `exploration_events(event_id, exploration_id, branch_id?, owner_instance_id?, causation_id, event_type, payload_digest, committed_at)`。

DB 必須強制 `(exploration_id, branch_ref)` 唯一、`owner_instance_id` 唯一、`(branch_id, candidate_id)` Referential Integrity；同一 Worktree 同時最多一個可寫 lease。不可用 Agent 回答內容直接修改 Git/DB 事實，所有提交都由受控 Git Service 驗證。

## 12.5 分叉、繼承與失效規則

1. 由 Spec/PPA 授權的探索提案指定 `requirement_id`、`objective_vector`、`hard_constraints`、`budget_scope`、`initial_fanout` 和 `max_depth`，Router 核准範圍內的探索不需每條詢問人類。
2. `EXPLORATION.REQUESTED` 由 trusted gateway / Owner 送進持久化 Inbox；`exploration service` 原子註冊 cohort、base sha 與授權預算。`BRANCH.FORK_REQUESTED` 需要 parent ref、expected head、衍生理由與 branch budget。
3. Git Service 執行 `git branch` + `git worktree add`，綁定一條 DB 的 branch_id；同時創建受限的 Owner Instance。工作區、EDA Artifact Prefix、Log 與 Lease 均以 `exploration_id/branch_id` 隔離。禁止直接工作在 main 或共用可寫 worktree。
4. Parent 若已更新，不能靜默改變 fork point；以 expected SHA 比對，衝突回傳 `BRANCH.BASE_MOVED`，由發起 Owner 重估。
5. Spec 或 Hard Constraint 改版時，舊分支/證據標 `STALE_REVALIDATION_REQUIRED`。舊報告保留作歷史，不可拿來為新 Requirement Release。
6. 不同分支的 RTL、Testbench、Formal Property、PPA Report 互不互換作 Gate；若共用一份 Reference Model，必須明確 pin 其 SHA。允許比較不同設計，但不允許「拼湊」不同 Candidate 的 Pass。
7. Branch 有生命週期：`PROPOSED → ACTIVE → EVALUATING → QUALIFIED → SELECTED → MERGING → MERGED`，或 `BLOCKED/REJECTED/ARCHIVED`；失敗、被淘汰仍保留血緣與 Evidence。Branch `QUALIFIED` 代表已有符合該方案的候選，並不等於允許 merge。
8. Branch 無進展停止只影響其子圖；只有 shared resource governor 可決定暫緩其他分支，不能因一個 Candidate 重試耗盡便停止整個 Requirement。

## 12.6 路由目標與 Peer Request

Runtime 使用兩階段確定性路由：
- `route_to_role`：事件政策指定 `owner_role`，如 RTL、Verification、PPA；角色不代表執行實例。
- `resolve_instance`：透過可信 `branch_registry / job_registry / peer_registry` 查 `exploration_id+branch_id+ticket_id` 的對應 `owner_instance_id`。不信任任意 Payload 中自稱的 owner。

`RTL.CANDIDATE_READY` fan-out 到**同一 candidate branch**的 Verification、Formal、PPA Owner Instances，各自獨立 ack/retry；`EDA.JOB_COMPLETED` 由 `job_registry.requesting_owner_instance_id` 回投原發起 Instance。`PEER.REQUEST_CREATED` 目標指定受認證的 owner_instance_id，或者在同 Branch 的 Role 中 deterministic resolution，不能發到另一個 Branch 的相同 Role。跨 Branch Peer Request 必須明確聲明 `cross_branch=true`、來源與目的、只讀 Evidence 分享及政策授權。

同一 `exploration_id` 的比較事件可發送給 Comparison Service + PPA/Spec Domain Decision Owner，但它們只能建議或作已授權的工程選擇。Main Agent 沒有候選評分、分支合併及技術仲裁權。

## 12.7 Git Branch/Worktree 與 Merge 規約

- 使用獨立命名空間 `sf/<exploration_id>/<branch_id>-<slug>`；git ref 與 branch_id 綁定，slug 只供人讀。
- Worktree 檔案系統須限定在專案受控根目錄；禁止非本專案的清理命令，禁止 force-push 或重寫已發佈的 lineage refs。
- 只有 Git Service 可受控建立、merge、archive；Owner 可以提出 Merge Proposal，不能直接推送 main。權限來自 Actor Policy，而不是自稱是 merge agent。
- ```MERGE``` 前檢查兩端 immutable head、Spec SHA、硬性 Constraint、Env／PDK 條件；三方合併衝突轉 `MERGE.CONFLICT`，不得以 LLM 自動接受所有衝突。可由受限 Domain Owner 提修補候選，重新走審查和驗證。
- Merge/Cherry-pick 後 `merge_commit_sha` 為新 Candidate，**源分支先前的 Simulation/Formal/PPA Pass 不可直接繼承**；全部必要 Gate 必須在整合後的新 SHA 重新執行。若先將多個分支的 RTL 合併、才產生真正的 target SHA，驗收必須綁定該 SHA。
- Branch 選擇不等於自動刪除 loser；保留可回溯 Artifact 與紀錄，依留存政策再 Archive；遞迴清理不得刪除未決 Peer/EDA Jobs。

## 12.8 候選比較、Pareto 与工程權限

- 多目標向量包括 `performance`、`power`、`area`，可以加入 latency、frequency、energy、cell_count；先通過功能正確性、Formal 必要條件和所有 hard constraints，才有資格比較。
- 比較必須披露 workload、constraints、lib/PDK、toolchain、process corner、clock/mode、switching activity、power estimation confidence；不具可比性的資料只能 `INCOMPARABLE`，不准宣稱勝出。
- 對無法單一排序的候選，保存 Pareto frontier，多個方案可同時 `QUALIFIED`。不得擅自替人類發明權重或更改原目標。權重已在授權 `objective_policy_sha` 時，PPA Owner 可依規則選擇；未授權的 trade-off 提供選項要求人類決策。
- Spec Owner 對功能意圖／需求衝突負責，PPA Owner 對 PPA 評估策略負責，RTL Owner 對自己的設計負責，Verification/Formal 各自對其 Gate 負責，Integration Owner 對最終 Commit 的全套 Gate 與發布狀態負責。Main 只呈現進度和轉達人類決策。

## 12.9 資源、停止與恢復

開發初期預設 `max_initial_branches_per_exploration=3`、`max_total_branches_per_exploration=6`、`max_active_branches_per_exploration=3`、`max_branch_depth=2`、`max_parallel_owner_instances_per_role=3`；配置必須可版控，數字是 MVP 資源政策而不是系統架構上限。`max_concurrent_eda_jobs` 為全域配額，應採公平排程，讓同一 cohort 的多分支可同時取得進展。

- 每個 Branch 獨立累積 failure signatures、tokens、EDA CPU、elapsed-time、PPA improvements；共用 cohort budget，兩層都有限制。只新增 Commit 或建立 Worker 不算有效工程進展。
- 無改善/重複失敗時 stop branch，留下 `BLOCKED` 原因；超額衍生嘗試進 `BRANCH.FORK_DENIED`，不得因宣稱「探索必要」修改自己預算或建立新外部 Repo。
- Runtime / Worker Crash 後依持久化 `branch_id + candidate_id + lease_epoch + expected_head_sha` 復原；舊 lease 回報失效，不得覆蓋新結果。
- Scheduler 可按照公平性、預算與工作依賴讓 Branch 被暫停或重新喚醒；明確保存 `WAITING_FOR_EDA/WAITING_FOR_PEER/WAITING_FOR_ENV/WAITING_FOR_BUDGET`。
- 不得因 PDCA 自動建新 Branch 無限衍生。PDCA 可提出改善提案，正式部署需完成受控版本變更。

## 12.10 最低交付檢驗

一個 APB CRC32 Requirement 同時展開 3 條不同微架構路線；至少一條二級 Fork；每條路線有對應 RTL Owner Instance、Verification、Formal、PPA 的獨立 Tickets 與 Evidence。每條分支能被暫停、失敗、重試，其他路線仍前進；能列出完整 lineage、Pareto frontier、選擇／淘汰理由；最後有受控 merge 或保留多個合格候選，新 SHA 全 Gate 重跑。

不得用三段並行 Prompt 或同一工作目錄的三次重試冒充平行 Branch。驗收以 `docs/13_PARALLEL_EXPLORATION_ACCEPTANCE.md` 的 E01–E20 和 `manifests/ACCEPTANCE_TRACKER_TEMPLATE.json` 為準。

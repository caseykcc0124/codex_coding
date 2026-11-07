# 05｜Observability、Communication、PDCA 與 Dashboard

## 5.1 必須有五種權威資料

1. `Event Journal`：事件收到、驗證、路由、Fan-out、完成或隔離的不可變事實。
2. `Communication Ledger`：Peer Request、意圖、問答、拒絕、Human Approval 與任務關聯。
3. `Execution Traces`：Owner Turn、Harness、Skill、Worker、EDA Job、耗時、資源與退出碼。
4. `Decision / Evidence Records`：選了哪個方案、為何選擇、假說、驗證方式與工程原始證據。
5. `PDCA Improvement Records`：錯誤模式、重現條件、A/B 比對、版本變更、批准與回滾。

這些共同引用 `trace_id`、`ticket_id`、`run_id`、`event_id`、`parent_event_id`、`peer_request_id`、`skill_run_id`、`evidence_id`、`policy_version`、`harness_version`、`model_id`。

## 5.2 使用者要能從 Dashboard 看到

- Mission Overview：每個 IP 的 Current Revision、Active Ticket、Waiting Reason、最後有效成果、Stop Reason。
- Event Flow：Event Received → Route Decision → Owner Claimed → Skill → Peer Request / EDA Job → Next Event，具時間軸與因果圖。
- Agent Activity：Owner 啟動／等待／停止、Skill、Harness、模型、Token／成本（若可讀）、Lease、Heartbeat。
- Engineering Evidence：同一 Candidate 的 Simulation / Formal / Synthesis / PPA、有效期、指紋與不合格原因。
- Communication：所有 Owner 直接互通的工程請求與狀態，以及 Human 對話的正式操作摘要。
- Failure Analytics：同一 Bug Signature 被修了幾次、多少實際改善、無效迭代原因、成本與停滯時間。
- PDCA Board：待分析、提案、隔離實驗、待批准、已推出、已回滾。
- Approval Inbox：需要人類做決策的少量問題，附最小必要背景與選項。

Dashboard 是投影／Read Model，可用 Event Journal 重新建立；Dashboard 停止或刷新，不影響 Runtime。

## 5.3 量測指標

主要工程指標：`accepted_verified_releases`、`time_to_verified_release`、`reproducible_failure_resolution_rate`、`formal_property_validity_rate`、`ppa_target_achievement`。

自主性：`human_interventions_per_ticket`、`autonomous_completion_rate`、`resume_success_rate`、`stalled_runs_prevented`、`routing_without_main_rate`。

成本效率：`tokens_per_verified_release`、`eda_cpu_minutes_per_verified_release`、`wasted_retry_ratio`、`cost_per_progress_delta`。

品質／治理：`stale_evidence_rejection_count`、`scope_violation_block_count`、`unapproved_external_action_count`、`blocked_ticket_explanation_completeness`。

不能把 `agent_messages_sent`、`skills_used`、`commits_created`、`test_count_increased` 當成核心成功指標。

## 5.4 PDCA 工作流

- **Plan**：Process Improvement Owner 觀察到一種重複錯誤，形成可驗證假說，引用至少一個實際事件與工程證據。
- **Do**：在 Sandbox／版本化分支提出一個 Skill、Policy、Routing、Harness 或流程修正；不能同時改多個可歸因的變因。
- **Check**：固定相同案例、工具、規格與資源上限，執行舊版／新版對照，計算收斂率、成本、正確性，確認沒有退化。
- **Act**：符合量化門檻並經核准後推進版本；保留可回滾版本。結果失敗也保留，成為下一輪反例。

PDCA Owner 只有提案與隔離實驗權限，不可自行修改運行中的 Routing、正式驗收 Gate、已被批准的 Spec 或 Env Profile。

## 5.5 預設保存與安全

- 原始事件與批准紀錄為追加式；更正以新事件與前一紀錄建立關聯，不覆寫歷史。
- 長期保存 Policy、Decision、Evidence Manifest、摘要與 Failure Signature；巨大波形／原始 Token 記錄採設定化保留期限與 Artifact Store，不強求永不清理。
- 所有敏感路徑、憑證、使用者訊息等應使用最小化、可遮罩、權限內可追溯；不得在公開 Repo 自動上傳機密 RTL、PDK、完整 Prompt。
- 對外遙測與第三方服務預設關閉，獲授權才可啟用。
- 任何觀測服務故障不應阻止 Event Journal 的正確交易與 Owner 工作。

## 5.6 最低驗收示例

從一個 `SIM.REGRESSION_FAILED` 在 Dashboard 點開，應能看到：收到來源、Router 規則版本、Verification Owner 認領、使用的 Skill、失敗 Reproducer、Peer Request 目標 RTL、RTL Candidate SHA、EDA Run 的環境 Digest 與結果，以及 Integration 的最終接受或阻擋理由。重啟 Backend 後，這些關聯仍完整。

在「無效修復迴圈」情境，必須可以回答：為何 Runtime 判定沒有進展、嘗試了幾次、使用多少資源、下一輪 PDCA 的提案為何、誰有權批准，以及哪一版 Skill / Policy 對應這段歷史。

## v3.1 Exploration DAG、分支追蹤與 PDCA

Dashboard 追加探索群組 DAG，按 Requirement/Spec Revision → Exploration → Branch/Parent Fork → Owner Instance → Candidate RTL SHA → EDA Evidence → Comparison/Pareto → MergeProposal → Release 展開。必備每條 branch 的累計 Token/EDA 成本、有效進展、阻塞、Stale、衝突、Merge 後 ReGate 狀態、淘汰理由。Event Journal/Branch Registry 可重建 Graph；不能只用 branch 名稱猜關係。跨分支證據污染必須直接標示 REJECTED。失敗候選也保留供 PDCA，不能直接刪紀錄。

# 07｜硬性驗收矩陣與證據規格

## 7.1 驗收基本規則

每個 Acceptance Case 必須有 `case_id`、`feature`、`preconditions`、`steps`、`expected`、`observed`、`status`、`evidence_paths`、`commit_sha`、`environment_digest`、`test_command`。可接受的狀態：`PASS`、`FAIL`、`BLOCKED`、`NOT_RUN`。不得用 `SKIP`、`NA` 或文字報告將 Required Case 偷偷當成 PASS。

驗收分層：A 類使用 Stub/Mock 驗證 Deterministic Runtime；B 類使用真實 Harness；C 類使用真實 EDA；D 類長期可靠性／治理。**同一 Case 只能宣稱自己實際驗證的層級**。Mock 19/19 Pass 不能替代 C 類 EDA。

## 7.2 A 類：Runtime / Event Contract（M0/M1 必過）

| ID | 必驗收行為 | 核心證據 |
|---|---|---|
| A01 | Main Agent 沒啟動時，trusted CI 送 `SIM.REGRESSION_FAILED` 直接 route Verification | Event → Delivery Owner、無 Main Activity |
| A02 | 事件持久化與 Delivery 同 transaction；模擬 Crash，不遺失 | DB Restart Record |
| A03 | 同 Idempotency Key + 同 Payload 不重複產生 Event | Receipt 等值與唯一數 |
| A04 | 相同 Key、不同 Payload 被 409 拒絕 | Conflict Log |
| A05 | Unknown Event / spoofed producer 進 Quarantine，不呼叫 LLM 自由判定 | Reason Code |
| A06 | Fan-out 到 Verification、Formal，各自獨立 Ack / Retry | 兩個 Delivery ID |
| A07 | Claim Lease 到期恢復、`lease_epoch` fencing，舊 Attempt 不得完成新結果 | Restart + Stale Worker 測試 |
| A08 | Ticket 一次 Turn 結束後仍可由新事件續跑 | Ticket ID 同一、Run ID 不同 |
| A09 | Backend / Worker Restart 之後繼續工作且不重複外部 Side Effect | Operation Receipt |
| A10 | 同時存在兩個 IP，A 卡住 B 仍能完成 | Parallel Trace |
| A11 | 新 Spec 覆蓋舊 Revision 後，舊 EDA Result 不能成為 Release Gate | Fingerprint Rejection |
| A12 | 相同 Failure Signature 反覆發生，第三次無有效進展後 Blocked | Watchdog Stop Reason |
| A13 | Agent 申請自行擴建不相干 Framework／外部 Repo 被拒絕 | Policy Violation |
| A14 | EDA Job 指回 registered requesting_owner，不能用事件 Payload 偽造 Owner | Job Registry Lookup |
| A15 | Runtime Budget 變更需要 Policy Version + AuthZ；Agent 不能改自己的限制 | Denied Change Audit |
| A16 | 實驗 Event Injection 與正式 Namespace 完全隔離 | Domain Isolation Log |

## 7.3 B 類：原生 Harness、MCP、Domain P-Stack（M2/M3 必過）

| ID | 必驗收行為 | 核心證據 |
|---|---|---|
| B01 | 從原生 Codex 透過 SiliconForge Skill/MCP 查詢 Ticket | Tool Call Transcript / Receipt |
| B02 | 從原生 Claude Code 查詢相同 Ticket，結果一致 | Tool Call Transcript |
| B03 | 從原生 Harness 提交已授權 Spec Intent，Runtime 記錄 Event 與 Scope | Event Receipt |
| B04 | User Harness 退出後，Owner 仍由 Runtime 喚醒 | Worker Run vs User Session Timeline |
| B05 | Codex Owner 使用結構化 Action 提交 EDA Job / Peer Request，未經 Schema 驗證則拒絕 | SDK trace + validation errors |
| B06 | Verification Owner 直接 Peer Request RTL，無 Main 介入 | Peer Ledger + Event Path |
| B07 | RTL Owner 的 `rtl-arena` 以隔離 Worktree 產生候選，候選功能不過不能選勝 | 3 Candidate Dir、Decision Evidence |
| B08 | Verification Owner 的 `verification-swarm` 可平行分工且獨立 Seeds，可合併結果 | Worker Receipt + Test Matrix |
| B09 | Formal Owner 對 `UNKNOWN/TIMEOUT` 不得宣布 Formal Pass | Gate Rejection |
| B10 | Harness Thread 遺失後以 Ticket Snapshot 啟新 Session，不遺失工作與批准 | Resume Trace |
| B11 | AI 回傳偽造 `HUMAN.APPROVED` 或 EDA_PASS 被拒 | AuthZ Audit |
| B12 | Notification 重要事件可去重，離線可讀、重新登入可續讀 | Cursor/ACK Test |
| B13 | Human Chat / direct Owner Chat 皆留下可追溯訊息與操作界線 | Communication Ledger |
| B14 | 無自建的 SiliconForge 自然語言 CLI 也可執行完整人類操作 | Install & Smoke Test |

## 7.4 C 類：開源 EDA 與晶片工程（M4/M5/M6 必過）

| ID | 必驗收行為 | 核心證據 |
|---|---|---|
| C01 | Env Owner 建立固定 Profile，Runner 可重現 tool versions、image digest | Toolchain Manifest + Hash |
| C02 | 普通 Owner 無法自行安裝／修改正式 Env | Denied Permission |
| C03 | Verilator + cocotb 真實執行 APB CRC32 定值和完整 Directed Tests | Real Runner Log、Seed、Waveform |
| C04 | Python Golden Model `123456789` 等於 `0xCBF43926` | Reference Unit Test |
| C05 | 修復之前某一故意 Bug 有可重現 Regression Fail | Test ID / Source SHA / Waveform |
| C06 | Verification → RTL → Verif／Formal 循環在 Main Offline 下真正自主修復並重新驗證 | Complete Trace + All Evidence |
| C07 | Reset 中途測試與 Formal 性質通過，不能回傳舊結果 | RTL SHA、Waveform、Property Proof |
| C08 | Yosys 真實產生可保存 Netlist 和 Cell Stats | Netlist SHA、Tool Log |
| C09 | 必要 Formal Proof 結果為 `PROVED`，或明確在限制下標示 Bounded Scope | Proof Report + Assumptions |
| C10 | OpenROAD 使用固定 Constraints/Library/Environment 得到可比 PPA | Timing、Area、SHA、setup path |
| C11 | PPA 目標修改後能自主發出 RTL Alternative，再完整驗證並比對 | Arena Evidence + new PPA Report |
| C12 | 新 Spec 運行中注入，舊 Candidate 不能混入新 Gate | Revision Transition Trace |
| C13 | Env Drift 擋下 Job，Env Owner 修復後自動恢復 | WAITING_FOR_ENV → READY → EDA_PASS |
| C14 | Release Manifest 僅採同版本、同環境、同約束且通過的報告 | Manifest Verifier |
| C15 | CLI 人類入口完全關閉時，仍能完成真實 EDA 交付 | User Session Closed Evidence |
| C16 | 真實 EDA 失敗不能被 mock 版本替代，Mock 模式有顯眼旗標與隔離 Namespace | Mode Stamp / Test |

## 7.5 D 類：自由事件、可靠性、觀測、PDCA（M6/M7 必過）

| ID | 必驗收行為 | 核心證據 |
|---|---|---|
| D01 | IDLE 之後注入新 Event，仍可恢復同 IP 的工作 | Ticket Revision 變遷 |
| D02 | AUTO 運行期間連續注入 Spec、Sim Fail、PPA Target，均被持久化、正確排序與交接 | Timeline / Replay |
| D03 | Main/User Harness 離線、Runner Crash、Backend Restart 組合之後可繼續 | Chaos Test Evidence |
| D04 | 完成及 Blocked 都只在重要事件通知人類，一般 Heartbeat 不騷擾 | Notification Audit |
| D05 | 從 Dashboard 任何失敗事件可追至 Owner、Skill、Harness、EDA Report、下一事件 | Trace Graph |
| D06 | Event / Peer / Decision / Evidence 重啟後可完整重建 Dashboard Read Model | Deterministic Rebuild |
| D07 | 重複失敗產生 PDCA Proposal，對照舊版／新版可比，不能擅自發布改善 | Proposal + A/B Log |
| D08 | Skill / Policy 改版可 Rollback，舊 Ticket 保留版本歷史 | Versions / Rollback Receipt |
| D09 | 事件壓力測試至少 1000 件 Mock Event 無資料遺失、無重複外部效果 | Fuzz/Stress Report |
| D10 | 測試失敗明確顯示 FAIL，不能以 Agent 自我聲明覆蓋結果 | Test Harness Anti-cheat |
| D11 | Token / EDA 用量超過預算時阻擋新工作，其他 Ticket 不受無關阻擋 | Budget / Fairness Report |
| D12 | 產物沒有自動發布公開 repo、敏感 RTL、PDK 或任何秘密 | External Side Effect Audit |

## 7.6 完成判定

- M0 Gate：Contracts Schema、配置校驗、A0 參考測試通過，且建立 A01 至 A16 的正式測試空殼與執行計畫；M1 Gate：A01 至 A16 以真正 Runtime 實作的自動測試全部通過。
- M2 / M3：B01 至 B14 通過，是真實 Harness，不是 mocked Console。
- M4 / M5：C01 至 C09、C13、C14、C16 通過，其中 C06 是首要里程碑。
- M6 / M7：全部 C、D Required Case 通過，A/B regression 仍全綠。

**最終不可減少的三個 Demo**：

1. `Spec Change → RTL → Simulation + Formal → Synthesis + PPA → Release`，中途人類無需反覆催促。
2. `Simulation Bug → Verification Triage → RTL Fix → Same Reproducer Pass → Release`，Main 關閉。
3. `PPA Miss → RTL Arena → 功能等價與時序重驗 → 可比 PPA`，若不可達可正確 Blocked 並給證據。

另外必備負面 Demo：無效迴圈被停、擅自框架擴張被拒、環境故障恢復、舊 Evidence 不可混用、人類批准不被模型偽造。

## 7.7 Acceptance Report 格式

最終需提供 `reports/ACCEPTANCE_REPORT.md` 及機器可讀 `reports/acceptance.json`；逐 Case 包含 `id, layer, result, test_command, evidence_sha256, commit, elapsed, notes`。任何 Required Case 未跑、沒有檔案路徑、沒有實際 Runner / Harness 證據，都不得稱總驗收通過。Mock 的 19／19 或瀏覽器 28／28 只是既有示意原型，**不繼承為本版真實整合 PASS**。

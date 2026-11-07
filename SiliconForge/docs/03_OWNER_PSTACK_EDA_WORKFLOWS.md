# 03｜Domain Owner 的 P-Stack 實作規格與開源 EDA 工作流程

## 3.1 技術方向

P-Stack 的方法沉入**每個 Domain Owner**，不是建立一個全域 P-Stack Orchestrator。Super Agent Runtime 只負責事件／狀態／授權／資源。Codex Domain Owner 以其專屬的領域 Skill 組合，在限定工作區調用臨時 Worker 與 EDA Job。父 Owner 對局部產物和整合品質負責，不能由 Temporary Worker 自行跨 Owner 改其他領域。

原版參考：`$architect`、`$arena`、`$swarm`、`$tdd`、`$interrogate`、`$blast-radius`、`$show-me-your-work`、`$reflect`、`$correct`。這些在 pstack-for-codex 中要求明確調用，且平行 Writer 必須隔離。SiliconForge 的 Owner Policy 才決定何時執行相應專業化程序。不能假設安裝後所有 Skills 就會自動生效。

## 3.2 Skill Contract 的統一界面

每個 Skill 必須提供：

```
name, owner, version, description,
trigger_criteria, input_schema, required_evidence,
allowed_tools, allowed_writes, allowed_workers,
procedure_steps, exit_predicate, failure_codes,
max_iterations, budget, telemetry_fields, output_schema
```

流程內的工具調用必須是透過 `EDA Job Contract`、`Peer Request` 或受控 Workspace 操作；Skill 不可以任意修改 Runtime 的 Route/Policy/Env。執行結果必須對應 `skill_run_id` 與 Evidence 或 `blocked_reason`，不能以完成一段思考作為 Skill Success。

## 3.3 P-Stack 對各 Domain Owner 的具體適配

| Owner | 內嵌方法 | 何時啟動 | 必須交付 |
|---|---|---|---|
| Spec | `silicon-architect`, `design-impact`, `interrogate` | 新 Spec／Change／Clarification | 版本化 Requirement、Latency、Protocol、可測試 Acceptance、Impact Graph |
| RTL | `rtl-arena`, `waveform-tdd`, `blast-radius`, `interrogate` | Spec 改動、RTL Repair、PPA Alternative | Candidate RTL、實作假說、變更 Diff、局部 Reproducer、選擇理由 |
| Verification | `verification-swarm`, `waveform-tdd`, `interrogate` | Regression Failure、新 RTL、Coverage Gap | Seed、Test ID、Waveform、Golden Model Comparison、Bug Signature、Coverage Evidence |
| Formal | `formal-triage`, `interrogate`, `blast-radius` | Candidate Ready、Property 變更、Proof Failed | Property-Requirement Mapping、Assumption、Proof Status、Counterexample |
| PPA | `ppa-arena`, `benchmark-checklist`, `design-impact` | Clock / Area Target、Candidate Ready | 同一環境與 Constraints 的可比 PPA Report、Critical Path、候選排名 |
| Integration | `show-me-your-work`, `interrogate`, `release-gate` | 全部必要 Gate 到齊 | Evidence Manifest、版本一致性、Release Decision、未解風險 |
| EDA Environment | `environment-reproduce`, `interrogate`, `correct` | Profile 缺失、Version Drift、Runner Error | Immutable Profile、Environment Digest、Smoke Test、兼容清單 |
| PDCA | `reflect`, `correct`, `interrogate`, `benchmark-checklist` | 重複失敗、停滯、成本異常 | Case、根因假說、隔離 A/B 實驗、差異報告、建議版本 |

### 範例 A：`rtl-arena`

1. Frame：接收同一 Approved Spec、Interface、Latency Bound、Toolchain Profile、Constraints。
2. Fan out：預設最多 3 個候選 Worker，分別在隔離 Worktree 中實作，各自提出 PPA 假說。
3. Pre-filter：執行 Lint、既有 Reproducer／Directed Tests；功能不過直接淘汰。
4. Cross-judge：獨立審查相同目標、約束有無偷換。模型評審只產生質疑，不能自行宣布最佳設計。
5. Evaluate：Verification／Formal 通過後執行 Yosys/OpenROAD，對同一 Fingerprint 比較可量測 PPA。
6. Pick：在硬約束全數滿足的候選中，根據明確排序規則選擇；不合格者不參賽。
7. Graft：如從淘汰方案採用部分概念，必須重新建立 Candidate 並完整再驗證。
8. Verify：輸出 Candidate SHA、Evidence、Loss / Tradeoff、Rejection Reasons，向 Owner Ticket 回報。

### 範例 B：`verification-swarm`

1. 先建立一個共同的 Golden Model／接口版本。
2. 對 Test Slice（APB Setup/Access、Reset、CRC32 reference、Random Sequence、Back-to-Back、Corner）平行處理；每個 Worker 有獨立 seed、work dir 和輸出路徑。
3. Aggregator 僅合併受檢驗的 test results，記錄失敗簽章、Test Coverage 和 Source SHA。
4. 若 Test 失敗，先最小化 Reproducer，再判斷是 RTL、Golden Model、Testbench 還是環境。
5. 可疑 Testbench 修正應由 Verification Owner 以 Spec Evidence 說明；不得因 RTL 不過就無依據地改 Expected Result。

### 範例 C：`formal-triage`

- Property 由 Requirement ID 追溯，明列假設和作用範圍。
- `PROVED`、`COUNTEREXAMPLE`、`UNKNOWN`、`TIMEOUT` 分離，後兩者不是通過。
- Counterexample 必須輸出可閱讀 Trace 或可重現資料；Property 弱化需新審查，不能私自放行。

### 範例 D：`ppa-arena`

- 比較必須 pin 同一 `lib_sha`、`constraint_sha`、`env_digest`、clock、corner、utilization 設定。
- `PPA_PASS` 至少包括 Timing Constraint 是否達標與標準化面積；有功耗資料時明列功耗的量測依據／品質。
- 若只使用 Yosys 面積和 OpenROAD Timing，應標示為 `ESTIMATED_PPA`，不得冒稱 Signoff 或實際功耗。

## 3.4 APB CRC32 Golden Design Contract

第一個 IP 使用 APB3 Slave + CRC-32/ISO-HDLC（反射 Polynomial `0xEDB88320`，Init `0xFFFFFFFF`，Final XOR `0xFFFFFFFF`，資料依 Byte 低位先處理）。標準 Check Vector `"123456789" → 0xCBF43926`，作為 Golden Model 與 RTL 必過的定值。

**Registers (可依文件實作，變更需修訂 Spec)**

| Offset | Name | Behavior |
|---|---|---|
| `0x00` | `CONTROL` | bit0 START 清除 CRC 到 Init；bit1 FINISH 鎖存可讀結果；bit2 CLEAR 清 status |
| `0x04` | `STATUS` | bit0 VALID，bit1 ERROR；Reset 全清 |
| `0x08` | `DATA` | APB Write 接收低位 `BYTE_COUNT` 個 byte，僅 Access Phase 生效 |
| `0x0C` | `BYTE_COUNT` | 1、2、3、4 有效；其他值回報 ERROR，不能變更 CRC |
| `0x10` | `RESULT` | FINISH 後回傳 Final XOR 的 CRC，VALID 未置位時固定回零 |

APB 時序：單一 `PCLK`，`PRESETn` 低有效，PSEL/PENABLE 規則；Access Phase 且 PWRITE 時才產生 Side Effect；APB Setup Phase 不得寫入資料。第一版可固定 `PREADY=1`，可透過後續 Spec 演進增加 Wait State，但不在 MVP 自行擴張。

Reference Model：純 Python，可接受 Byte Stream；每筆 APB Write 對應 1~4 bytes；Reset 中斷操作必須清除 VALID 與 CRC State，不得讀出上筆 RESULT。

**封閉的 MVP 範圍**：單 clock domain，單 APB slave，無 DMA、中斷、bus bridge、AXI、AES、SystemC 全 SoC 與多時鐘 CDC。在 APB CRC32 取得真實驗收後，才將 SystemC Reference 接為第二階段可選工作。

## 3.5 最低必要 EDA Matrix

| 類別 | Tool | Gate | 必存證據 |
|---|---|---|---|
| Syntax / Lint | Verilator | 0 errors，不可吞掉會影響功能的警告 | source_sha、指令、exit code、輸出 |
| Simulation | Verilator + cocotb | Directed + Random tests，全數 pass | Test ID、Seed、Waveform、Report |
| Golden Reference | Python CRC32 | 123456789 與額外 Corner | expected/actual、Model SHA |
| Formal | SymbiYosys（搭配開源 Solver） | 必要 Properties 證明或 bounded 結果明確標示 | Property File、Engine、Assumptions、Result |
| Synthesis | Yosys | Netlist 可產生、無 latch（除非 Spec 允許） | Netlist SHA、Cells、Warnings |
| PPA | OpenROAD + 可用 Open PDK / lib | 固定約束、可比較實測數據 | SDC SHA、Lib SHA、Timing、Area、Environment |

部分 PDK／Lib 在開源工具上可能有授權及流程差異。Environment Owner 應選可合法使用的公開流程，並把限制記錄於 manifest。若某公開實體設計套件不可用，先完成 Synthesis 的可量化 Target，PPA Gate 暫列 `NOT_IMPLEMENTED` 並保留正式最終 Gate，不能把「無 PPA」當作成功。

## 3.6 必備 Verification Case

- T01：復位初始值、STATUS / RESULT 清零。
- T02：單 byte 及多 byte CRC32 定值。
- T03：資料 `123456789` 的標準向量。
- T04：APB setup 不產生 side effect。
- T05：Back-to-back APB 寫入，結果順序正確。
- T06：Reset in-flight：VALID 清除、不回報舊結果。
- T07：非法 BYTE_COUNT 不改 CRC 且 ERROR 置位。
- T08：FINISH 後 RESULT 穩定，直到下一次 START。
- T09：Random seed 可保存並重播，至少 10 組固定種子。
- T10：故意植入 Bug，使 Directed Regression Fail；修復後同一 Reproducer Pass。

Formal：針對 reset、setup side effect、非法 Byte Count、VALID/RESULT、不可越界讀取等性質，建立清楚的 Property ↔ Requirement mapping；涉及資料正確性的完整等價性，可採 Reference Equivalence 或 bounded proof，明確說明證明邊界。

## 3.7 EDA Environment Owner 的工作契約

- 所有 Runner 必須指定 `profile_id`、`image_digest`、tool versions、lib/PDK SHA、可用工具、`profile_status=VERIFIED`。
- 只有 Environment Owner 可以提交新 Profile，必須先 smoke test，並由既定 Policy 准予 promote。
- Profile 舊版不覆寫。正在執行的 Job pin 舊 Digest，後續版本切換不影響已跑的實驗。
- 缺 Tool／版本漂移回傳 `WAITING_FOR_ENV`，Environment Owner 修復完成產生 `ENV.PROFILE_READY`，Runtime 恢復原 Job。
- 不同 Domain Owner 不得執行 `pip install`、`apt install`、更改 Dockerfile、替換 Solver 來直接通過當前 Job。

## 3.8 整合 Release Gate

對相同有效 Baseline 的 `spec_rev + rtl_sha + env_digest + constraints_sha`，Integration 必須取得下列必要 Gate：Lint、Directed、Random Regressions、Formal 必要性質、Synthesis、PPA Target（後期里程碑）。任何 Gate `MISSING`、`FAIL`、`UNKNOWN`、`TIMEOUT` 或 Fingerprint 不一致，不得產出 `RELEASE_ACCEPTED`。

必須能看到可下載的 `release_manifest.json` 與每個原始報告的 SHA。最終「成功」只在同一 Commit 有完整 Evidence 且 Exit Criteria 全數通過時成立。

## v3.1 每個 Domain Role 多個 Owner Instance

P-Stack Skills 沉入**每一個 Instance**；Role 只定義能力與權限，同一 Requirement 可同時產生 RTL(performance)、RTL(low_power)、RTL(area) 三個獨立實例，再各自配對 Verification/Formal/PPA 的獨立 Instance、Worktree 與 EDA Job。`rtl-arena` 可以在某個 branch 內部探索局部候選；跨 branch 的持久化血緣與 fan-out/fan-in 由 Super Agent Runtime 管理。任一來源 Candidate 的 Pass 不得直接套在其他 Branch 或 Merge 後新 SHA。

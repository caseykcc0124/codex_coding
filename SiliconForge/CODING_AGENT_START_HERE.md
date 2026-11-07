# 給 Coding Agent：先從這裡開始

本專案要做一個 **Super Agent Runtime 長時間管理自主性，P-Stack Skills 深入每個 Domain Owner，真實 EDA 工具證明工程結果** 的 SiliconForge 平台。

請先讀 `README.md`，再讀 `docs/00_MISSION_AND_BOUNDARIES.md`、`docs/07_ACCEPTANCE_MATRIX.md`、`docs/08_CODING_AGENT_WORK_ORDER.md`，接著讀 `docs/01` 至 `docs/06` 與 `docs/10`。

現階段你接手的是 v3.1 正式設計基準與可運作的 A0 參考原型。**不是完成的產品**。請不要只跑 25 個參考測試就宣稱交付成功。

立即執行：

1. 讀取所有規格與 78 項 Acceptance Cases。
2. 執行 `python -m pytest -q tests`，保存真實輸出與工具版本。
3. 檢查 `reference/runtime.py` 和 `reports/REFERENCE_TEST_REPORT.md` 已知差距。
4. 建立正式 M0 Schema／Policy／Repo Structure，開發真正 Event Runtime M1，補上 Transactional Outbox、Identity 驗證、Lease Fencing 與跨程序 Restart。
5. 逐 Gate 完成 M2 至 M7 的真實 Codex/Claude、P-Stack、EDA、Web Dashboard、PDCA。
6. 每次有真實證據即更新 `SILICONFORGE_WORKING_SYNC.md`，附 commit、測試數、結果和未完成項。

不能另外造對話 CLI、把 Main 當中央仲裁、偷偷減少工具驗收、沒有批准就擴張資源或外部發布。這些是不可通過驗收的違規架構。

GitHub 發布位置：`caseykcc0124/codex_coding`，專案子目錄 `SiliconForge/`，請將本目錄設為工作目錄。權威進度檔為 `SILICONFORGE_WORKING_SYNC.md`。

正式開始 M0 前，先於本目錄解開源碼包：
```bash
tar -xJf source/A0_REFERENCE.tar.xz
tar -xJf source/CONTRACTS_SKILLS_INTEGRATIONS.tar.xz
python -m pip install -r reference/requirements-dev.txt
python -m pytest -q tests
```

這些僅為 A0 MOCK 參考，M1–M7 必須自行實作及取得真實驗收證據。

## v3.1 工作指引新增優先順序（必讀）

1. 讀 docs/12、docs/13、docs/14 與 config/exploration.yaml，將 `owner_role` 與 `owner_instance_id` 分開。每個新 Branch 要有穩定的 exploration_id、branch_id、candidate_id、Git SHA 與來源血緣。
2. 按 M1X 完成 Registry、Candidate scoped Event Routing/Lease、Durable Fanout/Fanin、Quota、Restart；按 M3X 完成真 Git Worktree 隔離與多 Codex Owner Instance；按 M6X 交付三條不同目標的真 EDA、二級分叉、Pareto、Merge 後新 SHA 重跑 Gate。
3. E01–E20 全為 Required，原 A01–D12 共 58 項全部保留，總計 78 項。未取得真實執行證據仍為 NOT_RUN；Mock 不可冒稱真實。
4. 所有重要 Branch/Fork/Merge/Spec Stale/Stop/Comparison 立即寫入 `SILICONFORGE_WORKING_SYNC.md`，證據包含 branch_id、commit SHA、owner_instance_id、EDA Fingerprint 與 Stop Reason。
5. 不得把三個 Worker 在同一 Worktree 先後修改當成平行探索，也不能讓 Owner 自行放寬配額、直接合併 main 或發布遠端分支。

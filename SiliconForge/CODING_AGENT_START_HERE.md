# 給 Coding Agent：先從這裡開始

本專案要做一個 **Super Agent Runtime 長時間管理自主性，P-Stack Skills 深入每個 Domain Owner，真實 EDA 工具證明工程結果** 的 SiliconForge 平台。

請先讀 `README.md`，再讀 `docs/00_MISSION_AND_BOUNDARIES.md`、`docs/07_ACCEPTANCE_MATRIX.md`、`docs/08_CODING_AGENT_WORK_ORDER.md`，接著讀 `docs/01` 至 `docs/06` 與 `docs/10`。

現階段你接手的是 v3.0 正式設計基準與可運作的 A0 參考原型。**不是完成的產品**。請不要只跑 25 個參考測試就宣稱交付成功。

立即執行：

1. 讀取所有規格與 58 項 Acceptance Cases。
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

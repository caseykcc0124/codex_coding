# 11｜GitHub 工作交接與同步協定

權威 Repository：`caseykcc0124/codex_coding`，`main`，`SiliconForge/`。

Coding Agent 在現有 Repo 內此子目錄工作，不建立新 Repo，不變更 KA-DMM 相關檔案。

## 實作與提交
1. 每次開始先讀 `AGENTS.md`、`CODING_AGENT_START_HERE.md`、`docs/00`、`docs/07`、`docs/08`。
2. 給定已授權的工程範圍，可以自主完成 M0–M7，不必每個步驟都等人工轉交訊息。
3. 新增程式碼／測試／設定時保持模組隔離，變更後執行實際驗證並保存原始 log。
4. 維護 `SILICONFORGE_WORKING_SYNC.md`，工作中每 15 分鐘至少提交 Heartbeat；主要進展、阻礙、Gate 需立即更新。Heartbeat 和測試活動不是成果。
5. 若有 GitHub 並行更新，必須檢查原檔 SHA 與分支 HEAD，處理衝突後再提交，禁止覆蓋其他 Agent 進度。
6. 任何修改驗收標準、建立外部 Repo、對外發布、上調預算、新增網路目的地、改權限的行為都需明確人工授權。
7. 初期可用功能分支與 PR，但必須保證 main 的這套規格是可找到的正式基準。

## 每次狀態至少包括
mission_state、milestone、updated_at_utc、last_progress_at_utc、latest_agent_commit、實際執行命令、Test PASS/FAIL/NOT_RUN 分層數量、真實或 Mock 標記、環境 Fingerprint、Evidence SHA、風險、Human Approval、Next Action。

## 交付驗收
以 [58 Cases](07_ACCEPTANCE_MATRIX.md) 為準。A0 參考測試只證明參考程式，未通過真實 Harness/EDA 不能標完成。

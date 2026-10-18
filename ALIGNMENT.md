# 需求對齊與驗證

## 正確入口

GitHub 是安裝來源；安裝後 Codex 主對話就是工作入口。使用者正常說話，Main 整合意圖、執行或派原生 Worker、驗收、保存進度並在該對話回報。不另建 inbox、UI、聊天或代理框架，不要求使用者執行 PS1。

## 本次修正

- 使用者層 always-on skill，加上可備份、重複執行的 AGENTS.md 規則合併。
- 桌面版 native heartbeat 綁定目前主對話；CLI Windows 的內部喚醒只恢復已確認 UUID。
- 啟用、暫停、恢復與任務交付都由 Main 處理，腳本是內部實作。
- 舊 inbox 腳本保留追溯但退出安裝與日常流程，舊排程停用。
- 不覆寫既有 MCP、config.toml、認證、其他 skills 或人類意圖。

## 本機驗證（2026-10-18）

- Skill frontmatter 與命名驗證通過，全部新增 PowerShell 語法檢查通過。
- 安裝到隔離測試目錄，確認原有規則前綴完整保留，第二次安裝內容不變、管理區塊不重複，helper 完整安裝。
- 本機使用者層安裝成功，原有全域規則備份並合併，客戶端已回傳更新後的 AGENTS 指令。
- CLI 綁定已知測試 Session，實際執行新的 Wake-Session，確認 thread.started UUID 不變、turn.completed、WAIT 結果保存在同一 transcript。沒有建立新的 Main 或讀取 inbox 來交付新任務。
- 桌面版 native heartbeat 已由工具回報 ACTIVE，儲存的 target_thread_id 等於安裝對話。此項確認建立與綁定，不冒充已觀察到第一次定時觸發。
- 舊 Windows inbox 排程已停用。

## 仍然存在的客戶端界線

- 技能及 AGENTS 只能規定行為，喚醒依賴真正可用的 scheduler。
- 所有新 Codex 可發現使用者技能，不表示所有新聊天會自動取代同一 Main。需在想作 Main 的對話啟用或明確接續。
- CLI 必須有可靠當前 UUID；無法識別時不能猜最新 Session。互動終端的背景結果即時刷新及同時輸入競態尚未驗證，不能宣稱已解決。若要求畫面內接續，優先使用支援 native heartbeat 的桌面入口。
- 不同裝置或公司環境仍需本機驗證模型、sandbox、喚醒工具與政策相容性。
- Teams、Outlook、LINE 等來源或外發通知需另外明確授權，不會因安裝自動掃描或發送。

## 停用及回復

讓 Main 暫停同對話 heartbeat，或停用其綁定的 Windows 任務。安裝器回傳全域規則與既有同名 skill 的備份位置；回復只處理本次管理區塊與同名技能，保留其他設定。私人 Session、意圖、成果與日誌不公開。

# Windows CUI / CLI / IDE 同主對話喚醒

日常入口是正在使用的 Codex 主對話，任務直接在其中交付。內部 Windows timer 使用 Codex 原生 `queue --remote unix:// --thread <已確認 UUID>`，把有限喚醒交給原本持有 Session 的 Codex 處理。不啟動第二個 writer，不使用 exec resume，不需要 inbox 或另一個對話。

已實測 Codex 0.163.0 的 vscode-source 主對話：exec resume 被 active writer conflict 拒絕；native queue 成功，原本主對話回覆測試 marker，實際喚醒也在同對話回覆 WAIT。不能僅以 source=vscode 判定不支援。

使用技能內部 Bind-Session.ps1 驗證 UUID、工作區及原生 queue 能力，並建立 15 分鐘 Windows 任務。Wake-Session.ps1 使用鎖、活動回合檢查與單一 outstanding tick，避免排隊堆積。只確認 queue ack 不算執行完成，需檢查同 transcript 的 assistant 回覆與 task_complete。

已開著的 Main 保留原本模型、工具及權限；queue 不帶新的 sandbox 或模型覆寫。安裝不關閉安全保護、不終止其他程序。PowerShell 7、Windows 使用者登入、Codex 原生 queue 支援及可用的當前主對話是此 adapter 的條件。

若 transcript 已分頁或無法觀察 completion，保守保留 pending 而不反覆排隊，需由 Main 核對結果與游標。其他 OS timer、遠端 endpoint、客戶端關閉時的行為尚未驗證，不宣稱跨所有環境自動可用。主代理規則與原生 queue 介面共用，OS 只負責發出定時 tick。

人類不執行 helpers。啟用、暫停與恢復由 Main 操作自己的 Windows 任務。舊 inbox 排程保持停用，舊 resume-writer 路徑已移除。

排程實際呼叫已通過（LastTaskResult=0），該 tick 在原本仍開著的 Main 回覆 WAIT 並完成。先前的 embedded/server 衝突已以明確連接既有原生共享 server 解決；不新增自訂後端。

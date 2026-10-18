# Windows CLI 同主對話接續

日常入口是正在使用的 Codex CLI 對話。技能內部 Bind-Session.ps1 綁定已確認的當前 CLI Session UUID 與工作區，Windows 每 15 分鐘呼叫 Wake-Session.ps1，再以 exec resume 恢復同一 UUID。任務直接在主對話交付，不經 inbox。

內部腳本在 skills/always-on/scripts/，人類不需操作。使用者已授權才建立排程；使用現有登入及 MXC sandbox，不修改全域隔離設定。PowerShell 7、Windows 使用者登入、電腦運作與網路/認證有效是前提。

綁定驗證 Session source 與 cwd，不接受桌面/子代理或不符的 Session，不使用 --last。不可辨識當前 Session 時停止綁定，不猜最新檔案。背景恢復先檢查 transcript 是否有活動回合，避免已知重疊；檢查與互動開始之間仍有競態，嚴格單一執行時需在互動期間暫停 timer。

同 UUID 的 transcript 保存已驗證，不代表已開啟終端會即時刷新。桌面版應使用 native heartbeat，不拿 CLI 恢復當作桌面訊息橋接。AGENTS.md/skill 本身沒有 Scheduler。

舊 inbox 腳本保留但停用，新安裝不得再註冊 Codex-Native-Autonomy 舊任務。

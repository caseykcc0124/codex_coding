# Codex Native Autonomy

Codex CLI 主代理使用 GPT-6.1 Sol Low，原生 poc_worker 使用 GPT-6 Luna Low。以私有 Markdown 狀態保存意圖與證據，由 Windows 工作排程器每 15 分鐘啟動有限回合。沒有新事件時直接 WAIT，不呼叫模型。

- [部署指令](./INSTALL_PROMPT.md)
- [Windows CLI 操作、權限及限制](./WINDOWS_CLI.md)
- [代理規則](./AGENTS.md)

日常以 scripts/Submit-AutonomyEvent.ps1 交付任務與驗收條件，以 scripts/Get-AutonomyStatus.ps1 查看結果。Main 自行判斷、有限派工、驗收並保存證據。阻塞事件保留恢復條件，不反覆空轉。

目前工作來源為明確授權的本地 inbox。Teams、Outlook、其他專案與外發通知必須另外指定授權範圍及實際接入方式；此 repo 不會自行掃描公司帳號。Windows 排程不是 CLI 原生 Scheduler，也不能在電腦關機或使用者登出時保證執行。

Windows runner 使用 MXC sandbox，保留公司全域設定與強制政策。部署者須實際驗證裝置相容性，不因其他電腦已通過就宣稱當前裝置也能運作。

公開 repo 只放一般化規則與腳本；實際 INTENT、STATE、PROGRESS、inbox、成果、Session 與日誌均保留於本地且被 Git 忽略。不得提交公司機密、MCP URL 或憑證。

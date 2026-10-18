# Codex Always-on 主對話

安裝到既有 Codex，讓你直接在 Codex 主對話交付任務、追加意圖、查看結果。GitHub 只提供安裝材料；日常不需要操作 GitHub、PS1 或 inbox。

## 使用

首次把這個 repo 的 INSTALL_PROMPT.md 交給 Codex 安裝。之後在你要作為 Main 的 Codex 對話說：

> 啟用 Always On。這個對話就是主代理，持續處理我交付的工作，保存進度，適合時派 Luna 子代理，完成後在這裡回報。

也可以使用 `$always-on`。技能安裝到使用者層，因此其他工作區的新 Codex 對話也可發現它；新的對話不會擅自取代既有 Main。安裝後目前已開啟的客戶端可能需重新載入技能。

- [安裝指令](INSTALL_PROMPT.md)
- [實際技能](skills/always-on/SKILL.md)
- [需求、實作與驗證界線](ALIGNMENT.md)
- [Windows CLI 的同 Session 接續](WINDOWS_CLI.md)

## 喚醒能力

桌面版若提供 native heartbeat，直接綁定啟用時的主對話，後續在該對話接續。CLI-only Windows 可由內部排程恢復已確認的同一 Session UUID；不能據此保證已開啟的終端畫面即時刷新。沒有可用喚醒工具或無法辨識當前 Session 時必須回報，不能假稱 AGENTS.md 自己會醒來。

Main 預期 Sol Low，原生 Worker 預期 Luna Low；已開啟對話的實際模型由客戶端決定，載入技能不會自動更換它。保留既有 MCP、Skills、認證與公司政策。Teams/Outlook 需要明確授權及接通來源，沒有預設掃描。

舊 scripts/Submit-AutonomyEvent.ps1、Invoke-Autonomy.ps1、Register-AutonomyTask.ps1 是先前偏離需求的 inbox 路線，僅保留供遷移追溯；不要用它們安裝或啟用新版。停用舊任務後啟用同主對話喚醒，不能兩套同時運作。

實際意圖、狀態、Session、成果與日誌僅留本地，不上傳公開 Git。

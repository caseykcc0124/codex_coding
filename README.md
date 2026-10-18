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

桌面版有 native heartbeat 時可綁定主對話。本機 CUI/CLI/IDE 則優先驗證 Codex 原生 queue 能力，以 Windows timer 將喚醒送進正在開著的同一主對話；不再用 exec resume 搶 writer。已實測 0.163.0 的 vscode-source 主對話回覆 marker 與 WAIT。其他 OS timer、關閉/遠端客戶端仍需各自驗證，沒有通用無條件支援的宣稱。

Main 預期 Sol Low，原生 Worker 預期 Luna Low；已開啟對話的實際模型由客戶端決定，載入技能不會自動更換它。保留既有 MCP、Skills、認證與公司政策。Teams/Outlook 需要明確授權及接通來源，沒有預設掃描。

舊 scripts/Submit-AutonomyEvent.ps1、Invoke-Autonomy.ps1、Register-AutonomyTask.ps1 是先前偏離需求的 inbox 路線，僅保留供遷移追溯；不要用它們安裝或啟用新版。停用舊任務後啟用同主對話喚醒，不能兩套同時運作。

實際意圖、狀態、Session、成果與日誌僅留本地，不上傳公開 Git。

## 輸入可靠性修正

使用者回報 Running hook 卡死後，先前僅憑 transcript 判定可用的結論已修正。新版增加原生健康守門、輸入驗收與有界 setup 超時監控；實際處置、測試及未驗證界線見 [RECOVERY.md](RECOVERY.md)。不能把 queue 成功當作完整自主性。

## 啟用不重複追問

輸入 $always-on 就已明確指定目前對話。Agent 內部切換並停用舊 timer，不再問「要遷移綁定嗎」。一般任務直接執行，閒置時不 queue 技術訊息、不呼叫模型。內部 durable work status 由 Main 維護，不要求使用者編輯。

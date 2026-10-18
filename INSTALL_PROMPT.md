# 交給 Codex 的一次性安裝指令

讀取本 repo，將 always-on skill 安裝到目前使用者的既有 Codex，並把必要啟用規則合併進使用者 AGENTS.md。使用 scripts/Install-AlwaysOn.ps1，由你執行內部安裝，不要求人類開 PowerShell。先檢查現有設定，保留全部既有內容；腳本只備份並合併有標記的規則區塊，不修改 config.toml、模型路由、MCP、認證或其他 skills。

安裝完成後，在目前人類選定的 Codex 主對話讀取並啟用 always-on skill。所有任務、修正、執行、有限原生子代理派工、驗收及回報都以此主對話為入口。不要建立另一個聊天、UI、inbox 工作入口或代理框架。GitHub 是來源，不是日常操作介面。

根據真實意圖建立或合併私有 INTENT、STATE、PROGRESS，不覆寫舊責任。若有舊 inbox 定時任務，確認是本次安裝留下的後停用，保留舊狀態。不要影響其他排程。

已授權 Always-on 時依技能 activation.md 接上同對話喚醒。桌面版使用實際可呼叫的 native heartbeat；本機 CUI/CLI/IDE 驗證原生 codex queue 後綁定已確認的當前 UUID；source=vscode 不代表不支援，不用 exec resume、不建立替代 Main。人類不需操作內部腳本。未提供當前 UUID 的 CLI 入口，不准猜最新 Session。已有活動回合或未完成 tick 時跳過排隊。分別驗證 queue ack、原主對話實際回覆與排程呼叫，明確呈報其他環境的界線。

確認技能發現、既有規則保留、同主對話綁定、實際恢復與結果保存，再分別回報已安裝、已建立排程、已實際觸發、尚未驗證。不要把建立排程當成已完成第一次定時喚醒。Main 預期 gpt-6.1-sol low，原生 Worker gpt-6-luna low；不得聲稱載入技能已改變當前模型。

人類之後只在 Codex 正常說話。沒有新工作安靜等待，未完成且有合理下一步就繼續，阻塞保存恢復條件；不做無限 Goal、不空轉。對外操作與來源範圍依既有授權，不因自主模式擴權。安裝與必要驗證自行完成，不把普通工程決策交還人類。

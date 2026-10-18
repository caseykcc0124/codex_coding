# Codex Native Autonomy：Windows CLI 安裝與啟用

此專案使用 Codex CLI、原生 Luna 子代理、私有 Markdown 狀態與 Windows 工作排程器。沒有額外 Agent framework 或常駐後端。

## 交給安裝 Agent 的指令

在目前授權的 Windows 工作區部署此專案。先讀 AGENTS.md 與 WINDOWS_CLI.md；保留全域 AGENTS、MCP、Skills、認證與公司強制政策，只合併必要的專案設定。Main 使用 gpt-6.1-sol low，原生 poc_worker 使用 gpt-6-luna low，不得假稱模型已切換。

1. 取得一般化來源並檢查腳本。備份將合併的專案檔案，不覆寫既有私有狀態。
2. 從 .autonomy/templates 初始化 INTENT.md、STATE.md、PROGRESS.md；依人類最新意圖寫入工作範圍及授權。實際公司資料不得公開。
3. 驗證 CLI 登入、sandbox 命令與工作區寫入、原生子代理、指定 Session 恢復。Windows runner 使用 MXC sandbox，不跳過審批或關閉隔離。若公司裝置不支援 MXC，停止並呈報明確原因，不自行放寬權限。
4. 自行完成一項有界事件驗收、第二項事件 Session 恢復、相同事件不再呼叫模型、Windows 排程實際觸發的確認。不要要求人類逐輪操作。任何失敗保留本地證據並修復，不能只以排程已建立宣稱能工作。
5. 人類已授權長期運作時，使用 scripts/Register-AutonomyTask.ps1 建立每 15 分鐘任務。未授權則只做一次性驗證。確認任務、下一次時間與實際執行結果。
6. 日常工作透過 scripts/Submit-AutonomyEvent.ps1 寫入明確任務與驗收條件。Main 每輪最多處理一個事件；必要時派一名原生 Worker，驗證證據並更新狀態後結束。沒有新事件時不呼叫模型。
7. Teams/Outlook 只有在明確指定授權範圍、實際連線與游標收集方式後才啟用。不得掃描未指定的公司資料。目前 runner 只收本地 inbox，不能宣稱已監聽郵件或聊天。
8. 使用 Get-AutonomyStatus.ps1 查看進度、阻塞、Session、最近結果與排程。結果保存在本地；LINE、郵件或其他外發通知必須另有明確授權與實際通知通道。

可自主執行授權工作區的可恢復修改、測試、證據保存與草稿。外發、push、部署、刪除及新增承諾依人類明確授權處理；本 runner 保守禁止這些外部副作用。阻塞事件不空轉，修復後更新原事件再觸發。

完成後只回報實際可用能力、已啟用來源、排程狀態及下一次時間、真正未解決的阻礙。不得把本機結果當成公司電腦也已部署。完整條件與限制見 WINDOWS_CLI.md。

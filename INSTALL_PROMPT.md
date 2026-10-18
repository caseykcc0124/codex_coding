# 交給 Agent 的安裝與啟用指引

將下面整段交給**你要作為 Main 的既有 Codex 對話**。Agent 負責取得來源、安裝、接上喚醒及驗收；你不需要執行 PS1 或另外建立任務入口。

## 可直接貼給 Agent

請從 https://github.com/caseykcc0124/codex_coding 取得最新 main，讀取 INSTALL_PROMPT.md、skills/always-on/SKILL.md 與 references/activation.md，將 Always-on 安裝並啟用於目前這個 Codex 主對話。

我的使用方式是直接在目前 Codex 對話交付任務、追加意圖及接收結果。不要另外建立聊天、inbox、UI、框架或工作入口。GitHub 僅作安裝來源。這次指令授權安裝必要技能與合併規則、建立本對話每 15 分鐘的喚醒及有界功能驗證，不授權掃描未指定帳號或對外發送內容。

### 1. 保留現有環境並安裝

- 檢查已有來源與版本，更新到最新 main；不要覆寫使用者未提交的變更。
- 讀取並執行 scripts/Install-AlwaysOn.ps1。使用實際 CODEX_HOME，保留既有 AGENTS.md 全文、config.toml、模型路由、MCP、認證與其他 skills；只合併已標記的 Always-on 規則區塊，先備份。
- 讀取安裝後的 skill，確認 Codex 能找到它。已開啟客戶端若尚未刷新技能，先由你直接讀取已安裝 SKILL.md 繼續，不把重新開機當作一般必要步驟。
- 在授權工作區建立或合併私有 INTENT.md、STATE.md、PROGRESS.md，不覆寫既有責任。工作狀態、UUID、transport、成果與日誌不得公開提交。

### 2. 綁定目前主對話

- 由 CODEX_THREAD_ID 或可信的當前 runtime metadata 取得 UUID，核對對應 transcript 的 UUID、來源與 cwd。不得以最新檔案或 --last 猜 Session，也不得另建替代 Main。
- 本機 CUI/CLI/IDE：檢查原生 codex queue 能力（已測試 0.163.0 系列），驗證既有原生共享 server 能接達目前 Main。source=vscode 不是拒絕條件。使用技能內部 Bind-Session.ps1 綁定當前 UUID 與工作區；由 Windows timer 呼叫 Wake-Session.ps1，再經 `codex queue --remote unix:// --thread <UUID>` 排入原主對話。
- 保存已確認的原生 CLI binary，避免排程 PATH 與互動環境不同。不能用 exec resume 恢復正在開著的 Main，不能終止它、搶 writer、另起模型程序或默默遷移 server。若版本缺少 queue，明確回報版本與需要的原生能力，不以放寬權限解決。
- 桌面入口有可用 native heartbeat 時可使用它，必須綁定同一主對話；不要為同一 Main 同時啟用兩種 timer。
- 若已有此 Main 的排程，核對 action/UUID 後沿用或恢復，不重複建立。只停用已確認屬於舊 inbox 路線的任務，保留舊狀態，不影響其他自動化。

### 3. 自行完成驗收

分別確認：技能與規則安裝、既有設定保留、排程建立、queue 接受、原 Main 實際處理、結果保存。不得把其中一項當成全部通過。

- 使用有界且不存取外部來源的 marker 驗證原生 queue；核對原 UUID 的 assistant 回覆及 task_complete，不只看 Queued message。
- 實際觸發註冊的 Windows 任務，確認結果碼及對應 tick 在原 Main 完成。
- 驗證 active turn 與未完成 pending tick 不會持續堆入喚醒；不重送交付結果不明的訊息。先核對 marker 與 transcript，再處理游標。
- 啟用指令本身仍在活動回合時，喚醒應跳過或排隊等待；不要在同一活動回合死等它自己完成。先結束啟用回合，讓排隊訊息或下一次 timer 在原 Main 執行，再於該回合保存驗收結果。這不需要人類手動重跑測試。
- 尚未發生第一次喚醒時，只回報「已建立，首次觸發待驗證」，不能宣稱已全數驗收。失敗保存原因與恢復條件並自主處理正常工程問題，不盲目重試或擴權。

### 4. 日常工作與回報

人類之後直接在主對話說話。Main 維持最新意圖，能做就執行，需要分工時派有界原生 Worker，實際驗收成果後保存狀態並在原對話回報。Main 預期 gpt-6.1-sol low、Worker 預期 gpt-6-luna low；以實際客戶端路由為準，不宣稱載入技能已切換模型。

沒有新工作安靜等待；有未完成且可推進的工作就繼續；阻塞記錄恢復條件，不無限 Goal 或反覆空轉。Teams/Outlook、遠端專案、外發及部署依另行明確授權。Windows 需要使用者登入、電腦可運作與既有原生 server/認證可用；其他 OS、遠端或已關閉客戶端不得直接沿用本機成功結論。

完成後簡短回報：安裝版本、綁定的 Main、啟用的喚醒通道、下次時間、已完成的驗收與真正未解決的項目。不要要求我執行 PS1、填 inbox 或換到另一個對話。

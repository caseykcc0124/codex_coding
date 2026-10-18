# Always-on 需求對齊與驗證

**輸入卡死回歸已使先前的完整可用結論失效。** 下列傳輸驗證仍成立，但不能代替互動輸入與故障恢復驗收；最新處置、保護與驗證界線見 [RECOVERY.md](RECOVERY.md)。

## 使用方式

GitHub 只提供安裝包。使用者在既有 Codex 主對話啟用 always-on，直接交付、修改與查看工作；Main 執行、有限派原生子代理、驗收並保存私有意圖。沒有另一個 inbox、對話、UI 或代理框架，內部腳本由 Main 執行。

## 喚醒實作修正

先前以 Windows timer 呼叫 exec resume 的設計不適用於正在開著的主對話，實測被 already has an active writer 拒絕。僅允許 cli/exec、拒絕 vscode 來源也是錯誤的判定方式。

新版依能力選擇：有 native heartbeat 的客戶端可以使用它；本機 CUI/CLI/IDE 驗證原生 codex queue 後，Windows timer 將 tick 排入已確認 UUID 的既有主對話。原 Codex 繼續持有 writer，保留其模型與權限，不再另起模型或搶 writer。OS 僅提供 timer；原生 queue 是工作交付通道。

安裝器備份並合併使用者 AGENTS 的管理區塊、安裝 self-contained skill，不改 config.toml、MCP、認證或其他 skills。舊 inbox 與桌面測試排程維持停用。

## 本機證據（2026-10-18）

- 使用者測試的原對話 source=vscode，當前 UUID 與 cwd 均已從私有紀錄核對。
- 原生 queue 發送有界 marker，原本仍開著的主對話實際回覆 LIVE_MAIN_QUEUE_OK；同 transcript 記錄完成。
- 新喚醒腳本發送 tick，原主對話檢查私有狀態並回覆 WAIT，記錄 task_complete。
- Windows 同 UUID 任務已實際啟動，LastTaskResult=0；該次 tick 在原主對話回覆 WAIT 並完成。此項包含排程、queue ack 與同主對話處理，不只確認註冊。
- 安裝保留原規則與重複安裝不增生管理區塊已驗證。
- Active turn 與 outstanding pending tick 的守門檢查通過，兩者都不產生新 queue request。
- Skill 命名/frontmatter、PowerShell 語法及 Git 來源檢查通過。

## Headless 排程條件

綁定時記錄當前可用的原生 Codex binary（優先 CODEX_CLI_PATH）及明確的原生共享 server endpoint（unix://），僅保存在私有 binding，避免排程的 PATH/環境差異。原生 queue ack 必須包含目標 UUID；若短生命 queue client 在 ack 後保留 console handle，僅結束此次自己建立的 client，不終止既有 server/Main 或 process tree。未取得 ack 不自動重送，保留 pending marker 供核對。

## 邊界

已驗證的是本機支援 native queue 的入口，不是所有版本、OS 或遠端客戶端。Windows helper 需要 PowerShell 7、登入中的使用者、可用 Codex/本地 transport。客戶端關閉、remote endpoint、其他 OS timer 以及分頁 transcript 的 completion 追蹤未全面驗證；不可宣稱無條件通用。pending 無法確認時保守停止排隊，Main 應核對結果後恢復。

模型不因載入技能自動更換。Teams/Outlook、LINE 與外部操作仍依各自明確授權，不自動掃描或發送。實際意圖、Session、IPC、成果及日誌不公開。

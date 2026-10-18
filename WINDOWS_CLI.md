# Windows Codex CLI 喚醒

使用 Windows 工作排程器每 15 分鐘啟動一個有限回合，沒有新增 inbox 事件時不呼叫模型。這是 Windows 內建排程，不是 Codex CLI 原生 Scheduler，也不是常駐 Agent 程序。

## 啟用

保留全域設定、MCP 與認證。在核准工作區合併專案設定與 scripts；將 `.autonomy/templates/*.example.md` 複製成對應私有狀態檔，已有內容不得覆寫。先編輯 INTENT，寫明真實工作與授權範圍。

```powershell
# 在工作區手動執行一次有限回合
./scripts/Invoke-Autonomy.ps1
# 明確授權長期執行後才建立每 15 分鐘任務
./scripts/Register-AutonomyTask.ps1
# 或只建立一次性驗證任務
./scripts/Register-AutonomyTask.ps1 -TaskName Codex-Autonomy-Validation -Once
```

把已授權工作寫入 `.autonomy/inbox/<event-id>.md`，包含來源、目標、驗收條件。排程只監看此資料夾的 Markdown；不會自動掃描 Teams、Outlook 或 Git。其他來源必須另外明確設定核准的收集方式。

首個事件建立 Session，後續使用保存的 UUID 呼叫 `codex exec resume`。Main 使用 Sol Low；原生 `poc_worker` 使用 Luna Low。CLI 使用 workspace-write 與 MXC Windows sandbox，不使用略過審批或 sandbox 的旗標；需要新的權限時應回報 blocked。

JSONL 日誌、Session UUID 與雜湊游標保存在被 Git 忽略的 `.autonomy/runtime/`。只有 CLI 成功結束、出現 turn.completed 且結構化結果為 done、evidence_paths 指向工作區內存在的檔案才記錄完成。blocked 或失敗事件以雜湊暫停，修復原因後更新事件內容以重新觸發。程序在寫入游標前崩潰可能重試，因此任務本身仍須可重入；外部副作用不能依賴此游標提供 exactly-once 保證。

排程與檔案鎖都避免重疊啟動；互動 CLI 若同時編輯同一 Session/狀態，請先停用排程。修改 INTENT 後需要重新評估的任務也應更新 inbox 事件。

## 運行條件與管理

使用目前使用者的 Interactive 登入權杖、不保存密碼、不提高權限。需保持 Windows 使用者登入、電腦可運作、網路與 Codex 登入有效。登出、關機或睡眠期間無法保證準時執行；StartWhenAvailable 允許恢復後補跑。最長回合兩小時。

```powershell
Get-ScheduledTaskInfo -TaskName Codex-Native-Autonomy
Disable-ScheduledTask -TaskName Codex-Native-Autonomy
Unregister-ScheduledTask -TaskName Codex-Native-Autonomy -Confirm:$false
```

實際工作狀態與日誌不得提交公開 repo。此喚醒器沒有替人類發訊息或推送遠端的授權。

## 日常交付與結果

```powershell
./scripts/Submit-AutonomyEvent.ps1 -EventId task-001 -Task '整理指定專案的待辦' -Acceptance '提供可追溯的待辦清單與來源位置'
./scripts/Get-AutonomyStatus.ps1
```

一般化 runner 禁止外發、push、部署與排程修改；需要此類動作時由人類明確授權的互動入口執行。本地完成結果保存在 runtime 的 result.json，並由 STATE/PROGRESS 接續；沒有另行配置的 LINE、郵件或桌面推播。不能將本地結果保存宣稱為已發送通知。

任務優先使用 PowerShell 7，未安裝則使用 Windows PowerShell；明確設定 UTF-8，原生命令的 stderr 警告保留於日誌，不直接當作終止例外。任務失敗可查看 runtime/last_failure.json。MXC 不可用時停止，不自動降級隔離或修改全域設定。

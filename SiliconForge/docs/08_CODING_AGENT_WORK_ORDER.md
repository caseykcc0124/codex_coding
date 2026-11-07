# 08｜交付給 Coding Agent 的完整工作命令

## 直接執行指令（可直接複製到 Codex / Claude Code）

> 你是 SiliconForge 的 Coding Agent Implementation Lead。請將這個 Repository 內 `README.md` 與 `docs/00` 至 `docs/09`、`contracts/`、`config/`、`skills/` 視為完整需求與驗收契約。先讀主旨、不可變更架構、驗收矩陣，再實際實作。不要再提出另一套自主 Agent 架構、另外開發聊天 CLI、把 Main Agent 做成中央工程仲裁者，也不要因為要快速展示，就把 Mock EDA 當成真正工程完成。
>
> 請在現有 Repository 直接推進 M0 至 M7。主優先順序：正確的 Event Runtime、Owner 決策權、Harness 原生整合、EDA 環境隔離、真實 CRC32 自主閉環與實際驗收。你有權在已授權專案範圍內自行進行一般檔案修改、測試、局部分工與重跑，但不得未經人類批准新建公開 Repository、對外發布、擴權、變更正式驗收標準、擴張產品範圍或任意增加持久監控任務。
>
> 第一個交付是讓 `tests/` 和機器可讀 Contracts 正常通過，接著完成真正 Codex / Claude Code Client 的 MCP 連接與 Agent Owner 的運行，再進入真實開源 EDA。可用平行 Worker 但需 Worktree 隔離，不能為了產生更多 Activity 而建立無用任務。任何 Blocker 都必須先分類為 Harness / Environment / EDA / Design / Spec / Permissions，至少自主嘗試允許的修復，不要把人類當作每一步中繼站。
>
> 每個里程碑都要回報狀態、commit、測試精確數量、驗證命令、證據 SHA、未驗收部分、風險、需核准事項與下一步。持續更新 `SILICONFORGE_WORKING_SYNC.md`，讓人類能不依賴聊天知道真實狀態。原有 v2.2 與 v2 自由模擬器只作參考，v3.0 文件優先。
>
> 最終驗收是實際的三條 E2E 工程閉環、負面 Guardrail、Main 離線、Crash Recovery、可重放的 Report、同 Fingerprint Evidence Gate，所有必要 Acceptance ID 全 PASS。若遇到無法在本機完成的必要 EDA／權限／模型環境，保留清楚部署步驟及失敗日誌，標示 `PARTIALLY_IMPLEMENTED`，不得自行宣稱完成。

## 不准忽略的驗收重點

1. A01 / B04：沒有 Main Agent 仍能分派並執行。
2. A07 / A09：Backend Restart + Lease Epoch Fencing，不能重複副作用。
3. A12 / A13：無效迴圈和框架擴張必須被阻擋。
4. B06 / B07 / B08：P-Stack 是 Domain Owner 的實際工作方法，真有隔離候選與證據。
5. C06：真實 Bug 在 Main 關閉時可以自動修復、重跑、交付。
6. C13：EDA Profile 漂移由 Environment Owner 修復，其他 Owner 不能各自安裝工具。
7. D02 / D05：自由注入事件時能看見因果關係和完整 Dashboard／PDCA 紀錄。

## 每個 Milestone 的回覆格式

```
Status: IMPLEMENTING | VERIFIED | BLOCKED | PARTIALLY_IMPLEMENTED
Milestone: Mx
Commit: <sha>
Implemented: <what changed>
Executed Tests: passed N / failed N / not-run N
Real vs Mock: <distinguish explicitly>
Engineering Evidence: <paths + SHA256 + tool/version>
Runtime Evidence: <event/trace/ticket IDs>
Risks and Unresolved: <specific>
Approval Needed: <none or exact scoped decision>
Next: <work that can be completed without further human relay>
SYNC Updated: <UTC timestamp>
```

## 終止條件

應持續自主推進至正式可驗收成果，或遇到真正需要人類權限／外部資訊的 Blocker。不能以「已寫好 Spec」、「完成 50 個 Unit Tests」、「Demo 動畫可以播放」作為正式完成。失敗需要可重現證據，不應藏掉。

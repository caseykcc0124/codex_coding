# 輸入卡死事故與驗收修正（2026-10-18）

此前 queue 與 transcript 測試通過，卻未驗證 CUI 真正接受輸入，因此「可直接使用」的結論不足。使用者畫面顯示 Running hook 與排隊指令，這是實際回歸，不能用後端 task_complete 否認。

## 實際處置與觀察

- 先停用喚醒，沒有繼續往主對話塞測試訊息。
- 找到持續運行的 Windows sandbox setup refresh，日誌反覆處理家目錄 ACL。僅停止該暫時輔助程序，保留 Main/server、權限與既有 hooks；之後原生 thread 狀態為 idle。
- 使用者將原終端帶到可操作前景後，畫面已顯示先前排隊工作完成與輸入提示。實際輸入字元、確認回顯並清空，沒有送出測試任務。這些觀察確認當前輸入可用，不單憑紀錄推定 UI，也不把所有恢復因果歸給單一操作。

## 新的守門與有界恢復

- 每次喚醒先查原生 thread status；非 idle 不新增 queue。
- 私有 wake-suspended.json 可阻止再次啟用，直到真正輸入驗收通過。
- 每分鐘 Watch-Main 不呼叫模型。僅針對自己的 pending 自動 tick、精確工作區、既有 managed server 的超時 setup refresh 做有界處置。
- 不處置人類/其他回合；不停止 Main/server/process tree；不關閉 hooks 或安全保護。恢復後確認 native idle，同一 tick 最多兩次，失敗暫停主喚醒。
- 暫停時停用主 timer 與 -Recovery timer。UI draft 不自動提交、重放或丟棄。

## 驗證與界線

- 真實事故中 setup helper 結束後 native idle、原視窗輸入回顯/清空已觀察。
- Recovery target policy 的正向候選、無關工作區/parent、非 refresh、未超時、早於 tick 等拒絕條件測試通過。
- PowerShell 語法與 NativeMainRpc 編譯通過；監控健康檢查及其 Windows task 執行結果驗證通過。
- 尚未再次故意製造真實長時間 sandbox 卡死，以免中斷使用者工作；因此新 timer 的完整故障注入恢復並未宣稱驗證。
- 不保證所有 CUI/平台故障均可自救。對無法識別的 UI 卡死保守停止自動干擾，保存原因；不能宣稱完全無人介入或無條件通用。

# KA-DMM：Coding Agent 固定工作入口

> 更新日期：2026-11-07  
> **唯一最新的完整執行授權**：[KA-DMM Autonomous End-to-End DS Replacement Mission v2.0](./KA_DMM_Autonomous_End_to_End_DS_Replacement_Mission_v2.0.md)  
> 狀態：**完整工程任務已一次授權，等待 Coding Agent 讀取並執行。**

## 強制狀態同步

**本總任務執行期間，Main Agent 必須把去敏進度更新至公開 Repository 根目錄的 [KA_DMM_STATUS_SYNC.md](../KA_DMM_STATUS_SYNC.md)。**

- ACTIVE 期間至少每 **60 分鐘**更新一次，WorkItem 開始／完成、Gate 改變、重大阻擋、恢復、Engineering Complete 或需使用者授權時立即更新。
- 主 Agent 統一寫入。Sub Agent 只回報給 Main，不能各自改檔。
- 每次更新工作階段、實際已完成能力、測試／證據摘要、當前阻擋及自主修復動作、下一里程碑和授權需求。
- 預先讀取 GitHub Blob SHA 並做衝突安全更新。寫入失敗不能宣稱同步成功。
- 公開資訊必須去敏，私有 KA 檔案、公司內容、真實程式碼、測試原文與環境細節一律不推送。
- ChatGPT 的每兩小時定時巡檢已成功啟用（Automation ID：6aee7c6050408191a82be7b7b92d8954），只在重大進展、需授權或 ACTIVE 狀態超過 3 小時未更新等情況通知使用者；Coding Agent 每小時去敏狀態同步持續照常執行。
- 完整同步契約以 [自主總任務 v2.0 的 8A 節](./KA_DMM_Autonomous_End_to_End_DS_Replacement_Mission_v2.0.md) 為準。

## 給 Coding Agent 的直接指令

請由本公開 GitHub Repository 的指定 Markdown 檔取得完整工作規格，並記錄真正抓取到的 GitHub Commit SHA。

從現在開始，**不必在每個 M2 子批次、Gate 或技術缺口後停止等待 ChatGPT 再發布新指令**。依 v2.0 中 E0 至 E9 的工作路線，在既有 Knowledge Agent Repository 自主完成 DoclingDocument 替換 DS 的全部程式、測試、資料遷移工具、Review/Effective、Chunk/RAG、Viewer、升版相容與 DS 清理，直到達到 Engineering Complete 與 READY_FOR_RELEASE。

前輪 M2-V0 已由使用者回報 PASS。若 M2-V1 已在進行，請先保存既有成果與 Commit，將它納入 E1，**不得推倒重做**；之後直接沿 v2.0 續做全部 E2～E9。

請把阻擋轉成可實作的修復、最小兼容、受控降級或具體外部依賴，不能讓不相關的問題阻止其他模組進展。只有涉及正式環境不可逆操作、未授權網路／權限／秘密或核心架構實質變更時，才需要向使用者要求明確核准。完整規則請以 v2.0 為準。

**禁止**：將私有 Knowledge Agent 原始碼、公司文件或內部測試結果自動推到本公開 Repo；未授權就變更正式 DB／Index、部署或上線。當工程完整、正式切換待授權時，交付可運行的 Release Candidate、回退方案及全部可重跑證據。

## 版本沿革

- v1.2 主計畫：[架構與原始分批 Gate](./KA_DMM_Docling_Native_Migration_Plan_v1.2.md)。
- M2-V0 v1.3：[已回報 PASS 的原生 PDF Shadow 切片](./KA_DMM_M2_V0_Delivery_Execution_Guide_v1.3.md)。
- M2-V1 v1.4：[DCLX 工作包，已納入 v2.0 的 E1](./KA_DMM_M2_V1_DCLX_Native_Import_Execution_Guide_v1.4.md)。
- v2.0：[整體自主工程交付總授權](./KA_DMM_Autonomous_End_to_End_DS_Replacement_Mission_v2.0.md)。

若舊文件要求「完成本批即停止、等待下一份 GitHub 指令」，**該限制已由 v2.0 的完整任務授權取代**。舊文件的測試、資料安全、證據與回退義務仍有效。**正式環境變更仍須依 v2.0 第 10 節明確授權**。

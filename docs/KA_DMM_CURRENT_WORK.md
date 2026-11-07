# KA-DMM：Coding Agent 固定工作入口

> 更新日期：2026-11-07  
> **唯一最新的完整執行授權**：[KA-DMM Autonomous End-to-End DS Replacement Mission v2.0](./KA_DMM_Autonomous_End_to_End_DS_Replacement_Mission_v2.0.md)  
> 狀態：**E9 Final Closure 已發布，Coding Agent 應在既有 KA 專案持續執行至 Engineering Complete／Ready for Release 的真實 Gate。E10 正式切換未授權。**

## 最高優先：E9 最終驗收凍結與強制結案（立即生效）

**Coding Agent Main 必須先讀取並立即執行：[KA-DMM E9 最終驗收凍結與強制結案命令](./KA_DMM_E9_Terminal_Acceptance_Freeze.md)。** 這是使用者針對本輪 E9 的最新明確要求，優先於下文所有允許持續擴充測試、額外探索、增加 Gate 或反覆驗收的建議。原 Mission v2.0 的正式環境邊界與不得偽造 PASS 規則保留。

請凍結已有驗收清單，不得自行增加新測試或新工作包。**立即以最新 Office source-lineage 修復後的 successor Commit**執行既定 22 步 CI 及原有 50 項回歸，統合既有 clean 84 PDF、Review/Index/Viewer、170 欄必要責任、DS Retirement、回退及 RC 證據。只允許對已存在關鍵失敗做一次最小修復及同集合必要重驗。完成後直接給最終 Gate 判定與 Release Candidate 交付，**停止本輪測試活動，不得自行提出下一批測試**。若真實關鍵 Gate 仍未通過，須如實以 NOT_READY 和有界缺口報告結案，禁止虛報 Engineering Complete；E10 仍需另行授權。

## 本輪最新執行指令（E9 Final Closure）

**請 Coding Agent Main 優先讀取並執行：[KA-DMM E9 Final Closure：最終工程收斂與發行驗收指令](./KA_DMM_E9_Final_Closure_Execution_Guide.md)。**

本 E9 指引是 [Autonomous Mission v2.0](./KA_DMM_Autonomous_End_to_End_DS_Replacement_Mission_v2.0.md) 之實施細則，不重新授權 E10，也不更改正式環境安全界線。Main 必須接續既有 E0～E8 局部 PASS 與 22 步整合結果，完成 Feature Commits、Manifest、全離線 PDF 重建、真 CI、170 欄產品責任、DS 退休驗證、最終 Release Gates 與可重跑交付包。不得重頭另建專案、逐項等待 ChatGPT 或以狀態檔摘要代替產品驗收。

請從 main 取得兩份指令檔的實際 GitHub Commit／Blob SHA，並讀取既有本地 KA 工作樹與 receipts 以取得真實最新狀態。持續依下節只更新根目錄唯一去敏同步檔，不得將內部工程資料推送公開。

## 離線套件阻擋處理：立即生效

**使用者已要求由 ChatGPT 協助取得可公開且授權的缺失 Wheel，Coding Agent 不需等待總指令。** 請 Main 立即讀取：[E9 離線 Wheel 取得與交接指引](./KA_DMM_E9_Offline_Wheel_Acquisition_Handoff.md)。

目前公開摘要只有 18 件缺失數量（15 件 runtime 必需、3 件 exact profile 其他項），尚無可用於正確下載的套件名稱／精確版本／目標 Python ABI／Windows tags。請立即依指引，將**允許公開的 PyPI 缺件清單**加入唯一的 `KA_DMM_STATUS_SYNC.md`，保留資料保護限制與所有現有欄位。同時持續 170 欄產品歸屬、PPTX 回歸、歷史映射、Release Gates 等其他無依賴工作。

公開 GitHub 一般 Repo 不得直接當作未審查第三方大型二進位套件倉庫。二進位交付必須先驗 license、hash 和可用傳輸通道；來源清單或 README 不能代替真正 offline rebuild PASS。不准私自繞過網路限制、發布受限 wheel 或執行 E10。

## E9 Windows CPython 3.12 Wheelhouse：GitHub Actions 交接

18 項公開 PyPI 缺失 Wheel 已有精確下載清單，並新增受控 GitHub Actions 工作流程：

* [Exact 18 requirements](./KA_DMM_E9_Offline_Wheels_Requirements.txt)
* [Wheel verification script](./ka_dmm_tools/verify_public_pypi_wheels.py)
* [GitHub Actions workflow](../.github/workflows/ka-dmm-e9-wheelhouse.yml)
* [Workflow Runs 與下載頁面](https://github.com/caseykcc0124/codex_coding/actions/workflows/ka-dmm-e9-wheelhouse.yml)

此 Workflow 以 `windows-2022`、CPython 3.12，從公開 PyPI 精確下載 18 個原始 Wheels，不允許自動替代版本，核對官方 PyPI wheel 原始 SHA256 後才上傳 `ka-dmm-e9-18-wheels-cp312-win-amd64` Artifact。**工作流程已提交不等於實際執行成功或檔案已交付**，Main 必須查實 run status、Artifact、18 個 wheel、manifest 與雜湊。若 Workflow 失敗，記錄公開可去敏根因與最小下一步，持續其他 E9 工作。

Main 在已授權環境取得已驗證 Artifact，合併原有本地 66 個 wheels，真實執行 `--no-index` clean offline install 與 PDF→Review→Approval→Index→Serving，存下安裝與 Gate receipts。只有真正下載、SHA、清潔重建與既定測試完成才解除 offline Gate。不得將 artifacts 當成 Production 部署授權，亦不得把公司檔案或私有原件推送到公開 Repository。

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

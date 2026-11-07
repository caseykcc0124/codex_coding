# KA-DMM：Coding Agent 固定工作入口

> 更新日期：2026-11-07
> **當前執行階段：E10 Production Acceptance／Readiness。**
> E9 已完成隔離工程並宣告 `ENGINEERING_COMPLETE / READY_FOR_RELEASE`。此階段**不重開 E9，不自行新增測試，也不自行執行正式部署**。
> 原始完整授權與安全界線仍依 [Autonomous Mission v2.0](./KA_DMM_Autonomous_End_to_End_DS_Replacement_Mission_v2.0.md)，其中第 10 節的正式環境與不可逆操作必須明確核准。

## 最新最高優先執行指令：E10

**Coding Agent Main 現在必須讀取並自主開始執行：[E10 Production Acceptance 與受控 Cutover 執行指令](./KA_DMM_E10_Production_Acceptance_and_Cutover.md)。**

使用者已授權**開始 E10 工作**。這涵蓋 E10.1 的本地／隔離／已授權 staging 準備、Release Baseline 與部署包驗證、共同服務配置 Inventory、原有 Production Acceptance Criteria、Cutover／Rollback Runbook 和一次完整的使用者授權包。**它不代表已授權真正的 Production DB／Index／服務／流量、正式資料備份、正式資料讀寫、不可逆刪除或正式共同服務變更。**

Main 自行推進全部現有授權的 E10.1 項目，使用既定 Git Commit、測試與驗收契約，主動接收 Sub Agent 成果，勿因缺少正式生產權限而停止其他可執行準備工作。不必逐批向 ChatGPT 索取指令。

當 E10.1 Ready 時，在唯一同步檔公布**去敏 Cutover Authorization Packet**：明確 RC Commit、待核准環境／操作、備份恢復、真實品質與共同服務 Gate、Canary 流量及寫入比例、Alias 切換、Rollback Trigger、風險與建議。只有取得使用者對**特定正式動作**的明確授權後，才可依 E10 指令執行 E10.2 與 E10.3；未授權不得冒稱已完成 E10 或偷渡正式存取。

## 已完成工程基線（僅作歷史參考）

* E9 最終私有 Release Commit：`fb1aa0e6dc9da4fedcd285ea2471dff230f862ad`。
* 公開 E9 最終狀態及測試結果：[KA_DMM_STATUS_SYNC.md](../KA_DMM_STATUS_SYNC.md)；依最新讀到的 GitHub 狀態為準。
* E9 凍結驗收指令：[KA_DMM_E9_Terminal_Acceptance_Freeze.md](./KA_DMM_E9_Terminal_Acceptance_Freeze.md)，**已執行完畢，非目前優先指令**。
* E9 Final Closure：[KA_DMM_E9_Final_Closure_Execution_Guide.md](./KA_DMM_E9_Final_Closure_Execution_Guide.md)，已完成。
* [E9 公開離線 Wheel 交接指引](./KA_DMM_E9_Offline_Wheel_Acquisition_Handoff.md) 與 [18 項精確套件版本清單](./KA_DMM_E9_Offline_Wheels_Requirements.txt)，供可重建性追溯。
* [E9 公開 Wheelhouse Workflow](../.github/workflows/ka-dmm-e9-wheelhouse.yml) 屬發行依賴輔助流程，不可代替已完成的隔離工程及新的生產驗收。

不得將舊 E9 文件的「立即執行」、「NOT_READY」、「缺18件 Wheel」等歷史敘述誤認為現在的任務狀態；應以最新 `KA_DMM_STATUS_SYNC.md` 最終 E9 區段與實際私有 receipts 為準。

## 強制單一 GitHub 去敏狀態同步

**唯一檔案：公開 main 分支根目錄 [KA_DMM_STATUS_SYNC.md](../KA_DMM_STATUS_SYNC.md)。** 不新增第二份公開進度文件，不覆蓋 E9 的已保存失敗與完成證據。

1. Main 啟動 E10.1 時，實際讀取本入口與 E10 指令的 GitHub Commit／Blob SHA，在現有狀態檔加入 `instruction_version=v2.0 / E10`、`active_stage=E10_PRODUCTION_READINESS`、現有 RC SHA、`production_status=NOT_AUTHORIZED`、當輪工作、下一個 Gate 和 requires_user_action；不能未執行就宣稱 ACTIVE／PASS。
2. ACTIVE 期間至少每 60 分鐘更新一次；Gate 改變、重大風險、E10.1 Ready、要求 Cutover 授權、正式切換進展、Rollback 或 Production Complete 時即時更新。Main 唯一寫入，Sub 交付 Main。讀取現有 blob SHA 後條件式提交，衝突重讀合併，不得強制覆蓋。
3. 必須區分「已規劃」「本地已實測」「staging 已實測」「Production 已實測／尚未授權」，提供真實 Pass／Fail／Not Tested／Blocked、關鍵引用錯誤與 ACL、備份可恢復、Rollback、正式 SLO／檢索品質、next_action、requires_user_action 與適用 Release Commit。無新能力不要假裝進展。
4. 公開只寫去敏摘要。私有 KA 程式、公司文件、fixtures、完整 logs、密鑰、內部 URL／路徑、模型、資料庫及真實文件不推送 GitHub；沒有合法權限不新增外網連線或取得秘密。
5. ChatGPT 既有定時監督繼續比較此檔與 commit 歷史，只有重大進展、Gate 變化、授權需求或 ACTIVE 超過三小時未更新才通知使用者。陳舊不等於 Agent 停止或產品故障。

## 結案標準

E10.1 交付：可審閱、可執行的完整 Cutover／Rollback Packet 與已授權隔離環境證據，正式操作仍等待一次精確批准。

E10.2 及 E10.3：只有取得對應正式操作的明確授權，且實際完成 Production 備份、Canary、資料與 Index 受控切換、DS 停寫／必要受控退役、觀察與恢復驗證後，才可宣告 `mission_state=COMPLETE`、`production_status=PRODUCTION_COMPLETE`。

**立即開始 E10.1；不得等待下一份 ChatGPT 指令，也不得自行越過正式環境授權邊界。**

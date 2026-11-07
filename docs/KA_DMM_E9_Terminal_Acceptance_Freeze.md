# KA-DMM E9：最終驗收凍結與強制結案命令

> **立即生效，優先於先前 E9 指引中允許持續擴充測試或無限探索的描述。**
> 原本 [Autonomous Mission v2.0](./KA_DMM_Autonomous_End_to_End_DS_Replacement_Mission_v2.0.md) 的產品安全、不偽造證據、E10 正式環境授權限制仍有效。
> 執行對象：既有 KA 專案 Coding Agent Main 及其 Sub Agents。
> 目的：**在本次執行周期內結束所有已承諾的測試、驗收與 E9 工程 Gate 判定，停止測試範圍蔓延，交付最終報告，不得再要求下一輪測試或新的總工作指引。**

## 1. 本次終局命令

使用者明確要求：
**E9 不能再持續自行發展更多測試、額外研究、新規格、新 Gate、新批次或追加驗收輪次。Main 必須在本次既有工程工作中收斂完成全部事先承諾的測試與驗收，提出最終、可稽核的判定。**

這是**測試範圍凍結及本輪工作強制結案**。不得解讀為可以把 FAIL／NOT_TESTED 寫成 PASS，不得修改 Golden、弱化斷言、隱藏不良結果、略過必要安全驗收，亦不得在無授權下啟動 E10。

## 2. 立即凍結 Gate 與測試清單，不得新增

Main 從**現有 KA Release Candidate、E9 原計畫、已存在的測試 Runner、CI、Manifest、既存 Gate Checklist**固定一次性驗收矩陣，不再引入新的驗收目標；既有 170 欄責任矩陣僅完成**必要產品欄位的歸屬與現成證據判定**，不得以每欄再加一個新測試作為結案條件。

既定的終局檢驗至少包括：
1. 對最新含 Office source-lineage 修復的 **successor commit**，執行已存在的統一 **22 步 CI**，記錄每個 PASS/FAIL/SKIP 與 receipt；舊 RC 的 22 PASS 不得沿用為新 Commit 的結果。
2. 對同一 successor commit，執行原有 **50 項 regression**，逐項與原 49 PASS／1 個已知 PPTX digest FAIL 的 Golden／基準比對；歷史已知失敗維持獨立標記，不得直接宣稱全綠，也不得自行授予 waiver。
3. 使用**已存在**的離線 Wheel／PDF clean 84 安裝與 PDF→Review→Approval→Index→Serving 驗證證據，核實其對應版本、執行環境、hash 與可重現性；必要時僅做一次既定驗收確認，不重開新探索。
4. 以既有 RAG/引用、ACL、Version、Migration／Rollback、Chrome／Viewer、Office 精確來源、DS zero-dependency Guard、Release Bundle／Manifest 的既定 Gate 對應證據，做最終逐項實證判定。
5. 真實 corpus／live LLM 品質或正式規模測試如果缺少授權環境，依照既有門檻**明確列為 NOT_TESTED／BLOCKED_EXTERNAL**，不可持續自創合成測試來填補，不得因此另外開新研發批次。
6. 逐項標示 170 欄中真正產品必需而且可由目前既有證據判定的部分；其餘保留具名 GAP／UNRESOLVED／DEPRECATED_PENDING_APPROVAL。不要把 151 個未逐欄驗證的欄位都當成必須新做 151 個測試。

**禁止**：自訂新的測試矩陣、額外測試層、新分析主題、擴張上游相容性研究、增加新模型／新工具／新來源格式，或者以「還可補測」無限推遲結案。

## 3. 最多一次受控修正和一次完整重驗

對已存在的固定測試若本輪發現**實際 release-critical 失敗**，允許最小範圍的根因修正，限於讓原本已批准的 Gate 通過；修正後對影響範圍做必要定位驗證，再對**同一套已凍結的 22＋50 驗收集合**完整重跑一次，不得因新增想法擴張驗收集合。

如果已證明不能在既定授權、現有資料及可用環境下完成修復或驗證，應立刻分類為有界 BLOCKED／FAIL／NOT_TESTED 並進入**最終結案**；不得再自主衍生新探索任務、反覆詢問使用者或等待更多測試。對安全、資料完整性、ACL、來源誤綁等關鍵風險必須 fail closed，不能帶病宣稱 READY_FOR_RELEASE。

## 4. 必須在本次執行結束時交付的終局狀態

Main 必須完成且停止本輪 E9 測試活動，提交原本 KA Repo 的最終 RC Commit／Manifest／ZIP／receipts／逐項 Gate 報告、Source/Fidelity、DS Retirement、Migration/Rollback、既存限制及正式 E10 Cutover Runbook，並**僅在現有公開狀態檔** `KA_DMM_STATUS_SYNC.md` 更新去敏結案摘要。

終局分流只有：
* **ENGINEERING_COMPLETE／READY_FOR_RELEASE**：既定 Engineering Definition of Done 所有 release-critical Gate 真正通過，所有可執行必要項目已有證據；只剩 E10 正式切換授權。
* **E9_FINAL_ACCEPTANCE_CLOSED_NOT_READY**：既定測試已實際執行或受限而明確封存，存在未通過 Gate／必要外部條件；工程狀態維持 `NOT_READY`，提供**具體且有限的缺口清單、影響與唯一可採取的下一個授權動作**，並停止本輪測試擴張。不得把「最終驗收流程結束」冒稱「Engineering Complete」。

若現有狀態契約不支援新的 `mission_state` 枚舉，維持規格允許值（例如 `PAUSED` 或 `EXTERNAL_BLOCKED`），在 `stage_gate` 或 `current_work_item` 記錄 `E9_FINAL_ACCEPTANCE_CLOSED_NOT_READY`，**不自行發明 machine-state 枚舉**。任何已達成之既有 PASS 保留原實測證據。

公開摘要必須包含：最新本地 commit SHA、凍結驗收清單識別、22/50 最終結果、clean 84、引用錯綁／DS Guard、170 欄責任與 GAP、RC 部署可重建性、PASS/FAIL/NOT_TESTED/BLOCKED 的分別、`requires_user_action` 與最終 `next_action`，清楚區分本地工程、隔離驗證與 Production。只由 Main 更新，每次寫入採 SHA 衝突保護。

## 5. 停止條件與治理邊界

**本輪終點是最終驗收判定以及完整交付，不得以任何一般工程理由自行延長到更多測試。** 如果關鍵問題確實使 Engineering Complete 無法合法成立，就如實結案為 NOT_READY 並將後續決策交回使用者；不可隱瞞風險或自行降低驗收標準。

禁止將私有 KA 原始碼、公司來源、模型、完整 logs、敏感環境資料或 Wheel 內部來源公開。不得修改正式 DB／Index／服務，不能啟動 E10。

**Main 現在直接執行這個固定驗收集合、整合 Sub 結果、交付一次終局回報；不得再建立新的測試或驗收批次。**

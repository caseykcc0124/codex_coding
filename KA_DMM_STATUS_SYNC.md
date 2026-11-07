# KA-DMM 開發狀態同步

> 公開去敏狀態；完整程式、資料與測試證據保留本地。局部 PASS 不代表正式切換。
> [Autonomous Mission v2.0](./docs/KA_DMM_Autonomous_End_to_End_DS_Replacement_Mission_v2.0.md) · [CURRENT WORK](./docs/KA_DMM_CURRENT_WORK.md)

## 最新狀態

| 欄位 | 值 |
|---|---|
| status_version | 1.0 |
| updated_at_utc | 2026-11-07T07:37:57+00:00 |
| updated_at_taipei | 2026-11-07T15:37:57+08:00 |
| instruction_version | v2.0 |
| chatgpt_monitor_state | ACTIVE_CURRENT_SESSION |
| instruction_commit | 5936429058e6bf9fecbfa35ae8be5cc92ba91218 |
| mission_state | ACTIVE |
| active_stage | E9_FINAL_VERIFICATION |
| current_work_item | E9 Final Closure：凍結 RC、實際本機 job 與發行包 |
| stage_gate | FULL_SUITE_22_PASS / RELEASE_GAPS_REMAIN |
| engineering_release_status | NOT_READY |
| production_status | NOT_AUTHORIZED |
| last_progress_at_utc | 2026-11-07T07:37:57+00:00 |
| next_action | 完成最終 commits／manifest／release gates 與 PDF 離線重建缺項 |
| requires_user_action | NO |
| user_action_summary | 沒有新的授權要求；正式切換仍未授權 |

## 階段進度

| 階段 | 狀態 | 實際證據與限制 |
|---|---|---|
| E0 | PASS_LOCAL | V0 T01–T10、8 integration、20 policy comparisons 通過；原 50 項結果保留 |
| E1 | PASS_SCOPED | DCLX 原生匯入 6 PASS；安全與來源反例保留 |
| E2 | PASS_SCOPED | 8 cases／7 formats 共用 bundle、fresh guarded reload、chunk／citation／tamper PASS；PDF 另用封存模型 |
| E3 | PASS_SCOPED | 19 source-fact assertions、8 converter/binding checks 及 exact facts／citation／ACL／stale／tamper PASS；無法綁定者保留 unresolved |
| E4 | PASS_SCOPED | 歷史不重解析遷移 17 項、既有 reparse 13 項 PASS；保留修訂／adoption／作者／時間，不偽造核准 |
| E5 | PASS_SCOPED | 真 API 與隔離 PostgreSQL PASS；外部 archive 已接共同 metadata background，保留衍生提示，不重解析 |
| E6 | PASS_SCOPED | UI 核准後真 native index drain，Serving 為同一修訂；embedding 合成，不宣稱 live RAG 品質 |
| E7 | PASS_UI_10_AND_CACHE_5 | Chrome 混批編輯／重載／匯出／核准／Serving PASS；45 頁實際拖曳與按需快取 PASS |
| E8 | PASS_ISOLATED_SCOPED | 候選版仍 quarantine；已有相容／降版／回退 probes，未宣稱正式升級 |
| E9 | RUNNING_NOT_READY | 第二輪 22 步 fresh-process 驗證全部 PASS；最終 commits／manifest／全部 gates 待完成 |
| E10 | NOT_AUTHORIZED | 正式服務、DB、Index、流量沒有切換 |

## 本次修正與證據

官方 DoclingDocument 是唯一共同內容母本。Markdown、Viewer、DTO、chunks 是投影；Office facts 與治理事件旁掛，沒有重建 DS 2.0。

圖片摘要與文字、表格共用一次 transaction／adoption／版本檢查。錯誤圖片 SHA／頁碼／ordinal、過期版本或第三次 adoption 故障均整批拒絕或回滾，獨立檢查通過。PictureItem 重複當空文字顯示的問題已修正，圖片依來源順序顯示一次。

Chrome 完整流程 10 項 PASS：文件／區塊視角、邊界、混批儲存、重載、同版本 chunk、HTML 匯出含圖表與摘要、UI 核准及 Serving 相同修訂。45 頁拖曳與快取 5 項 PASS：初始只取第一個 20 頁視窗，拖到第 25、45 頁才取後續視窗；共三次 unique 請求，返回不重取。

外部 ZIP／DCLX 現在從已綁定母本執行共同 metadata background，保留領域／衍生提示／提交者。ZIP 唯一完整 enhanced MD 的轉換與來源校驗共用選取規則，原 ZIP bytes／inventory 不變。新增 targeted 28 tests、external ASGI 6 checks PASS。

原始 50 項最新 **49 PASS／1 個既有 PPTX digest FAIL**；逐項與基準一致，Golden 檔案雜湊未變。此前新增七個失敗已修復且原證據保留，未放寬斷言製造全綠。此回歸使用既有 pytest 與明確原生套件路徑，不冒稱 clean-room。

真隔離 PostgreSQL 48 migrations／26 checks PASS；metadata abort／failed-state／retry 有反例。DS 正式依賴退休 18 項 PASS。原附件 MCP ZIP、CLI ZIP、MCP DCLX 分別驗 bytes／inventory／converter/source pin／SQL lineage。98 個原始 wheel 的 API clean runtime 路徑／版本／pip check PASS。

## 尚未完成

- 首輪完整 22 步為 17 PASS／5 FAIL，source/input 未變且無 skips，原結果保留。Serving verifier 的 lifecycle 預期應保留 `draft`，不是審核 `reviewed` 狀態；修正後三 transport 各 11 checks PASS。索引 fixture 的零面積 table span、SQLite adapter 與缺 backend 欄位修正後 7/7 PASS。PDF verifier 改用 guard 已建立的 Windows 事件迴圈，沒有放寬網路 guard；schema-valid metadata fixture 的真 PDF API 重驗 PASS。第二輪完整 22 步已全部 PASS，exit code 0，無必要 skips，source_changed=false、inputs_changed=false；22 份子 receipt 的 SHA256 與統一 receipt 一致。
- 封存 PDF 的 submit → Review → approval → index PASS，未弱化重載 Gate。84 個來源套件原盤點有 62 個 wheel；擴充本機搜尋補找到四個相容候選，仍缺 18 項。全離線 clean rebuild 未完成，未下載或重包。
- Windows 長圖片輸出路徑曾失敗，短路徑對照 PASS。限制与原 FAIL 保留，未宣稱不限路徑長度。
- 170 欄矩陣為 AUDIT_COMPLETE_WITH_GAPS，0 欄被宣稱逐欄 parity-certified。
- 真 corpus／live LLM 品質、實際 CI job、最終 feature commits／manifest／release gates 待完成。

## 授權與同步

E0–E9 工程持續已授權。正式切換與不可逆資料處置仍需另行授權；沒有公開公司程式、原文件、私人路徑、logs 或秘密。

產品 Gate 與同步分開判定。本次先以 Chrome 讀回既有公開檔並核對內容，再使用線上編輯更新；不使用 git 或檔案上傳，不以同步完成推論工程已可發布。

本次 E9 closure：原生功能與驗證工具已有兩個本地 commit。RC 原50重跑49 PASS／1相同已知PPTX FAIL，三次工具profile失敗證據保留。新增 headed Chrome完整流程10 PASS。CI wrapper已補獨立歷史50個test ID、failure signature與三Golden SHA核對，正向與替換失敗內容／test ID反例通過；尚未宣稱實際CI job或新RC完整22步通過。170欄責任補齊，其中19欄有具名斷言，151欄仍缺逐欄驗證，29項R1 BLOCKED未裁定。PDF84列缺項矩陣已完成，18缺wheel含15必要runtime依賴；沒有下載或偽造clean rebuild。


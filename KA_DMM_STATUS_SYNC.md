# KA-DMM 開發狀態同步

> 公開去敏摘要。完整程式與證據保留本地，局部 PASS 不代表正式切換。
> [Mission v2.0](./docs/KA_DMM_Autonomous_End_to_End_DS_Replacement_Mission_v2.0.md) · [CURRENT WORK](./docs/KA_DMM_CURRENT_WORK.md)

## 最新狀態

| 欄位 | 值 |
|---|---|
| status_version | 1.0 |
| updated_at_utc | 2026-11-07T08:22:41+00:00 |
| last_progress_at_utc | 2026-11-07T08:22:41+00:00 |
| instruction_version | v2.0 / E9 Final Closure |
| instruction_commit | 5936429058e6bf9fecbfa35ae8be5cc92ba91218 |
| mission_state | ACTIVE |
| active_stage | E9_FINAL_VERIFICATION |
| current_work_item | 最終 RC 已凍結；交付封裝與完整 Gate 判定 |
| stage_gate | ACTUAL_LOCAL_CI_22_PASS / RELEASE_BLOCKERS_REMAIN |
| engineering_release_status | NOT_READY |
| production_status | NOT_AUTHORIZED |
| release_commit | 54745fd733e52744c9b5728bcbbc91d337ecdbbc |
| next_action | 關閉欄位契約／驗證缺口、取得核准離線依賴與真實品質驗收條件 |
| requires_user_action | YES_FOR_EXTERNAL_RELEASE_INPUTS |
| user_action_summary | 解除完整發布需核准的離線套件來源及代表性品質驗收資料；內部欄位歸屬仍由工程處理，E10另行授權 |

## 階段判定

| 階段 | 狀態 | 實測範圍與限制 |
|---|---|---|
| E0 | PASS_LOCAL | 原基準與失敗證據保留；不宣稱全 regression 綠燈 |
| E1 | PASS_SCOPED | DCLX 原生匯入與安全反例 |
| E2 | PASS_SCOPED | 共同 bundle、官方 JSON 重載、資產／chunks／引用；PDF 使用獨立封存 profile |
| E3 | PASS_SCOPED | Office facts、精確來源、唯一綁定、ACL／stale／tamper；unresolved 拒絕猜測 |
| E4 | PASS_SCOPED | 隔離遷移／回退／崩潰恢復；完整唯一事件可重播，不代表所有 legacy 路徑 parity |
| E5 | PASS_SCOPED | 真 API、共同 metadata／審核流程；外部 MCP transport 為合成，不是 live converter 驗收 |
| E6 | PASS_SCOPED | 核准同版 Index／Serving、拒答與故障回退；embedding 合成，不代表 relevance 品質 |
| E7 | PASS_UI_SCOPED | Headed Chrome 10 項、45 頁按需快取 5 項；Original Viewer 判定見下文 |
| E8 | PASS_ISOLATED_SCOPED | 相容／降版／回退 probes；候選 reader 保持 quarantine |
| E9 | NOT_READY | 最終 RC 本機隔離 CI 22/22 PASS；發布阻擋仍保留 |
| E10 | NOT_AUTHORIZED | 正式服務、DB、Index、流量均未切換 |

## 本輪實際成果

官方 DoclingDocument 是唯一共同母本，Office facts／治理事件旁掛。MD、DTO、Viewer 和 chunks 是投影，新入口不重建 DS。

四個本地 commits 已落實產品遷移、驗證／CI／manifest工具、raw fixture 排除，以及四個必要 SQL migrations。固定 RC 後實際啟動本機隔離 CI job `local-fd8dae3e177c437e9a4c04cdce5598b3`：22 PASS、0 FAIL、0 required SKIP、exit 0，source／inputs 未變。Main 另核49項子收據與雜湊。這是實際本機 job，遠端 GitHub Actions 為 NOT_TESTED。

原50項在同RC另外重跑：49 PASS／1相同既有PPTX digest FAIL，50個 test ID／failure signature／三Golden hashes與原基準一致。未接受此失敗作為發布 waiver。回歸使用明列既有 pytest/site profile，不冒稱 clean-room。

Headed Chrome 10項涵蓋混批文字、表格、圖片摘要、保存／重載、同版chunk、含圖表HTML匯出、核准與Serving一致。45頁5項涵蓋實際拖曳、三個20頁視窗及返回快取。隔離PostgreSQL migrations／26 checks、自有server停止、DS退休18項與新業務路徑DS loaded0通過。

原始 DCLX Viewer 手動檢查曾在隔離站點出現 404，已確認是測試站點缺少資產掛載。只補隔離部署後，實際 Chrome 5 項通過：原件橋接 SHA 相等、同 origin 200、45 頁解析與第 1／45 頁呈現。此測試使用 headless Chrome 合成來源，不宣稱 OCR、schema 編輯或 Viewer 匯出已驗收。

實際 source RC ZIP 與含部署描述檔的交付 ZIP 已產生並解包核對。Main 與獨立覆核確認 904 個 source/test 檔案的 Git blob／SHA／ZIP bytes 一致，16 個描述檔 hash 相符，四個必要 migrations 完整，沒有不安全或重複路徑。包只包含程式、測試與部署元資料；執行仍需另外佈建核准的依賴與模型，不能當成已完成 PDF clean rebuild。

## 尚未關閉的發布條件

- 封存 PDF 真 parser 入庫到 Index／Serving已通過，但clean offline rebuild仍BLOCKED_EXTERNAL。84套件原profile有66原始wheel、18缺失，其中15為selected runtime必備，另3為原exact profile額外項。沒有下載、重包或捏造來源SHA。
- 170欄最終j1責任矩陣保留19具名bounded assertions、151未逐欄歸屬、29 R1 unresolved、0完整legacy parity認證；補31項限定證據候選，另120尚無此輪個別歸屬。這些不是151個已確認壞功能，也不能全轉成IT需求。
- 真實代表性corpus／live LLM／RAG relevance與groundedness、正式規模效能未測。合成embedding／fail-closed反例不能替代品質驗收。
- 原PPTX digest失敗仍未解除。Windows深圖片路徑原FAIL保留，短路徑控制PASS不代表無上限相容。
- 歷史任意revision/adoption映射未保證；無法唯一對應者只讀隔離，不偽造Verified Evidence。

## 交付與授權

完整逐Gate報告、RC checklist、有限Open Issues、離線套件缺項矩陣與canary／rollback程序保留本地。source包不包含原件、wheels、模型、資料庫或秘密，執行需依hash-pinned profile另行佈建。切換前先驗一致性備份可恢復，再canary／shadow index／CAS alias；錯引、ACL或事件丟失即停止擴大並保留增量事件。

沒有公開公司程式、原件、私人路徑、內部logs或憑證。本檔只透過國基Chrome線上編輯與Raw全文讀回同步，不使用git／push／檔案上傳。E10正式操作仍需另行核准。


# KA-DMM 開發狀態同步

> 公開去敏摘要。完整程式與證據保留本地，局部 PASS 不代表正式切換。
> [Mission v2.0](./docs/KA_DMM_Autonomous_End_to_End_DS_Replacement_Mission_v2.0.md) · [CURRENT WORK](./docs/KA_DMM_CURRENT_WORK.md)

## 最新狀態

| 欄位 | 值 |
|---|---|
| status_version | 1.0 |
| updated_at_utc | 2026-11-07T08:44:19+00:00 |
| last_progress_at_utc | 2026-11-07T08:44:19+00:00 |
| instruction_version | v2.0 / E9 Final Closure |
| instruction_commit | 5936429058e6bf9fecbfa35ae8be5cc92ba91218 |
| mission_state | ACTIVE |
| active_stage | E9_FINAL_VERIFICATION |
| current_work_item | 發布精確 wheel 交接 manifest；持續 PPTX 根因與 lineage 欄位驗證 |
| stage_gate | ACTUAL_LOCAL_CI_22_PASS / RELEASE_BLOCKERS_REMAIN |
| engineering_release_status | NOT_READY |
| production_status | NOT_AUTHORIZED |
| release_commit | 54745fd733e52744c9b5728bcbbc91d337ecdbbc |
| next_action | 外部先核18件精確PyPI版本與Windows tags／license／SHA；Main持續無依賴內部工作 |
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

## E9 PUBLIC WHEEL REQUEST

依 CURRENT_WORK commit `17865fba6779572088f637ed6e08445621ae399e` 與 wheel handoff commit `58856056533721762d2e6775c699b48b9eeab15e` 執行。以下只公開開源 distribution 身份、保存的精確版本與相容 tags；沒有內部路徑、index、憑證或文件。18個專案身份已有本地metadata證據，但18個精確版本是否公開發布仍未核實。此清單是外部核實及取得請求，不表示已下載、已取得授權或已完成offline rebuild。

```json
{
  "wheel_request_version": 1,
  "release_commit": "54745fd733e52744c9b5728bcbbc91d337ecdbbc",
  "wheel_request_state": "READY_FOR_EXTERNAL_PUBLIC_SOURCE_VERIFICATION",
  "target_python": "CPython 3.12",
  "target_platform": "win_amd64",
  "target_abi": "per-wheel: cp312, abi3, or none; see filename_or_tags",
  "missing_count": 18,
  "required_runtime_count": 15,
  "exact_profile_extra_count": 3,
  "verified_public_exact_version_count": 0,
  "private_or_unpublished_count": "UNKNOWN",
  "offline_wheel_gate": "BLOCKED_EXTERNAL",
  "public_wheels": [
    {
      "name": "accelerate",
      "version": "1.15.0",
      "filename_or_tags": [
        "py3-none-any"
      ],
      "category": "RUNTIME_REQUIRED",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "docling-ibm-models",
      "version": "4.0.3",
      "filename_or_tags": [
        "py3-none-any"
      ],
      "category": "RUNTIME_REQUIRED",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "docling-parse",
      "version": "7.22.2",
      "filename_or_tags": [
        "cp312-cp312-win_amd64"
      ],
      "category": "RUNTIME_REQUIRED",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "filelock",
      "version": "4.1.1",
      "filename_or_tags": [
        "py3-none-any"
      ],
      "category": "RUNTIME_REQUIRED",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "hf-xet",
      "version": "1.7.0",
      "filename_or_tags": [
        "cp38-abi3-win_amd64"
      ],
      "category": "RUNTIME_REQUIRED",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "huggingface-hub",
      "version": "1.33.0",
      "filename_or_tags": [
        "py3-none-any"
      ],
      "category": "RUNTIME_REQUIRED",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "markupsafe",
      "version": "3.0.4",
      "filename_or_tags": [
        "cp312-cp312-win_amd64"
      ],
      "category": "RUNTIME_REQUIRED",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "mpmath",
      "version": "1.3.0",
      "filename_or_tags": [
        "py3-none-any"
      ],
      "category": "RUNTIME_REQUIRED",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "pandas",
      "version": "3.0.6",
      "filename_or_tags": [
        "cp312-cp312-win_amd64"
      ],
      "category": "RUNTIME_REQUIRED",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "pip",
      "version": "23.2.1",
      "filename_or_tags": [
        "py3-none-any"
      ],
      "category": "EXACT_PROFILE_EXTRA",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "pypdf",
      "version": "6.20.0",
      "filename_or_tags": [
        "py3-none-any"
      ],
      "category": "EXACT_PROFILE_EXTRA",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "setuptools",
      "version": "84.0.0",
      "filename_or_tags": [
        "py3-none-any"
      ],
      "category": "RUNTIME_REQUIRED",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "soupsieve",
      "version": "3.0.2",
      "filename_or_tags": [
        "py3-none-any"
      ],
      "category": "EXACT_PROFILE_EXTRA",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "sympy",
      "version": "1.14.0",
      "filename_or_tags": [
        "py3-none-any"
      ],
      "category": "RUNTIME_REQUIRED",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "torch",
      "version": "2.14.1",
      "filename_or_tags": [
        "cp312-cp312-win_amd64"
      ],
      "category": "RUNTIME_REQUIRED",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "torchvision",
      "version": "0.29.1",
      "filename_or_tags": [
        "cp312-cp312-win_amd64"
      ],
      "category": "RUNTIME_REQUIRED",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "transformers",
      "version": "5.19.0",
      "filename_or_tags": [
        "py3-none-any"
      ],
      "category": "RUNTIME_REQUIRED",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    },
    {
      "name": "tzdata",
      "version": "2026.5",
      "filename_or_tags": [
        "py3-none-any"
      ],
      "category": "RUNTIME_REQUIRED",
      "expected_sha256": "UNKNOWN",
      "source": "Official PyPI; exact release must be verified",
      "redistributable": "UNKNOWN",
      "exact_version_publication": "UNKNOWN",
      "blocking_reason": "No original compatible wheel in the completed authorized local inventory; public exact-version availability and original wheel hash are not yet verified"
    }
  ]
}
```

沒有原始 wheel filename 或已驗 SHA，所以保留 UNKNOWN；不能用 RECORD hash 代替 wheel hash。`hf-xet` 的 `cp38-abi3-win_amd64` 可供 CPython3.12；`py3-none-any` 是純Python wheel，不能一律改成cp312。協作端先核官方PyPI精確版本、Requires-Python、tags、license與實際SHA；若精確版本不存在，明確回報，禁止替版。GitHub一般Repo不作未審查大型二進位庫，實際交付另核准傳輸通道。只有收到原始wheels並完成全新offline install及PDF既定Gate，才能解除BLOCKED_EXTERNAL。私有metadata來源證據只留本地。

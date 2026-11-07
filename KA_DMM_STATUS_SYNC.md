# KA-DMM 開發狀態同步

> 公開去敏摘要。完整程式與證據保留本地，局部 PASS 不代表正式切換。
> [Mission v2.0](./docs/KA_DMM_Autonomous_End_to_End_DS_Replacement_Mission_v2.0.md) · [CURRENT WORK](./docs/KA_DMM_CURRENT_WORK.md)

## 最新狀態

| 欄位 | 值 |
|---|---|
| status_version | 1.0 |
| updated_at_utc | 2026-11-07T09:38:53.894Z |
| last_progress_at_utc | 2026-11-07T09:38:53.894Z |
| instruction_version | v2.0 / E9 Final Closure |
| instruction_commit | 5936429058e6bf9fecbfa35ae8be5cc92ba91218 |
| mission_state | ACTIVE |
| active_stage | E9_FINAL_VERIFICATION |
| current_work_item | 18件官方wheel取得及84套件offline install通過；真PDF入庫到Serving限定驗證PASS |
| stage_gate | ACTUAL_LOCAL_CI_22_PASS / RELEASE_BLOCKERS_REMAIN |
| engineering_release_status | NOT_READY |
| production_status | NOT_AUTHORIZED |
| release_commit | 54745fd733e52744c9b5728bcbbc91d337ecdbbc |
| next_action | 維持RC凍結；收斂PPTX版本契約、欄位歸屬與代表性RAG品質等剩餘Gate |
| requires_user_action | YES_FOR_EXTERNAL_RELEASE_INPUTS |
| user_action_summary | 套件下載不需使用者代辦；代表性品質驗收資料與E10授權仍另處理 |

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

- 封存PDF既有真parser流程已通過。18件缺失的精確wheel現已從官方PyPI取得並驗SHA256、METADATA、Requires-Python與tags；全新84套件offline install與pip check均exit0，user site disabled；真PDF解析、Review、核准、Index與Serving限定驗證PASS。metadata/embedding使用合成資料，不宣live RAG品質。
- 170欄最終j1責任矩陣保留19具名bounded assertions、151未逐欄歸屬、29 R1 unresolved、0完整legacy parity認證；補31項限定證據候選，另120尚無此輪個別歸屬。這些不是151個已確認壞功能，也不能全轉成IT需求。
- 真實代表性corpus／live LLM／RAG relevance與groundedness、正式規模效能未測。合成embedding／fail-closed反例不能替代品質驗收。
- 原PPTX digest失敗仍未解除。Windows深圖片路徑原FAIL保留，短路徑控制PASS不代表無上限相容。
- 歷史任意revision/adoption映射未保證；無法唯一對應者只讀隔離，不偽造Verified Evidence。

## 交付與授權

完整逐Gate報告、RC checklist、有限Open Issues、離線套件缺項矩陣與canary／rollback程序保留本地。source包不包含原件、wheels、模型、資料庫或秘密，執行需依hash-pinned profile另行佈建。切換前先驗一致性備份可恢復，再canary／shadow index／CAS alias；錯引、ACL或事件丟失即停止擴大並保留增量事件。

沒有公開公司程式、原件、私人路徑、內部logs或憑證。本檔只透過國基Chrome線上編輯與Raw全文讀回同步，不使用git／push／檔案上傳。E10正式操作仍需另行核准。

## E9 官方wheel取得結果

使用者已授權Main直接下載。18個精確版本均由官方pypi.org release metadata與files.pythonhosted.org取得，未替版、未重包site-packages。全部實際wheel SHA256重核一致，名稱、版本、頂層METADATA/WHEEL、Requires-Python與指定tags驗證通過。共175448802 bytes，其中15件runtime必備、3件exact profile額外。license宣告已記錄，license宣告的記錄不等於整包再散布核准；PDF重建的追加實測如下。

```json
{
  "wheel_request_state": "18_OFFICIAL_WHEELS_VERIFIED",
  "target_python": "CPython 3.12",
  "target_platform": "win_amd64",
  "verified_public_exact_version_count": 18,
  "missing_count": 0,
  "offline_install_gate": "PASS_OFFLINE_CLEAN_INSTALL_84",
  "public_wheels": [
    {
      "name": "accelerate",
      "version": "1.15.0",
      "sha256": "97eacca0b73e45cb867dbf8c5d5d4dc32219544300e0c8992c7334dc2ef33cec",
      "filename": "accelerate-1.15.0-py3-none-any.whl",
      "wheel_tags": [
        "py3-none-any"
      ]
    },
    {
      "name": "docling-ibm-models",
      "version": "4.0.3",
      "sha256": "82c6c6ad6622aa9e58c4d745c26fba12eef54927f32d44f21f24bcb5be5464ff",
      "filename": "docling_ibm_models-4.0.3-py3-none-any.whl",
      "wheel_tags": [
        "py3-none-any"
      ]
    },
    {
      "name": "docling-parse",
      "version": "7.22.2",
      "sha256": "04a38e69c05167c4f1aa8429c051b81c868f019d4a28c81d220f5018ce98d250",
      "filename": "docling_parse-7.22.2-cp312-cp312-win_amd64.whl",
      "wheel_tags": [
        "cp312-cp312-win_amd64"
      ]
    },
    {
      "name": "filelock",
      "version": "4.1.1",
      "sha256": "3f4a557945a7b0f95efeb1f432267affe5d45ac8ddde2aed1b97ebb62382c089",
      "filename": "filelock-4.1.1-py3-none-any.whl",
      "wheel_tags": [
        "py3-none-any"
      ]
    },
    {
      "name": "hf-xet",
      "version": "1.7.0",
      "sha256": "2b7bb5727889b0f2436dbaaad8fc4c3e66b8240d992716989e0c086b4278b1bc",
      "filename": "hf_xet-1.7.0-cp38-abi3-win_amd64.whl",
      "wheel_tags": [
        "cp38-abi3-win_amd64"
      ]
    },
    {
      "name": "huggingface-hub",
      "version": "1.33.0",
      "sha256": "04e434b06e100eddbce9a6e817d72693a7884b10a79bd67ab48080d5c07eb899",
      "filename": "huggingface_hub-1.33.0-py3-none-any.whl",
      "wheel_tags": [
        "py3-none-any"
      ]
    },
    {
      "name": "markupsafe",
      "version": "3.0.4",
      "sha256": "11935df9bf455ed0c04eb87bcd720f02b1fe5e02128a9430f23aed6f93336fc7",
      "filename": "markupsafe-3.0.4-cp312-cp312-win_amd64.whl",
      "wheel_tags": [
        "cp312-cp312-win_amd64"
      ]
    },
    {
      "name": "mpmath",
      "version": "1.3.0",
      "sha256": "a0b2b9fe80bbcd81a6647ff13108738cfb482d481d826cc0e02f5b35e5c88d2c",
      "filename": "mpmath-1.3.0-py3-none-any.whl",
      "wheel_tags": [
        "py3-none-any"
      ]
    },
    {
      "name": "pandas",
      "version": "3.0.6",
      "sha256": "3ef908d28590b3f42d7070e7ad8f9b34b442b260b7f3c1afb57e0040c58cdb1b",
      "filename": "pandas-3.0.6-cp312-cp312-win_amd64.whl",
      "wheel_tags": [
        "cp312-cp312-win_amd64"
      ]
    },
    {
      "name": "pip",
      "version": "23.2.1",
      "sha256": "7ccf472345f20d35bdc9d1841ff5f313260c2c33fe417f48c30ac46cccabf5be",
      "filename": "pip-23.2.1-py3-none-any.whl",
      "wheel_tags": [
        "py3-none-any"
      ]
    },
    {
      "name": "pypdf",
      "version": "6.20.0",
      "sha256": "f003fc2014814d264fe7dd3f9d435c158e23e1a85a2233f87a0a2d6d21c914ad",
      "filename": "pypdf-6.20.0-py3-none-any.whl",
      "wheel_tags": [
        "py3-none-any"
      ]
    },
    {
      "name": "setuptools",
      "version": "84.0.0",
      "sha256": "51a52592b3b99e102b609654876bd65f19f999935166d1352678931132b0c670",
      "filename": "setuptools-84.0.0-py3-none-any.whl",
      "wheel_tags": [
        "py3-none-any"
      ]
    },
    {
      "name": "soupsieve",
      "version": "3.0.2",
      "sha256": "9f2c709e4bfbb3f520289e81a4e14808bf0b3259c7f6c3b9efab30058be0607e",
      "filename": "soupsieve-3.0.2-py3-none-any.whl",
      "wheel_tags": [
        "py3-none-any"
      ]
    },
    {
      "name": "sympy",
      "version": "1.14.0",
      "sha256": "e091cc3e99d2141a0ba2847328f5479b05d94a6635cb96148ccb3f34671bd8f5",
      "filename": "sympy-1.14.0-py3-none-any.whl",
      "wheel_tags": [
        "py3-none-any"
      ]
    },
    {
      "name": "torch",
      "version": "2.14.1",
      "sha256": "38bee9f2a2ccfc6898172a5075e4ba52522fbe143eeb099674fc67ab390e858d",
      "filename": "torch-2.14.1-cp312-cp312-win_amd64.whl",
      "wheel_tags": [
        "cp312-cp312-win_amd64"
      ]
    },
    {
      "name": "torchvision",
      "version": "0.29.1",
      "sha256": "551c567fd39581570bf553c8df58895d567258b9997760179719f205ec5cd859",
      "filename": "torchvision-0.29.1-cp312-cp312-win_amd64.whl",
      "wheel_tags": [
        "cp312-cp312-win_amd64"
      ]
    },
    {
      "name": "transformers",
      "version": "5.19.0",
      "sha256": "afcd2dd5f603ed28c1e1fcb00a338ccbb4ef5f878ed289635df8b58187afb518",
      "filename": "transformers-5.19.0-py3-none-any.whl",
      "wheel_tags": [
        "py3-none-any"
      ]
    },
    {
      "name": "tzdata",
      "version": "2026.5",
      "sha256": "b683bd1b6659ddcd810ff02ad09ba821d4bf1065072805063eb35c49617905ac",
      "filename": "tzdata-2026.5-py2.py3-none-any.whl",
      "wheel_tags": [
        "py2-none-any",
        "py3-none-any"
      ]
    }
  ]
}
```

原封存RC、部署profile與ZIP保持不變。新wheelhouse與驗證收據獨立保存；不把取得套件直接當成ENGINEERING_COMPLETE，也未啟動E10。

## 本輪無依賴工作追加結果

PPTX digest 已在固定來源上重現，parser／planner身份版本與recipe是主要差異；兩次限定執行的單一legacy entry內容一致。舊expected digest的完整生成輸入未保存，所以不能宣稱Golden原錯、不能以換hash或回退真實planner身份製造PASS。原50項的已知FAIL與未批准waiver保持原狀，需找回完整舊輸入或由既定Gate批准版本契約遷移；此結論不代表所有PPTX/RAG品質已測。

10個parser lineage欄位補上owner／consumer與實證歸屬，另實跑1正向control、5個parser/package/recipe/weights篡改反例，現有pinned recipe/package與bound prepared manifest路徑拒絕變更。完整自洽重封存資料可通過raw bundle結構／checksum驗證，原bound manifest digest則拒絕它；不把這項當獨立核准模型政策通過。模型內容讀取、網路與DS均為0，RC/profile/原j1證據未變，170parity仍未完成。

Main已讀實際receipt／exit code並核對RC未變。上述只是追加限定證據，不重封原RC、不改Golden、不更新已pin部署profile，也不啟動E10。上方18件官方取得實證取代先前外部代辦假設；offline重建結果另行驗收。

## 官方套件離線重建驗收

全新Windows CPython3.12隔離venv安裝84件hash-locked原始wheel，pip使用no-index與require-hashes。建立、安裝、pip check與身份核對四個程序均exit0；84件installed identity吻合、user site disabled、所有site-packages位於新venv。

新PDF環境完成一次真parser、Review、核准與Index流程，產生3個chunks與1張頁面圖片。Serving真ASGI路由核對未登入拒絕、raw／map同有效revision、圖片讀取與錯誤hash拒絕，共4項檢查PASS。API使用既有clean98環境，PDF subprocess使用新clean84環境；資料庫為隔離SQLite語法adapter、metadata與embedding合成。這解除原18wheel取得與這項clean PDF重建卡點，不代表整體170parity、live RAG品質、正式PostgreSQL或E10已通過。RC/profile/舊ZIP未改。

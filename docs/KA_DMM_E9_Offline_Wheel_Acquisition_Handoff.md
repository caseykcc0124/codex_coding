# KA-DMM E9 離線 Wheel 取得與交接：供 Coding Agent Main 執行

> 上位規格：[Autonomous Mission v2.0](./KA_DMM_Autonomous_End_to_End_DS_Replacement_Mission_v2.0.md) 及 [E9 Final Closure](./KA_DMM_E9_Final_Closure_Execution_Guide.md)。本文件為缺套件的**具體協作指令**，不取代既有授權、驗收與資料保護規則。
>
> 使用者要求：如果 Coding Agent 不能直接取得所需依賴，改由 ChatGPT 協助從**授權的公開來源**下載、校驗並交付 Wheel；GitHub 是指令及去敏同步管道。此要求**不授權 Coding Agent 自行繞過網路限制、不授權上傳公司資料或私有套件到公開 GitHub，也不授權 E10 Production Cutover**。

## 1. 立即行動：先取得準確缺件清單

目前已知：來源 profile 84 套件，已取得原始 wheel 66 件，仍缺 18 件，其中 15 件為 selected runtime 必需，3 件是原 exact profile 其他項。單靠數量**無法準確下載或重建**。

Main 立即從已保存的本地 release manifest／lock／offline wheel matrix 擷取下列資訊，**不得重新猜版本或拿另一個環境的套件充數**：

| 欄位 | 要求 |
|---|---|
| package | PyPI canonical distribution name |
| version | 必須與 RC lock 精確一致 |
| filename | 預期的 wheel filename，或精確可接受的 wheel tag |
| criticality | RUNTIME_REQUIRED（15 件）或 EXACT_PROFILE_EXTRA（3 件） |
| python | 目標 Python major/minor、implementation 與 ABI tag，如 cp311 |
| platform | 實際 Windows architecture / supported platform tags，如 win_amd64 |
| origin | 官方 PyPI、核准的 package index，或已存本地；不得包含私有連結 |
| expected_sha256 | 若 lock 已有真正 hash 則提供；沒有就寫 UNKNOWN，不得捏造 |
| redistributable | 已檢查公開分發許可或 UNKNOWN |
| blocking_reason | 本地無檔、無網路、官方無相容 wheel、衝突或其他具體原因 |

如無法在不暴露公司敏感資訊的前提下披露完整 lock，**僅列出公開開源 PyPI 套件及目標 platform/ABI、非敏感 hash**。私有套件、受限版本、內部 index URL、憑證、路徑、公司環境資訊、公司來源文件絕對不可放進公開 Repository；這些只能留在本地，必要時標示 PRIVATE_TRANSFER_REQUIRED。

## 2. GitHub 去敏回報格式

仍只使用原本根目錄 [KA_DMM_STATUS_SYNC.md](../KA_DMM_STATUS_SYNC.md)，不新增平行進度檔。Main 在同步檔最後附加「E9 PUBLIC WHEEL REQUEST」區段，建議使用以下簡明結構，**只放經確認可公開的項目**：

```yaml
wheel_request_version: 1
release_commit: "<local RC SHA>"
wheel_request_state: READY_FOR_EXTERNAL_FETCH  # or PRIVATE_TRANSFER_REQUIRED / WAITING_FOR_MANIFEST
target_python: "cp3xx"
target_platform: "win_amd64"
target_abi: "cp3xx"
missing_count: 18
required_runtime_count: 15
exact_profile_extra_count: 3
public_wheels:
  - name: "<PyPI name>"
    version: "<exact locked version>"
    filename_or_tags: "<exact wheel filename or tags>"
    category: "RUNTIME_REQUIRED"
    expected_sha256: "UNKNOWN"
    source: "PyPI"
private_or_unpublished_count: 0
offline_wheel_gate: BLOCKED_EXTERNAL
```

主狀態欄位（updated_at_utc、mission_state、stage_gate、next_action、requires_user_action）也要如實更新，勿破壞既有 E0～E10 分段。

如果 18 個皆是公開 PyPI 項目且允許揭露，請一次列完整 18 件；若有受限資訊，只公布可公開部分，並明確計數缺口。不要只是再次回報「缺 18 件」；那無法完成交付。

## 3. ChatGPT 端協作取得及封裝準則

Main 公開清單後，外部協作端才可按**列出的精確版本與 tags**查官方 PyPI 發行檔並驗 SHA256、Requires-Python、Wheel Tag 與許可，再形成可重現取得清單及離線 wheelhouse。不得把 Linux/macOS wheel 當作 Windows 可用，或用未鎖定版本代換原 RC。

若取得的檔案適合公開再散布，優先使用可用的受控 Binary Artifact／GitHub Releases 配送，而非把 Wheel 推進 `main` 的 Git history；需核對服務限制、授權與實際可用的上傳能力。若目前連接工具無法上傳 Releases binary asset，**不得宣稱已上傳**。先交付來源 URL／實際 SHA256／本地安裝清單；待可用且獲允許的二進位傳輸管道後再配送。官方 PyPI 直接來源及 hash 可以作為追溯證據，但在 Coding Agent 無網路時**連結本身不等於 Wheel 已交付**。

任何未驗證檔案及依賴都不可置入正式環境。未經授權禁止透過私人 CDN、未核准網路代理或其他方式迴避網路政策。

## 4. 收到 Wheel 的 Main 驗收

在已授權的本地隔離環境將收到的 wheel 與原本 66 個 wheel 合併，對照 lock／manifest 逐檔驗 sha256、platform／ABI／metadata／Requires-Python、相依封閉性與 License，確認 84 件 exact profile（或精確列明非必要 extras 的分界）。

使用 `--no-index --find-links` 的 offline install 流程，必要時配合 `--require-hashes` 對照經驗證的 hash，確保測試時不會暗中連網。在全新 clean environment 執行 PDF 真 parser → canonical bundle → Review → approval → Index → Serving 的完整既定 Gate，另驗 DS guard、資產重新載入與引用完整性；留下來源檔 hash、安裝日誌、exit code、測試 receipt。

成功之前，`offline_wheel_gate=BLOCKED_EXTERNAL/NOT_TESTED` 不能改成 PASS。

## 5. Main 不中斷其他 E9 工作

套件尚未交付期間，繼續完成：
* 170 欄必要產品 consumer／欄位歸屬及證據映射；
* PPTX digest 基準差異之受限根因修復或符合既定 Gate 的處理，保留原 FAIL；
* 歷史 revision/adoption 必需語意、長圖片路徑限制及 rollback 驗證；
* 真實品質驗收所需資料與判準之**去敏規格**，但不得公開代表性公司 corpus。

E9 仍維持 `NOT_READY`，E10 仍為 `NOT_AUTHORIZED`。如包及驗收證據齊全，才依 Mission v2.0 宣告工程 Gate 成立。

**立即在固定狀態檔留下可公開的精確套件 manifest，Main 依此清單繼續自治；不等待使用者逐項回覆。**

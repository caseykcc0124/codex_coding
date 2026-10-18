# Codex Native Autonomy V2.1

以原生 Codex Main Agent 與 Luna Sub-Agent 組成的輕量 Always-on Agent POC。重點是事件輪詢、有限派工、工作證據、WAIT 與恢復，不引入額外後端、UI 或第三方代理框架。

## 取得與安裝

1. 複製這個公開範本儲存庫：`git clone https://github.com/caseykcc0124/codex_coding.git`。
2. 閱讀 [INSTALL_PROMPT.md](./INSTALL_PROMPT.md)，在**公司核准的 Codex 環境**中將安裝指令交給 Agent。
3. 安裝 Agent 必須先檢查全域與專案 `AGENTS.md`，只合併 POC 所需的專案層設定，不覆寫公司既有資源與認證。
4. 在測試工作區完成 WAIT、單一事件派工與再次喚醒去重的三次手動測試；通過後才考慮原生排程。

## 模型配置

Main 預期 `gpt-6.1-sol`、low；Worker 預期 `gpt-6-luna`、low；最多 2 個原生子代理。實際可用性取決於 Codex 版本、公司模型路由與政策，尚未在公司環境驗證。

## 公開與私有資料界線

此公開儲存庫僅保留**一般化 POC 設定範本**，沒有公司內部 AGENTS.md、MCP 位址、認證資料、郵件、Teams 或工作產物。實際運行時的 `.autonomy/work/` 與 `.autonomy/inbox/` 應留在受控工作區，避免推送公開 GitHub。

## 限制

範本中 AGENTS.md 的停止、去重與成本規則只是模型應遵循的軟規則，不構成 Token 的硬預算控制。排程功能依安裝時的 Codex 客戶端能力而定，不應假設已存在。

此儲存庫提供可檢視與複製的來源檔案。另有 ZIP 安裝包在原始對話中提供下載，但**目前未將 ZIP 二進位檔提交至 GitHub**。

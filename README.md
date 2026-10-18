# Codex Native Autonomy V2.1

原生 Codex Main／Sub-Agent 的極小自主代理 POC，供研究事件輪詢、有限派工、驗收、WAIT 與恢復使用。此公開儲存庫只有一般化範本，沒有公司內部 AGENTS.md、MCP 連線資訊、帳號認證或工作資料。

## 下載與安裝

1. 下載 [完整安裝包](./codex-native-v2.1-poc.zip)，其中包含 13 個檔案（含安裝 Prompt）。
2. 開啟 [安裝 Prompt](./INSTALL_PROMPT.md)，將「交給 Codex 的指令」貼到**公司核准的 Codex 工作環境**。
3. 先在專案中做只讀預檢，合併既有專案規則，確認公司全域設定完全不受更動。
4. 先測試 WAIT、有新事件時單一 Worker 派工、同一事件去重。確認後再由人類決定是否使用原生排程。

**模型預期**：Main `gpt-6.1-sol`／low，Worker `gpt-6-luna`／low。能否使用取決於公司實際模型路由與授權，設定檔不等於已成功生效。

**操作界線**：安裝包僅含 POC 範本。請勿把公司程式碼、會議、郵件、金鑰、內網 URL 或實際執行時的 `.autonomy/` 工作狀態推送到公開 GitHub。安裝時不啟用無限 Goal，也不自動執行寄信、Teams 傳送、部署或 git push。

## 封存檔完整性

SHA-256：`26d9aca2f628ccf133a09924dd048c951f3f484c7b1075c6c11b52386dd7388c`

本 POC 尚未在使用者公司的 Codex／MCP 環境實際執行驗證。

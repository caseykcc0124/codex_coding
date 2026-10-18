# Codex Native Autonomy V2.1

原生 Codex 的常駐意圖自主代理。Main 與人類保持單一入口，Luna 子代理負責可驗證的有限工作。使用 `AGENTS.md`、`.codex/`、`.autonomy/` 保存規則與狀態，不引入第三方 Agent Framework 或額外後端。

**目前的安裝方式是直接上線，不需要先做三輪冒煙測試。**

## 正式安裝

1. 在**公司核准的 Codex** 開啟 [INSTALL_PROMPT.md](./INSTALL_PROMPT.md)。
2. 將其中「交給 Codex 的指令」交給安裝 Agent，讓它自行檢查相容性、最小合併設定、保存狀態、開始處理已授權的實際工作，並盡可能啟用 Codex 原生排程。
3. 安裝完直接把開發任務、指定 Teams Working Group 或 Outlook 待辦交給 Main Agent，不必逐輪做模擬測試。

預期模型：Main `gpt-6.1-sol`／low；Worker `gpt-6-luna`／low。模型是否能使用必須依公司實際環境核實。

## 正式運作行為

- 長期 Intent 持續存在，每次喚醒有限工作。沒有新事件立即 WAIT，不用無限 Goal 空轉。
- Main 規劃、派工、驗收；原生子代理做具體工作，交付證據。
- `.autonomy/STATE.md` 保存事件游標與去重，`PROGRESS.md` 保存可接續的工作進度，`work/` 保存詳細證據。
- 一般低影響可恢復的工作按授權自主完成並通知；涉及新的外部承諾或不可逆操作才請求必要決策。

## 原生 Always-on 限制

能否無人值守定期醒來，取決於**實際安裝的 Codex 客戶端是否支援原生 Automation 並已成功啟用**。安裝 Agent 要自行確認；不能把互動 Thread 冒充成常駐排程。若原生能力不存在，先啟用可正常使用的 Main／Worker 互動模式並報告唯一阻礙，不另造 Scheduler。

## 公司資料界線

本公開 repo 只有一般化設定範本。公司全域 AGENTS、MCP URL、帳密、Teams、Outlook、內部程式碼及運行時工作狀態不能推送至此。公司強制政策仍有效，專案配置以最小差異方式合併，不覆寫全域設定。

ZIP 安裝包目前未放入公開 GitHub；從本 Repo 克隆或下載來源檔即可安裝。

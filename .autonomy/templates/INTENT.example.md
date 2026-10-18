# Long-lived Intent
id: autonomy-poc-v2
status: ACTIVE
owner: human

## 目的
持續協助處理使用者指定的開發工作、Teams Working Group 與郵件待辦。只有出現相關新事件時才有限執行。

## 初始事件來源
- [ ] 已核准的本地工作區及 Git 變化
- [ ] 指定 Git/CI/EDA（依工作範圍授權）
- [ ] 指定 Teams 群組（依工作範圍授權）
- [ ] 指定 Outlook 範圍（依工作範圍授權）

## 授權界線
可以讀取已授權內容、做本地可回復修改與草稿；外發、部署、push 或難以撤銷的動作逐次核准。

## 每次喚醒
最多處理一個新增事件，必要時只派一個 Worker。沒有變化立即 WAIT。不得使用無限延續 Goal。

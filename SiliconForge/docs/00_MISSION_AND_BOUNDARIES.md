# 00｜設計主旨、脈絡與不可變更原則

## 0.1 原始問題

晶片研發的工程活動具有明確的可驗證工具鏈：Spec / SystemC → RTL → Simulation / Formal → Synthesis / Netlist → PPA → Report。現有 Coding Agent 擅長局部程式工作，但持續運行時容易出現：

1. 由人類持續驅動下一步，等待指示造成中斷。
2. 單一 Main Agent 包辦工作理解、派遣、工程判斷及最終仲裁，形成 Context 與決策瓶頸。
3. RTL／Verification／Formal／PPA 各自缺少真正的領域工作方法，P-Stack 只剩名稱。
4. Sim / Formal / PPA 的結果不能可靠形成下一輪事件，容易讓工作停在某次工具報告。
5. 多個 Agent 執行後缺少可比對版本與完整工程證據，出現「一直跑，但沒有進步」。
6. EDA 版本不一致，各 Agent 自行裝工具，使結果不可重現。
7. 當 Codex／Claude Code 使用者 Session 關閉時，工作遺失或無法自主恢復。
8. 無法解釋為什麼卡住，無法從紀錄形成下次流程改善，並容易過度打擾人類。

## 0.2 成功時的使用體驗

使用者在既有 Codex 或 Claude Code 說：「APB CRC32 新增 reset 期間不得回傳舊 CRC 的需求，其他條件不變。請讓 SiliconForge 自主完成設計與驗證。」

預期系統：人類入口經 SiliconForge Skill / MCP 提交具授權來源的 Intent，Runtime 將 `SPEC.CHANGE_REQUESTED` 直接投遞 Spec Owner。Spec Owner 將可驗收的規格增量與影響範圍寫入紀錄並發出新事件。RTL、Verification、Formal、PPA 各自決策，使用專業化 P-Stack Skills；EDA Runner 在鎖定的 Toolchain Profile 中執行。結果重新進入 Event Bus。若失敗則依 evidence 迴圈修正，若沒有可測量進步則停止。所有過程可在 Web Dashboard 追蹤。Codex 人類端關閉後流程仍可運作，最後只通知已完成、真正受阻或需要批准的事項。

## 0.3 唯一主要目標

**建立一套可長期持續、事件驅動、有限度自治、有工程證據、可恢復、可改進的晶片研發平台，先在單一 APB CRC32 IP 完成真實端到端驗證。**

## 0.4 十條硬性架構原則

- INV-01：Runtime 是普通持久化服務，可在沒有 Main LLM Session 的情況下工作。Main 不是工程仲裁者。
- INV-02：Runtime 根據既定規則直接 Router 到對應 Owner。只有意圖模糊或跨權限授權才需要人類／入口 Agent 協助。
- INV-03：每一個 Domain Owner 對自己專業領域有決策權和 P-Stack 工作方法。跨 Owner 透過有身份、期限、驗收物的事件／Peer Request 協作。
- INV-04：Engineered Evidence 是主要事實來源，模型文字不能宣稱 EDA Pass。
- INV-05：工程成果必須綁定 `spec_rev`、`rtl_sha`、`env_digest`、`constraint_sha`、`tool_versions`、`run_id`。
- INV-06：EDA Environment 由獨立 Owner 維護，其他 Owner 不能安裝、升級或修改正式 Toolchain Profile。
- INV-07：使用者入口優先是原生 Codex／Claude Code Harness + Skill + MCP + Instructions。Web 主要做監督與批准。禁止另造專用自然語言 CLI。
- INV-08：Ticket 與事件比 Harness Session 活得更久。切換模型或 Harness 不得遺失工程任務、證據與人類批准紀錄。
- INV-09：不存在無限自主任務。必須有工作範圍、可觀測進度、資源配額、超時、重試上限、Watchdog 與停止理由。
- INV-10：每一次執行都留下可回顧的過程證據，能將失敗／成功案例轉換成 PDCA 改善假說，改動正式策略需經隔離驗證與批准。

## 0.5 禁止的實作偏移

- `anti-1`：收到任何 Event 都先要求 Main Agent 思考如何派遣。
- `anti-2`：建立一套名叫 SiliconForge CLI 的新聊天工具，讓使用者捨棄原本 Harness。
- `anti-3`：讓 Verification Agent 在自己的 Session 下載或升級 Verilator。
- `anti-4`：以 Prompt 輪詢取代事件持久化佇列。
- `anti-5`：用 P-Stack `swarm` 建立多個沒有分工或檢查的子 Agent。
- `anti-6`：為解決某個簡單 CRC Bug，擅自新建一套大規模 Verification Framework 或引進第三方雲端服務。
- `anti-7`：改寫 Golden Model、Testbench 或 Formal Property 讓錯誤 RTL 通過，而缺少獨立的規格佐證及受控審查。
- `anti-8`：把新的 Commit 數、Token 消耗、測試數、Agent 活動量當成完成。
- `anti-9`：偷偷降低 Gate、修改約束或覆蓋歷史報告，讓 PPA 指標看似改善。
- `anti-10`：把改良建議直接併入正式政策或正在執行的 Ticket，未經版本比對或批准。

## 0.6 第一階段實驗邊界

一個 APB3 CRC32 Engine，使用 Python Golden Model、開源 RTL/EDA。必須至少驗證新 Spec、Sim Failure、Formal Failure、PPA Target、環境漂移、空轉停止、人類插入變更、多 IP 任務隔離等情境。APB CRC32 收斂後可增加 AES-128 或小型 Peripheral；不可擅自先擴張 MCU／SoC 全系統。

## 0.7 「少打擾人類」量測定義

人類介入指一次需要使用者選擇工程方向、授權、補充不可推知的需求或手動恢復流程。Dashboard 觀察、主動閱讀紀錄不算介入。預先授權範圍內的自主執行，目標中途干擾次數為零。需求歧義、正式政策擴權、預算上調、外部發布及安全敏感變更需批准。停止而提供完整證據與可選方案，也是正確成果。

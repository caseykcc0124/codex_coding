# Activation by available native transport

The current conversation is always the interface. Pick by verified capabilities, not the product label or transcript source alone.

## Native same-thread heartbeat

Where automation_update is available, use a heartbeat bound to the current thread, preserving human intent, with no unchanged-state notifications. Inspect matching existing automations before creating another. Record its actual tool result privately. Do not substitute a standalone cron/new chat.

## Local CUI/CLI/IDE with native queue (Windows timer)

Verify `codex queue --help` and that the existing native shared local server owns/can reach the original main; do not start a replacement server, identify the current UUID from CODEX_THREAD_ID or trusted current runtime metadata, verify its stored source and cwd, then internally run Bind-Session.ps1. Source vscode is accepted along with cli and exec. No UUID guesses or new Main.

Wake-Session.ps1 calls native `codex queue --remote unix:// --thread UUID --message ...`. The running Codex process remains the writer and handles the queued wake in the same conversation; no exec resume, second model process, permission override or model override. It skips known active turns and holds one outstanding tick until transcript completion is observed. Queue errors stop without resume fallback. A missing/paginated transcript conservatively leaves the tick pending rather than flooding messages; investigate and reconcile the pending marker, never delete it just to retry blindly.

Test with a bounded marker message, verify assistant output and completion in the exact bound transcript, then test the registered task. Distinguish queue acknowledgement, execution and UI display. The real 0.163.0 vscode-source main accepted a native queue message and returned the marker while live; exec resume on the same main failed with active writer conflict. Source-label rejection was therefore incorrect.

Pause/resume by disabling/enabling the bound Windows task. Existing task registration must be inspected rather than duplicated. Do not require the human to execute helpers. Do not promise operation when a client is closed/offline or on another OS without a verified timer/transport adapter.

Binding saves the verified native binary and explicit native shared-server endpoint (unix://) privately so a headless timer uses the same transport. Queue client acknowledgement is bounded; only the newly created client may be ended after ack if it holds handles, never its process tree/server/main. Uncertain delivery leaves a pending marker and must be reconciled, not blindly retried.

Explicit $always-on in the current conversation is already activation/switch authority: pass -ActivateHere and archive/pause the prior binding internally, without another question. Do not bind during ordinary tasks. Maintain private work-status.json; idle/blocked produces no queued wake. Do not expose binding IDs in routine replies or run model marker tests in the user's main after it has already been accepted unless specifically needed/authorized for a regression.

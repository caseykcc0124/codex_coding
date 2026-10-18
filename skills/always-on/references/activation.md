# Client activation

## Codex desktop / local Work chat with native heartbeat tools

Discover automation_update. Inspect existing automation metadata for the matching main before creating a duplicate. Use kind=heartbeat, destination=thread, and the current thread (omit targetThreadId when the tool binds the caller). Default interval is 15 minutes. Use the tool's structured schedule fields; do not print raw scheduling directives as instructions to the user.

Prompt: Continue this main conversation's latest authorized intent. Read private intent/checkpoint when needed, reconcile recent human steering, progress unfinished work or authorized new source changes, use bounded native Luna workers when useful, verify evidence, preserve state and report meaningful changes in this conversation. No unrelated source scans, new chats, infinite goals or unapproved external effects. If nothing actionable changed, finish quietly.

Store returned automation ID and bound thread ID privately; never put a native automation capability into public templates. Verify actual tool result. Existing chats may require opening a new turn/client refresh to discover newly installed skills. Do not claim the current model changed due to loading this skill.

## Codex CLI on Windows

The agent runs scripts/Bind-Session.ps1 -Workspace <authorized root> -SessionId <verified UUID> internally. It verifies stored source is cli and cwd matches, then registers the wake against that UUID. Do not guess UUID from the latest session, copy auth, alter global sandbox or spawn a replacement main. This path only supports local Windows CLI.

Use scripts/Wake-Session.ps1 for an internal finite check. Inspect its JSONL for matching thread.started and turn.completed, and inspect the stored transcript for result persistence. Pause by disabling the returned task; resume by enabling it. Updating tasks means editing persistent intent through the main conversation, not Submit-AutonomyEvent.ps1.

The wake skips when the transcript indicates an active turn. There is still a race if the user starts a turn immediately after the check; simultaneous live CLI/worker UI behavior is client-dependent. Do not promise synchronized live rendering. For a strict single active executor, pause the timer during interactive work. It is not a message bridge to desktop chats.

Windows requires login, working network/auth and supported MXC sandbox. Fail closed on unsupported isolation. Do not downgrade safety or terminate other sessions to make it work.

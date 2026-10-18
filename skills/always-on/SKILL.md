---
name: always-on
description: Make the current Codex conversation the main agent for persistent work and bounded automatic follow-ups. Use when the user asks to enable Always On, keep working autonomously, manage long-lived intent, or pause/resume that mode.
---

# Always-on Codex main conversation

The current Codex conversation is the human interface. Take tasks and steering directly here, execute here, delegate bounded tasks when useful, verify evidence, and report here. Do not create another chat, inbox workflow, UI, or agent framework. GitHub is an installation source only. Users do not run helpers themselves.

On activation, preserve existing global/project instructions, MCP, credentials and policies. Main target is gpt-6.1-sol low; bounded native worker target is gpt-6-luna low. Verify actual routing; instructions cannot change the already-running model. Workers cannot delegate again or expand scope. Keep substantial multi-agent control-plane requirements from the user's existing instructions.

Maintain private .autonomy/INTENT.md, STATE.md and PROGRESS.md in the authorized workspace. Create only missing files, and merge new user steering without replacing existing intent. Store objectives, acceptance, permissions, sources, pending work, evidence and recovery conditions. Ignore these files and work/runtime artifacts in Git. The latest direct human message overrides stale saved plans. A new conversation must explicitly adopt or resume an existing main; do not silently rebind it or overwrite another session.

Do work immediately in the current turn. A timer is for later continuation, not a reason to defer current work. Reassess unfinished tasks and authorized source deltas on wake; verify worker artifacts before completion. No new work means WAIT. Changed state alone is not a new event. Stop retries without new evidence and record the condition needed to resume. Silence unchanged/nonactionable wakes; report meaningful completion, failure or a needed human decision in this main conversation. External messaging needs its own authorization.

## Bind the wake to this conversation

Read [activation.md](references/activation.md) for the installed client. Prefer an available native same-thread heartbeat tool. Do not create standalone cron jobs or new chats as a substitute. The prompt must preserve current intent, continue pending work and return results here, with no notification on unchanged state. Confirm tool-reported creation before saying enabled. Pause/resume through the same scheduler, keeping the existing ID.

For local Windows CUI/CLI or IDE sessions, use the included Bind-Session.ps1 with the verified current Session UUID and authorized workspace. Verify native `codex queue --help` support (tested with 0.163.0). Source `vscode` is valid when it is the verified current local main, not grounds for rejection. Obtain UUID from trusted runtime metadata such as CODEX_THREAD_ID; never guess the newest session. Verify the original main is reachable on the existing native shared local server; do not start an unrelated server or migrate it silently. The internal Windows timer calls `codex queue --remote unix:// --thread <UUID>` to deliver a finite wake to the existing main, preserving its active writer, model and permissions. Never use exec resume for a live main and never create a replacement session.

The wake uses a lock and keeps one outstanding tick until its completion is observed in the bound transcript; skip known active turns and never fall back to stealing the writer. Queue acknowledgement proves delivery acceptance, not execution: verify the actual assistant reply/task completion in the same transcript. Keep the old inbox scheduler disabled. Native heartbeat may be used where available, but is not required for a local client that supports native queue. Other OS timer adapters are not implemented by these Windows helpers. Closed clients, remote providers and unavailable queue endpoints need their own verified support; do not claim universal availability.

After activation, the user continues ordinary conversation here; no task file, PS1, or GitHub interaction is required. Only authorized source scopes may be monitored; do not assume Teams/Outlook are connected. Retain permission boundaries for external effects; autonomy does not grant new authority.

## Recovery and real input acceptance

A saved turn completion is not proof that the CUI is interactive. Before claiming activation is accepted, verify the actual client can accept input and return to an idle prompt; clear any unsubmitted test text. A reported input regression suspends wakes using private wake-suspended.json until real input acceptance is confirmed. Do not resume flooding an unverified client.

The Windows binder also installs a one-minute Watch-Main task without model calls. Wake-Session checks native thread health before queuing, not just transcript flags. The monitor may stop only a sandbox setup refresh older than 120 seconds, created after the outstanding automatic tick, for the exact workspace, owned by the native managed server, with its process identity rechecked. The native last user item must match that tick; do not cancel human/other work. It does not kill the main/server or disable hooks/security. Confirm native idle afterward; two failed recoveries for the same tick suspend wakes. This covers a known setup hang, not every UI, hook, platform or network fault. Read recovery.json/last-wake-failure.json when continuing after an incident and report meaningful unresolved failures.

Pause both the main timer and its -Recovery timer on human request. Recovery is not permission to change another session, broadly terminate processes, or retry a non-idempotent external action.

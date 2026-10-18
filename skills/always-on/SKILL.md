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

For CLI-only Windows, use the included Bind-Session.ps1 with a positively identified current CLI Session UUID and authorized workspace. It installs a hidden internal Windows wake that resumes that UUID; never use --last or create a new session. Obtain UUID from trusted current runtime metadata (such as CODEX_THREAD_ID), not newest-file guesses. Verify current session/source before binding. If unavailable, explain the specific missing binding; do not fabricate it. Keep any prior inbox scheduler disabled.

CLI persistence is not proof that an already-open terminal renders background updates. Verify transcript persistence separately and state that display limitation. AGENTS.md/skills alone cannot wake an exited process. Native heartbeat creation is not proof that a scheduled wake has fired; report verification levels accurately.

After activation, the user continues ordinary conversation here; no task file, PS1, or GitHub interaction is required. Only authorized source scopes may be monitored; do not assume Teams/Outlook are connected. Retain permission boundaries for external effects; autonomy does not grant new authority.

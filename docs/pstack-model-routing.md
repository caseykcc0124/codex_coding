# PStack Codex model routing policy

Version: 2026-11-02

This is a portable, public model-routing **policy and deployment specification**, not a claim that this repository installs a PStack runtime config automatically. It is intentionally separate from this repository's Always-on Codex setup, which has its own model defaults.

## Goals

- Use only **`gpt-6-luna`** and **`gpt-6.1-sol`**.
- Never select `gpt-6-astra`, any Astra variant, or legacy `gpt-6-sol`.
- Route routine parallel implementation to **Luna / high**.
- Route technical diagnosis, synthesis, integration and cross-module reasoning to **Sol / medium**.
- Route architecture, intent, agent behavior, permission and irreversible decisions to **Sol / high**.
- Do not automatically expand a task or delegate new authority when a worker discovers a larger issue.

Use the exact model IDs exposed by the target Codex installation. If a listed model/effort pair is unavailable, report the incompatible pair and stop that lane or inherit a **verified** compatible model. Never silently use Astra or claim an unverified model was served.

## Role-level defaults

| Role | Model assignment | Effort |
| --- | --- | --- |
| feature, refactoring | gpt-6-luna | high |
| bug-fix | gpt-6.1-sol | medium |
| perf-issue | gpt-6.1-sol | medium |
| hillclimb | gpt-6-luna | high |
| judgment and prose | gpt-6.1-sol | medium |
| strongest judgment | gpt-6.1-sol | high |
| how explorer | gpt-6-luna | high |
| how explainer | gpt-6.1-sol | medium |
| why investigators | gpt-6-luna | high |
| why synthesizer | gpt-6.1-sol | medium |
| reflect tooling | gpt-6.1-sol | medium |
| reflect judgment, divergent, synthesizer | gpt-6.1-sol | high |
| arena runners | gpt-6-luna, gpt-6.1-sol | high, medium |
| arena cross-judge pool | gpt-6.1-sol, gpt-6-luna | high, high |
| swarm workers | gpt-6-luna | high |
| architect runners | gpt-6.1-sol, gpt-6.1-sol | medium, high |
| interrogate reviewers | gpt-6-luna, gpt-6.1-sol | high, high |

`arena cross-judge pool` is a **candidate pool**, not a request to run both judges for each result; use one cross-family reviewer when the workflow requires it. Critical architecture outcomes still require Sol/high approval. Panel roles should normally launch **two candidates rather than four**; increase only with explicit need.

## Main coordinator and fallback effort

- Main/coordinator: `gpt-6.1-sol` at **medium** by default.
- Worker default: `gpt-6-luna` at **high**.
- Critical decision/review: `gpt-6.1-sol` at **high**.
- Generic fallback effort: **high**, with **explicit per-role overrides** as above. Avoid relying on `session` inference unless verified runtime metadata is available.
- No routine use of `xhigh` or `max`.

An example of the desired **parent** Codex preference, subject to local model validation:

```toml
model = "gpt-6.1-sol"
model_reasoning_effort = "medium"

[features]
multi_agent = true
```

Do not blindly overwrite an existing `config.toml`; merge only supported keys after examining the installed Codex version and the user's company policy.

## Dynamic escalation rules

Role defaults are not final authority. Judge each task by **scope and effect**:

1. **Normal → Luna/high**. Bounded implementation, localized refactoring, explicit test cases, code discovery, documentation, well-specified maintenance.
2. **Complex → Sol/medium**. Unknown bug root causes, performance diagnosis, multi-module integration, tradeoff analysis, interpreting conflicting evidence.
3. **Critical → Sol/high**. Intent semantics, state-machine transitions, agent behavior, tool authorization, permission boundaries, security-sensitive design, API/data-contract compatibility, architectural boundaries and hard-to-reverse changes.

When a Normal worker discovers a Critical change, the worker must **pause the affected change, return evidence and a proposal to the parent, and await a Sol/high decision**. The worker can then implement the approved, bounded specification. A Sol/high review is a technical escalation, **not an authorization to bypass user approvals** for sensitive or external actions.

For architecture sessions, preserve independent analysis where useful, but retain one accountable parent that integrates decisions and verifies tests.

## Concurrency and evidence

- Parallel work only for independently owned files, isolated worktrees, or non-overlapping outputs.
- Workers report changed paths, tests, evidence, remaining risks and any requested change of scope.
- The parent runs authoritative checks and owns the final integration, commit, push or deployment according to explicit user authorization.
- Avoid redundant workers and repeated reviews that do not add independent evidence.
- Target most routine worker tasks for Luna/high; do not treat any fixed workload percentage as a performance guarantee.

## SessionStart / Poteto routing

Preference: **enable trusted SessionStart/Poteto automatic routing** if the installed PStack variant actually supports it and the Codex host confirms trust.

- A hook must not be treated as active until verified by the host's supported mechanism.
- If the installed PStack provides only explicit skills or two optional profiles, do **not** invent 17 role profile files or claim they were activated.
- Keep routing recommendations in the parent policy until the installed PStack variant proves compatible.
- Fall back to explicit `$poteto-mode` and supported profiles when hook behavior is unavailable.

## Apply on a local Codex installation

Paste the following instruction to the **existing** Codex parent agent in the target environment:

> Read `docs/pstack-model-routing.md` from `caseykcc0124/codex_coding`. Inspect the **installed** PStack/Codex variant, supported model list, effective config location, AGENTS.md and trusted hook surfaces. Make a backup and preserve existing unrelated configuration, authentication, MCP, skills and the Always-on main session. Install only validated model/effort pairs. Map the 17 role defaults where supported; otherwise keep this policy as instructions and configure only available profiles. Set the main preference to Sol/medium, routine worker preference to Luna/high, and critical escalations to Sol/high. Never select Astra. Confirm the served model from runtime evidence where possible, then test a bounded Luna worker, Sol synthesis, critical Sol review, concurrent isolated workers and hook routing. Report applied files, test outcomes, unsupported features and unresolved risks. Do not push, publish, grant extra permissions or modify unrelated projects.

## Compatibility note

The public `Aqua-123/pstack-for-codex` derivative documents only two optional agent profiles (`pstack-poteto-agent` and `pstack-comment-sicko`) and validates model/effort pairs against supported runtime evidence. The 17-role table above is a **desired role mapping from another PStack setup surface** and is **not verified as a native parser format** of that derivative.

References:
- https://github.com/Aqua-123/pstack-for-codex
- https://github.com/Aqua-123/pstack-for-codex/blob/main/docs/codex-adaptation.md

No company-internal files, credentials, conversations, logs or state belong in this public policy.

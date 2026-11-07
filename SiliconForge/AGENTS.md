# SiliconForge Implementation Agent Contract

This repository contains a specification and acceptance baseline for an autonomous chip engineering framework. Before any implementation, read `README.md`, `docs/00_MISSION_AND_BOUNDARIES.md`, `docs/07_ACCEPTANCE_MATRIX.md`, then `docs/01` through `docs/06`, and `docs/08`.

Do not invent a custom natural language CLI. Do not turn Main Agent into a centralized technical decision maker. Keep P-Stack methods inside each Domain Owner. All event routing and job delivery must be persistent and policy governed. EDA Environment Owner alone promotes versioned toolchains. Completion requires actual EDA evidence and exact source/constraint/toolchain fingerprints, not model prose.

Use the installed Codex or Claude Code harness. To interact with a running SiliconForge service, use the SiliconForge MCP tools if connected; if not connected, report the integration blocker. Do not fabricate a service response.

Work toward M0–M7 in `docs/06_IMPLEMENTATION_ROADMAP.md`. Use `docs/07_ACCEPTANCE_MATRIX.md` as immutable required tests. Keep `SILICONFORGE_WORKING_SYNC.md` current and report precise real-vs-mock test results. Do not claim the prototype's mock tests prove actual EDA or harness integration.

No unapproved external publication, creation of public repositories, expansion of user scopes, increasing budgets, changing quality gates, or installing unrelated infrastructure.

Always respond in Traditional Chinese, including verified state, commit, test counts, evidence paths / hashes, blockers, risks, required approval, and next executable work.

## Mandatory v3.1 Parallel Exploration

Before implementing, read `docs/12_PARALLEL_EXPLORATION_ARCHITECTURE.md`, `docs/13_PARALLEL_EXPLORATION_ACCEPTANCE.md`, `docs/14_PARALLEL_EXPLORATION_IMPLEMENTATION.md`, and `config/exploration.yaml`. A Domain Role is not a singleton Owner Instance; multiple instances may run concurrently per requirement on different branch-scoped Git worktrees. Preserve parent/child branch lineage, trusted routing, candidate-scoped EDA evidence and post-merge re-gating. Implement M1X/M3X/M6X within the existing M0–M7 plan. There are **78 required cases** (A01–D12 and E01–E20). Never report mock results as actual EDA or claim mainline completion without merged-commit verification. Do not create a separate project.

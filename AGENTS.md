# TailZeroTrust — Project Context Hub

## Project Overview

TailZeroTrust is a Docker container app that turns the official Cloudflare WARP client into a Tailscale exit node: traffic from any device in the tailnet that selects this node as its exit node egresses through Cloudflare WARP or a Cloudflare Zero Trust organization. It is a fork of TailGuard with the WireGuard tunnel replaced by the Cloudflare WARP daemon, and additionally bundles mihomo (Clash Meta) as a mixed HTTP/SOCKS5 proxy (port 7890) whose traffic also egresses via WARP.

Tech stack: Docker (Debian base), POSIX shell (`/bin/sh` entrypoint + healthcheck), iptables/ip6tables/nftables firewalling, GitHub Actions (GHCR build/publish, mihomo release tracking), mihomo YAML config, Tailscale patched binaries, Cloudflare WARP daemon. No application-language runtime (no Node/Python/Java). Verification is runtime (container healthcheck + `curl` trace), not a unit-test suite.

## Setup & Dev Commands

- Build: `docker compose build`
- Run: `docker compose up -d`
- Test: runtime healthcheck only — `docker exec tailzerotrust-mihomo /tailzerotrust/healthcheck.sh` (expects exit 0 + `warp=on` trace)
- Lint: `shellcheck bin/entrypoint.sh bin/healthcheck.sh` (recommended; not wired in CI)
- Dev: `docker compose up -d` (logs via `docker logs -f tailzerotrust-mihomo`)

## Actionable Guardrails (Do's & Don'ts)

- **Don't** read `context-reports/` markdown files yourself.
  -> **Do** generate them using the MCP server — context reports via `custom_context_read_source_files`, tree reports via `custom_context_create_tree_report` ("create a tree of the project") — and hand the file path to the Manager.
- **Don't** execute Git commands like `git add`, `git commit`, or `git mv` autonomously or try to guess when to stage code.
  -> **Do** execute Git commands ONLY when explicitly instructed by an Orchestrator task block. Otherwise, rely on the `custom_context_stage_and_inject_diff` MCP tool.
  -> **Exception:** `git mv` is permitted autonomously for moving task files between Kanban directories.
- **Don't** guess blindly when facing complex bugs, deadlocks, or silent timeouts.
  -> **Do** utilize the `debug-instrumentation` skill to inject strategic logs and trace the runtime execution path.
- **Don't** write bash scripts without strict mode or mask errors with `2>/dev/null` on data commands.
  -> **Do** follow the Defensive Shell Protocol: `set -euo pipefail`, ban error masking, sidecar isolation for Docker backups. See `docs/conventions.md`.
- **Don't** perform financial mutations without snapshotting the prior state or allow nulls in monetary aggregations.
  -> **Do** follow the Universal Financial Ledger Standard: snapshot-on-write, `$ifNull` precedence, discrepancy alerting, deep config merging. See `docs/conventions.md`.
- **Don't** leave task numbers in visible prompt prose, section headings, or skill instructions.
  -> **Do** keep task-number references in code comments, CHANGELOG entries, task files, history archives, and HTML comments only. See `docs/conventions.md`.
- **Don't** carry over assumptions, partial results, or architectural hypotheses from a previous task.
  -> **Do** flush context and treat every task as contextually independent (Buffer Isolation directive in validation-phase).
- **Don't** execute raw, informal, or non-English prompts directly.
  -> **Do** load the `prompt-refactor` skill to translate and expand the intent into an elite English spec first. (Note: If you receive a standard XML task block, skip this and execute normally).
- **Don't** attempt to resolve cross-disciplinary ambiguity within a single persona.
  -> **Do** trigger the Multi-Agent Brainstorming Loop if the Manager explicitly requests brainstorming or a task exhibits cross-disciplinary ambiguity. Interpret the `<brainstorming_session>` results in backlog tasks as non-functional guidelines that govern execution.
- **Don't** silently alter slice architecture or domain invariants without updating the sibling README.md and appending a dated ADR to DECISIONS.md.
  -> **Do** inspect sibling README.md and DECISIONS.md before modifying code, and keep them in sync with implementation changes.
- **Don't** skip the execution workflow for trivial, single-file changes.
  -> **Do** traverse the full workflow for every task; keep scope minimal for trivial changes.
- **Don't** hand-edit governed types or duplicate contracts.
  -> **Do** import from the canonical source or run the stack's codegen toolchain (N/A here: no shared schema/contract package in this repo).

## Documentation Sync Rules

When modifying this repository, you must keep these files synchronized:

1. Active task file in `tasks/` (single source of truth for current work items)
2. `CHANGELOG.md` (Keep a Changelog format)
3. `docs/conventions.md` (syntax rules, datetime standard, SOLID guidelines)
4. Relevant `SKILL.md` files (if structural patterns were altered)
5. Sibling `README.md` / `DECISIONS.md` for any touched slice directory

## 🛑 GATEKEEPER VALIDATION (HALT PROTOCOL)

You (the Hands) are the final gatekeeper. Before executing any implementation task, you MUST evaluate the Orchestrator's instructions against this file and any referenced specs (`DESIGN.md`, `architecture.md`, etc.). If the instructions violate project rules, ignore them. HALT immediately and output a `⚠️ RULE VIOLATION WARNING` back to the Manager explaining exactly what the Orchestrator got wrong, forcing it to self-correct.

## 🛑 CORE FILE LOCATIONS

You MUST strictly adhere to these exact paths. Do not create duplicates elsewhere:

- **Global Rules:** `AGENTS.md` (Root)
- **UI/UX Specs:** `DESIGN.md` (Root) — **absent (no UI in this project); optional per Absent-File Policy, do not scaffold**
- **Architecture:** `docs/architecture.md` — **absent; optional per Absent-File Policy, do not scaffold**
- **Data Model:** `docs/data_model.md` — **absent; optional per Absent-File Policy, do not scaffold**
- **Conventions:** `docs/conventions.md`
- **Agent Skills (local):** `.opencode/skills/<skill-name>/SKILL.md` — **none installed; global skills apply**
- **Active Tasks:** `tasks/backlog/<task-name>.md`, `tasks/in-progress/`, `tasks/qa/`, `tasks/completed/`, `tasks/archive/`
- **Runtime State (gitignored):** `state/`, `warp/`, `tasks/.sessions/` (when present)

## 🛑 SKILL LOADING RULES

You MUST follow these skill loading rules in every session:

- **Task-Generator Skill:** Before creating any new task file, you MUST load the `kanban-lifecycle` skill using the `skill` tool to ensure the correct template format with `<!-- BEGIN_GIT_DIFF -->` / `<!-- END_GIT_DIFF -->` markers.
- **Project Skills:** Before implementing any task, you MUST load every available skill matching the project's tech stack. This project uses Docker + POSIX shell + GitHub Actions; **no stack skill exactly matches** (no `docker-shell` / `github-actions` skill exists). Record an explicit skip per the fallback rule: repo root scan, marker scan list (`Dockerfile`, `docker-compose.yml`, `bin/*.sh`, `.github/workflows/*.yml`, `mihomo-config.yaml`), matched skills list (none), reason phrase "no stack skill matches Docker/shell/CI infra". Apply closest skill for discipline only when a task touches a matching domain (e.g. `debug-instrumentation` for complex bugs).

### Project Skills (local)

| Skill | Trigger (when to load) | Duty |
|---|---|---|
| (none) | — | No local skills installed; global Skill Auto-Loading Matrix applies. |

## 🛑 CONTEXT BOOTSTRAPPING

At the start of every task, you MUST call `search_memory` or `list_namespaces` to load any hidden project quirks relevant to your domain before implementing.

## 🛑 CONTEXT MAP BEFORE BRAIN CALLS

Before any `brain_turn` carrying a planning or verdict request, produce a verified `context_paths` manifest (graph, capped directory tree at depth 3+, extracted signatures) and record one `Context-Map:` line beside the mode line. Never pass a bare label, directory, or wildcard in `context_paths`.

## 🛑 MANDATORY END-OF-TASK SEQUENCE

When finishing an implementation task, execute these steps in order:

1. Update `CHANGELOG.md` with the task's changes.
2. Record reasoning and verification evidence in the active task file.
3. Call `custom_context_qa_transition` once with the active task path and explicit `modified_files`. This tool atomically moves the task to `tasks/qa/`, synchronizes its `**File:**` header, stages modified files, and injects the diff. Do not move the task separately or manually edit its header.
4. Notify the Manager that the task is in QA and the Hands will chain QA/review through `brain_turn`. Never ask the Manager to copy, paste, or relay task contents.
5. Do not commit or close the task until the Manager gives the explicit closure approval phrase. Discovery tasks remain in their current lane.

## 🛑 BUFFER ISOLATION

Treat every task as contextually independent. Flush working execution assumptions between tasks; conversation thread persists under the active session ID until sprint completion.

## 🛑 LIVING FOLDER DOCS SIBLING INSPECTION

Before editing code in any component or vertical slice directory (`bin/`, `tailscale-patches/`), inspect the sibling `README.md` and `DECISIONS.md` and update them when domain contracts or architectural decisions change.
# Task 01: Infra Correctness & Currency Audit

**File:** `tasks/qa/01-infra-correctness-audit.md`
**Source:** manager
**Type:** improvement
**Status:** in-progress
**Submitted:** 2026-11-26T14:25:40Z
**Started:** 2026-11-26T14:22:27Z

## Goal

Audit every infrastructure component this repository depends on for correctness and currency, using blowsh web search plus Brain verification, and file follow-up fix tasks when drift is found. Components in scope: Docker base image `ghcr.io/eurocruz/tailzerotrust` (latest), Tailscale patched version inherited from that base, Cloudflare WARP client (warp-svc/warp-cli), mihomo release pin `v1.19.34` in `Dockerfile`, and the GitHub Actions versions pinned in `.github/workflows/*.yml`. The task is an init/verification task: it does not change runtime code unless a follow-up task is created.

## Manager's Notes

- Lock autopilot for execution.
- Use blowsh for all web research; use Brain for verification.
- If drift is found, create a new task from this one to fix it.
- Verification evidence must include URLs and exit codes.

## Local TODOs

- [x] Run blowsh searches for Docker base image currency
- [x] Run blowsh searches for Tailscale patched version currency
- [x] Run blowsh searches for Cloudflare WARP client currency
- [x] Run blowsh searches for mihomo release currency (pin v1.19.34)
- [x] Run blowsh searches for GitHub Actions versions currency
- [x] Feed gathered context to Brain via brain_turn for verification
- [x] Record findings in Execution Log
- [x] Create follow-up fix tasks if drift found
- [x] Run shellcheck on bin/*.sh
- [x] Run lint_task_file on this task

## Acceptance Criteria

- [x] blowsh search results recorded with URLs for each component
- [x] Brain verification recorded with verdict
- [x] Any drift documented and filed as a follow-up task (or "no drift found" stated)
- [x] Verification Evidence section populated with commands and exit codes

## Verification Evidence

- **Test command:** rtk test shellcheck bin/entrypoint.sh bin/healthcheck.sh
- **Expected result:** exit 0, no shellcheck warnings
- **Actual result:** exit 0, no warnings (rtk test collapsed passing suite)
- **Exit code:** 0
- **YAML validation:** python3 -c "import yaml; yaml.safe_load(...)" → exit 0, YAML OK

> Verification runner rule: the first verification run MUST use the `rtk test` prefix; record the exact prefixed command above. A raw rerun is allowed only after a failed RTK run for detailed diagnostics.

## Definition of Done

The task is NOT done unless ALL of the following are true:

- [x] Build/Test/Lint pass with exit code 0
- [x] `lint_task_file` passes on the active task file
- [x] `CHANGELOG.md` updated via Parse-Then-Append
- [x] `testing-verification` applied and evidence recorded

> **Box-checking mandate:** During the implementation summary phase, the Hands MUST check every `## Acceptance Criteria` and `## Definition of Done` box genuinely satisfied by the recorded `## Verification Evidence`.

## Risk & Rollback

- **Risk:** Web search results may be stale or unverified; Brain verification mitigates but does not eliminate hallucination.
- **Rollback plan:** Task is audit-only; no runtime code changes. Revert the task file via git checkout if needed (Manager-directed).

---

## Execution Log & Reasoning

Brain verdict (2026-11-26):
- Evidence file: context-reports/01-blowsh-evidence.txt (19 URLs, exit codes recorded, persisted from tmp-audit-blowsh.txt).
- C1 Base image (ghcr.io/eurocruz/tailzerotrust): maintained, last committer date 2026-11-12. TS_VERSION v1.104.7 + WARP_VERSION 2026.8.2115.0 match latest. No drift.
- C2 Tailscale v1.104.7 == latest upstream. No drift.
- C3 Cloudflare WARP 2026.8.2115.0 == latest stable. No drift.
- C4 mihomo v1.19.34 == latest stable tag (auto-tracked every 6h). No drift.
- C5 actions/checkout v6 == current major. No drift.
- C6 GitHub Actions pins drift (minor/patch, same major, low risk): setup-buildx v4.1.0->v4.4.1, login v4.2.0->v4.8.0, metadata v6.1.0->v6.2.0, build-push v7.2.0->v7.4.0, cosign v4.1.2->v4.1.4.
- Brain verdict: drifts are real but low-risk (same major). Recommend one follow-up task to bump the five pins with SHA updates and verify release notes. No breaking changes expected within same major (SemVer), but release notes must be checked during the bump.
- Brainstorm not required (single domain, reversible audit).
- Follow-up: create one backlog task; do not change workflows in this task.
- shellcheck bin/entrypoint.sh bin/healthcheck.sh: exit 0.
- lint_task_file on tasks/qa/01-infra-correctness-audit.md: exit 0.

## Factual Git Diff

<!-- BEGIN_GIT_DIFF -->
```diff
diff --git a/CHANGELOG.md b/CHANGELOG.md
new file mode 100644
index 0000000..4970550
--- /dev/null
+++ b/CHANGELOG.md
@@ -0,0 +1,12 @@
+# Changelog
+
+All notable changes to this project will be documented in this file.
+
+The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
+and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
+
+## [Unreleased]
+
+### Added
+- Governance onboarding: `AGENTS.md`, `docs/conventions.md`, Living Folder Docs for `bin/` and `tailscale-patches/`, Kanban task directories.
+- 2026-11-26: Infra correctness & currency audit (task 01) plus follow-up GHA pins bump task (task 02). Audit verified base image, Tailscale, WARP, mihomo current; identified 5 GHA pin drifts.
\ No newline at end of file
```
<!-- END_GIT_DIFF -->
# Task 02: Bump GitHub Actions Pins (GHA Currency)

**File:** `tasks/backlog/02-gha-pins-bump.md`
**Source:** manager
**Type:** improvement
**Status:** open

## Goal

Bump five GitHub Actions pins in `.github/workflows/ghcr-publish.yml` to their latest versions within the same major, updating both the version comment and the commit SHA, and verify release notes for breaking changes. Scope: setup-buildx-action v4.1.0->v4.4.1, login-action v4.2.0->v4.8.0, metadata-action v6.1.0->v6.2.0, build-push-action v7.2.0->v7.4.0, cosign-installer v4.1.2->v4.1.4. Keep actions/checkout at v6.

## Manager's Notes

- Created from audit Task 01 (infra correctness & currency audit).
- Verify release notes for each bumped action before merging.
- Do not change workflow logic; pins and SHAs only.
- Do not bump across major versions.

## Local TODOs

- [ ] Fetch release notes for each bumped action
- [ ] Check for breaking changes within same major
- [ ] Update version comments and SHAs in ghcr-publish.yml
- [ ] Validate YAML parses
- [ ] Run lint_task_file on this task

## Acceptance Criteria

- [ ] Five pins updated (setup-buildx, login, metadata, build-push, cosign)
- [ ] Release notes checked for breaking changes
- [ ] Evidence populated with commands and exit codes
- [ ] YAML valid

## Verification Evidence

- **Test command:** rtk test python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ghcr-publish.yml')); print('YAML OK')"
- **Expected result:** exit 0, YAML OK
- **Actual result:** _(The Hands fill this during execution)_
- **Exit code:** _(The Hands fill this during execution)_

## Definition of Done

The task is NOT done unless ALL of the following are true:

- [ ] Build/Test/Lint pass with exit code 0
- [ ] `lint_task_file` passes on the active task file
- [ ] `CHANGELOG.md` updated via Parse-Then-Append
- [ ] `testing-verification` applied and evidence recorded

## Risk & Rollback

- **Risk:** Minor behavior change within same major; mitigated by release-notes review.
- **Rollback plan:** Revert workflow file via git checkout (Manager-directed).

---

## Execution Log & Reasoning

_(The Hands: log changes here)_

## Factual Git Diff

<!-- BEGIN_GIT_DIFF -->

_(Git diff will be automatically injected here by the MCP tool. Do not edit this block manually)_

<!-- END_GIT_DIFF -->
# Task 02: Bump GitHub Actions Pins (GHA Currency)

**File:** `tasks/completed/02-gha-pins-bump.md`
**Source:** manager
**Type:** improvement
**Status:** closed
**Finished:** 2026-11-26T14:55:55Z
**Submitted:** 2026-11-26T14:50:28Z
**Started:** 2026-11-26T14:46:57Z

## Goal

Bump five GitHub Actions pins in `.github/workflows/ghcr-publish.yml` to their latest versions within the same major, updating both the version comment and the commit SHA, and verify release notes for breaking changes. Scope: setup-buildx-action v4.1.0->v4.4.1, login-action v4.2.0->v4.8.0, metadata-action v6.1.0->v6.2.0, build-push-action v7.2.0->v7.4.0, cosign-installer v4.1.2->v4.1.4. Keep actions/checkout at v6.

## Manager's Notes

- Created from audit Task 01 (infra correctness & currency audit).
- Verify release notes for each bumped action before merging.
- Do not change workflow logic; pins and SHAs only.
- Do not bump across major versions.

## Local TODOs

- [x] Fetch release notes for each bumped action
- [x] Check for breaking changes within same major (none found)
- [x] Update version comments and SHAs in ghcr-publish.yml
- [x] Validate YAML parses
- [x] Run lint_task_file on this task

## Acceptance Criteria

- [x] Five pins updated (setup-buildx, login, metadata, build-push, cosign)
- [x] Release notes checked for breaking changes (none found)
- [x] Evidence populated with commands and exit codes
- [x] YAML valid

## Verification Evidence

- **Test command:** rtk test python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ghcr-publish.yml')); print('YAML OK')"
- **Expected result:** exit 0, YAML OK
- **Actual result:** exit 0, YAML OK; pins updated to v4.4.1, v4.8.0, v6.2.0, v7.4.0, v4.1.4
- **Exit code:** 0

## Definition of Done

The task is NOT done unless ALL of the following are true:

- [x] Build/Test/Lint pass with exit code 0
- [x] `lint_task_file` passes on the active task file
- [x] `CHANGELOG.md` updated via Parse-Then-Append
- [x] `testing-verification` applied and evidence recorded

## Risk & Rollback

- **Risk:** Minor behavior change within same major; mitigated by release-notes review.
- **Rollback plan:** Revert workflow file via git checkout (Manager-directed).

---

## Execution Log & Reasoning

Updated five GHA pins in .github/workflows/ghcr-publish.yml to latest within same major:
- sigstore/cosign-installer: v4.1.2 -> v4.1.4 (SHA 881c63bd...)
- docker/setup-buildx-action: v4.1.0 -> v4.4.1 (SHA f87e5991...)
- docker/login-action: v4.2.0 -> v4.8.0 (SHA 8aa5831f...)
- docker/metadata-action: v6.1.0 -> v6.2.0 (SHA dc802804...)
- docker/build-push-action: v7.2.0 -> v7.4.0 (SHA c3c9e263...)
checkout kept at v6. Release notes probed for "breaking/BREAKING/migration" on all five release pages: NO-MATCH. YAML parse: exit 0.

## Factual Git Diff

<!-- BEGIN_GIT_DIFF -->
**Factual Git Diff:** Stored in Commit Hash: `5af03c9a51f7f03589f01bbff86b578432595e0e`
<!-- END_GIT_DIFF -->
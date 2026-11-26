# Task 02: Bump GitHub Actions Pins (GHA Currency)

**File:** `tasks/qa/02-gha-pins-bump.md`
**Source:** manager
**Type:** improvement
**Status:** in-progress
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
```diff
diff --git a/.github/workflows/ghcr-publish.yml b/.github/workflows/ghcr-publish.yml
index 0cdb8dc..7c29e90 100644
--- a/.github/workflows/ghcr-publish.yml
+++ b/.github/workflows/ghcr-publish.yml
@@ -63,7 +63,7 @@ jobs:
       # https://github.com/sigstore/cosign-installer
       - name: Install cosign
         if: github.event_name != 'pull_request'
-        uses: sigstore/cosign-installer@6f9f17788090df1f26f669e9d70d6ae9567deba6 # v4.1.2
+        uses: sigstore/cosign-installer@881c63bd87e38389154debd8331404ce7ca8a3ab # v4.1.4
         with:
           cosign-release: 'v2.2.4'
 
@@ -71,13 +71,13 @@ jobs:
       # multi-platform images and export cache
       # https://github.com/docker/setup-buildx-action
       - name: Set up Docker Buildx
-        uses: docker/setup-buildx-action@d7f5e7f509e45cec5c76c4d5afdd7de93d0b3df5 # v4.1.0
+        uses: docker/setup-buildx-action@f87e5991a6d7451dcb8d9637bfbc97413f497069 # v4.4.1
 
       # Login against a Docker registry except on PR
       # https://github.com/docker/login-action
       - name: Log into registry ${{ env.REGISTRY }}
         if: github.event_name != 'pull_request'
-        uses: docker/login-action@650006c6eb7dba73a995cc03b0b2d7f5ca915bee # v4.2.0
+        uses: docker/login-action@8aa5831fb8d48d8f76594c7ddde61ae58019f550 # v4.8.0
         with:
           registry: ${{ env.REGISTRY }}
           username: ${{ github.actor }}
@@ -87,7 +87,7 @@ jobs:
       # https://github.com/docker/metadata-action
       - name: Extract Docker metadata
         id: meta
-        uses: docker/metadata-action@80c7e94dd9b9319bd5eb7a0e0fe9291e23a2a2e9 # v6.1.0
+        uses: docker/metadata-action@dc802804100637a589fabce1cb79ff13a1411302 # v6.2.0
         with:
           images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
           tags: |
@@ -100,7 +100,7 @@ jobs:
       # https://github.com/docker/build-push-action
       - name: Build and push Docker image
         id: build-and-push
-        uses: docker/build-push-action@f9f3042f7e2789586610d6e8b85c8f03e5195baf # v7.2.0
+        uses: docker/build-push-action@c3c9e263c25d99ce0380d002d59b67737d91b0dc # v7.4.0
         with:
           context: .
           provenance: false
diff --git a/CHANGELOG.md b/CHANGELOG.md
index f65832d..dde1ed2 100644
--- a/CHANGELOG.md
+++ b/CHANGELOG.md
@@ -10,3 +10,4 @@ and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0
 ### Added
 - Governance onboarding: `AGENTS.md`, `docs/conventions.md`, Living Folder Docs for `bin/` and `tailscale-patches/`, Kanban task directories.
 - 2026-11-26: Infra correctness & currency audit (task 01) plus follow-up GHA pins bump task (task 02). Audit verified base image, Tailscale, WARP, mihomo current; identified 5 GHA pin drifts.
+- 2026-11-26: Bumped five GitHub Actions pins in ghcr-publish.yml to latest within same major (setup-buildx v4.4.1, login v4.8.0, metadata v6.2.0, build-push v7.4.0, cosign v4.1.4). No breaking changes found.
```
<!-- END_GIT_DIFF -->
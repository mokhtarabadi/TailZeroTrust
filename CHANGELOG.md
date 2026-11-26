# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Governance onboarding: `AGENTS.md`, `docs/conventions.md`, Living Folder Docs for `bin/` and `tailscale-patches/`, Kanban task directories.
- 2026-11-26: Infra correctness & currency audit (task 01) plus follow-up GHA pins bump task (task 02). Audit verified base image, Tailscale, WARP, mihomo current; identified 5 GHA pin drifts.
- 2026-11-26: Bumped five GitHub Actions pins in ghcr-publish.yml to latest within same major (setup-buildx v4.4.1, login v4.8.0, metadata v6.2.0, build-push v7.4.0, cosign v4.1.4). No breaking changes found.

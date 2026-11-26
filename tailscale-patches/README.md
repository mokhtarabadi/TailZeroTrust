# Slice: tailscale-patches

## Duties

Patched Tailscale source patches inherited from TailGuard, applied during the base image build. They prevent Tailscale from taking over default routes and from adding conflicting firewall rules, so WARP retains egress control.

## Files

- `0001-net-netmon-Do-not-iterate-over-problematic-interface.patch`
- `0002-net-netmon-Allow-excluding-custom-interfaces.patch`
- `0003-wgengine-router-osrouter-Do-not-add-tailscale-rule.patch`

## Key Risks & Invariants

- Patches must apply cleanly against the pinned Tailscale version in the base image (`ghcr.io/eurocruz/tailzerotrust`); version bumps may require rebase.
- Do not edit patch files by hand without regenerating via `git format-patch`.
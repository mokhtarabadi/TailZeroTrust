# Slice: bin

## Duties

Shell entrypoint and healthcheck for the TailZeroTrust container. `entrypoint.sh` bootstraps WARP, mihomo, firewall rules, and Tailscale (containerboot). `healthcheck.sh` enforces tg-* chains, WARP connectivity, mihomo health, and Tailscale `/healthz`, and records healthy epoch.

## Files

- `entrypoint.sh` — main container entrypoint: WARP daemon + enrollment, mihomo proxy startup, TailGuard firewall (iptables/ip6tables/nftables), Tailscale daemon launch.
- `healthcheck.sh` — Docker healthcheck: firewall chain enforcement, WARP/mihomo/Tailscale probes, delayed-script runner.

## Key Risks & Invariants

- Must run under `set -e` (entrypoint) / strict checks (healthcheck); firewall rules must be idempotent on re-runs.
- Healthcheck is the container's liveness gate; a failing probe restarts the container.
- Do not break the WARP firewall exceptions (0x80000 mark) or tailnet routing.
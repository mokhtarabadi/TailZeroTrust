# TailZeroTrust

A simple Docker container app which turns the official Cloudflare WARP client
into a Tailscale exit node. Select it as the exit node on any device in your
tailnet and its traffic goes out through Cloudflare WARP or your Cloudflare
Zero Trust organization.

TailZeroTrust is a fork of [TailGuard](https://github.com/juhovh/tailguard),
with the WireGuard tunnel replaced by the Cloudflare WARP daemon.

The network topology will look roughly like this:
```
  +---------+
  | device1 |\
  +---------+ \                        VPS
  +---------+  \ +-----------+    +---------------+    +----------------+
  | device2 |----| Tailscale |<-->| TailZeroTrust |<-->| Cloudflare     |
  +---------+  / +-----------+    +---------------+    | WARP/Zero Trust|
  +---------+ /                                        +----------------+
  | device3 |/
  +---------+
```

## Benefits

Why would you want to do this? For most use cases it may be easier to run the
WARP client on your devices directly, but there are a couple of benefits with
this bridged approach:
- the device enrollment and credentials are stored only on a single machine
- devices that can't run WARP, or where you don't want to install it, can still
  use Cloudflare Gateway policies by selecting an exit node
- it's easier to switch between exit nodes in your tailnet, without having to
  reconnect to different VPNs
- you can have access to both your tailnet and WARP concurrently on your
  mobile device, which doesn't support multiple VPNs
- you can temporarily share access to WARP with other people using Tailscale,
  without having to enroll their devices

## Installation

The simplest way to start TailZeroTrust is with consumer WARP, which needs no
account at all:

```bash
docker compose up -d
```

This builds `ghcr.io/mokhtarabadi/tailzerotrust-mihomo:latest` (or pulls it
if already published), starts container `tailzerotrust-mihomo`, and persists
Tailscale/WARP state in `./state` and `./warp`.

Docker will print you an URL where you need to log in to your tailnet, and after
that you should be good to go. Approve the exit node in the Tailscale admin
console, select it on your device and visit
<https://www.cloudflare.com/cdn-cgi/trace>, which should show `warp=on` (or
`warp=plus`).

That's it, happy networking!

### Cloudflare Zero Trust

To enroll the container into your Zero Trust organization without a browser,
create a service token in **Access → Service Auth**, allow it to enroll devices
in **Settings → WARP Client → Device enrollment permissions** (a rule with the
*Service Auth* action), and pass it in:

```
    environment:
      - WARP_ORGANIZATION=your-team-name
      - WARP_AUTH_CLIENT_ID=xxxxxxxx.access
      - WARP_AUTH_CLIENT_SECRET=xxxxxxxx
```

Alternatively you can register it as a
[WARP Connector](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/private-net/warp-connector/)
with `WARP_CONNECTOR_TOKEN`.

The Split Tunnels settings of the device profile still apply. The default
exclude list contains `100.64.0.0/10`, which is fine: TailZeroTrust routes the
tailnet itself and sends everything forwarded from it into WARP.

### Advanced settings

Supported configuration parameters through environment:
- `TG_EXPOSE_HOST` - Set to 1 if you want to allow connections from TS and WARP peers
- `TG_NAMESERVERS` - Nameservers to use if WARP leaves the Docker resolver in place (**default:** Cloudflare 1.1.1.1)
- `WARP_ORGANIZATION` - Zero Trust team name, consumer WARP is used if not set
- `WARP_AUTH_CLIENT_ID` - Zero Trust service token client ID for enrollment
- `WARP_AUTH_CLIENT_SECRET` - Zero Trust service token client secret for enrollment
- `WARP_CONNECTOR_TOKEN` - Register as a WARP Connector with the given token instead
- `WARP_PROTOCOL` - Tunnel protocol for Zero Trust, `wireguard` or `masque` (**default:** from device profile)
- `WARP_LICENSE_KEY` - WARP+ license key for consumer WARP
- `WARP_CONNECT_TIMEOUT` - Seconds to wait for WARP to connect (**default:** 120)
- `TS_DEVICE` - Tailscale device name, must be a valid device name (**default:** tailscale0)
- `TS_PORT` - Tailscale port number, should be exposed by Docker (**default:** 41641)
- `TS_LOGIN_SERVER` - URL of the control server if not using Tailscale default
- `TS_AUTHKEY` - Tailscale auth key for authentication if used
- `TS_HOSTNAME` - Tailscale hostname for this device if used
- `TS_ROUTES` - Set routes to advertise in addition to the exit node

Some of these parameteres follow the naming of Tailscale Docker image
[parameters](https://tailscale.com/kb/1282/docker), in which case they should
also work the same way.

### How it works

The WARP daemon routes everything that is not marked with its own fwmark
through the `CloudflareWARP` interface, much like `wg-quick` does. On top of
that, it installs an nftables firewall which drops traffic bypassing the tunnel.

- The patched Tailscale from TailGuard doesn't take over the default routes,
  and ignores the `CloudflareWARP` interface.
- Tailscale's own packets carry the `0x80000` mark, so they keep using the
  regular network, while the healthcheck keeps exceptions for them in the WARP
  firewall (WARP rebuilds it on reconnects).
- Packets forwarded from the tailnet may only leave through `CloudflareWARP`:
  if WARP is down, nothing is forwarded at all.
- Only `warp-svc` and `warp-cli` are taken from the official package, which
  otherwise depends on a full desktop stack. As WARP is built against glibc,
  the image is based on Debian instead of Alpine.

### Updates

This fork builds from `ghcr.io/eurocruz/tailzerotrust:latest`, so Tailscale,
Cloudflare WARP and the upstream networking logic are inherited automatically.
`.github/workflows/update.yml` tracks the latest mihomo release every six hours,
updates `MIHOMO_VERSION` in the Dockerfile and pushes the change. The GHCR
workflow rebuilds the image on every push to `main` and publishes it daily.

## Mihomo Proxy (added)

This fork adds **mihomo** (Clash Meta) as a mixed proxy (HTTP + SOCKS5) on
port **7890** inside the container. All traffic captured by mihomo egresses
through the container's WARP tunnel, so clients using the proxy get a
Cloudflare WARP IP.

### Usage

```bash
# Build the image
docker compose build

# Run
docker compose up -d

# Use the proxy from any LAN client
curl -x http://<host-ip>:7890 https://www.cloudflare.com/cdn-cgi/trace
# Should show warp=on
```

### Configuration

Mihomo config is in `mihomo-config.yaml`. Default: mixed-port 7890,
allow-lan true, bind-address *, MATCH,DIRECT (all traffic goes direct
through the container's WARP tunnel).

### Ports

| Port | Protocol | Purpose |
|---|---|---|
| 41642/udp (host) → 41641/udp (container) | UDP | Tailscale direct connections |
| 7890/tcp | TCP | Mihomo mixed proxy (HTTP + SOCKS5) |

### Notes

- Mihomo runs inside the container's network namespace, so all egress
  goes through WARP automatically.
- The host's own traffic is NOT routed through mihomo (avoids routing
  loops). Use the Tailscale exit node or WARP proxy mode on the host
  if host-level WARP is needed.
- Mihomo external controller is on 127.0.0.1:9090 (inside container only).

## Stable Identity

The container uses a fixed Tailscale hostname and Tailnet IP:

| Field | Value |
|---|---|
| Docker container name | `tailzerotrust-mihomo` |
| Tailscale hostname | `warp-exit-mihomo` |
| Tailnet IPv4 | `100.74.8.111` |
| Mihomo proxy | `100.74.8.111:7890` (Tailnet) or `<host-ip>:7890` (LAN) |
| Tailscale underlay port | `41642/udp` on the host |

`TS_HOSTNAME=warp-exit-mihomo` is set in `docker-compose.yml` so the Tailscale
hostname stays stable across restarts and container recreation. Tailscale
state is persisted in the `./state` bind mount, preserving the node identity
and Tailnet IP. Do not delete `./state` unless you intentionally want a new
tailnet node and IP. The `./warp` directory contains WARP registration
credentials. Both directories are gitignored and must never be committed.

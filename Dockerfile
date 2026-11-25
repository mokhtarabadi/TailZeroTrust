FROM ghcr.io/eurocruz/tailzerotrust:latest

# Install mihomo (latest release)
ARG MIHOMO_VERSION="v1.19.34"
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl && \
    curl -fsSL -o /tmp/mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VERSION}/mihomo-linux-amd64-${MIHOMO_VERSION}.gz" && \
    gunzip /tmp/mihomo.gz && \
    chmod +x /tmp/mihomo && \
    mv /tmp/mihomo /usr/local/bin/mihomo && \
    rm -rf /var/lib/apt/lists/*

# Copy mihomo config
COPY mihomo-config.yaml /tailzerotrust/mihomo-config.yaml

# Override entrypoint with our modified version.
# It starts mihomo after WARP connects, sets up firewall rules including
# port 7890, and then starts Tailscale.
COPY bin/entrypoint.sh /tailzerotrust/entrypoint.sh
RUN chmod 755 /tailzerotrust/entrypoint.sh

EXPOSE 7890

ENTRYPOINT ["/tailzerotrust/entrypoint.sh"]

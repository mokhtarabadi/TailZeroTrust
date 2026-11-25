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

# Override entrypoint with our modified version (includes mihomo firewall rule)
COPY bin/entrypoint.sh /tailzerotrust/entrypoint.sh
RUN chmod 755 /tailzerotrust/entrypoint.sh

# Create wrapper entrypoint that starts mihomo then calls original
RUN cat > /tailzerotrust/entrypoint-mihomo.sh << 'WRAPPER'
#!/bin/sh
set -e

# Start mihomo mixed proxy (traffic egresses via WARP tunnel)
mkdir -p /tailzerotrust/mihomo-data
cp /tailzerotrust/mihomo-config.yaml /tailzerotrust/mihomo-data/config.yaml
/usr/local/bin/mihomo -d /tailzerotrust/mihomo-data &
MIHOMO_PID=$!
sleep 2
if kill -0 "$MIHOMO_PID" 2>/dev/null; then
  echo "mihomo started (PID $MIHOMO_PID), mixed-port 7890, LAN listen enabled"
else
  echo "WARNING: mihomo did not start"
fi

# Note: iptables rule for 7890 is in entrypoint.sh (after firewall setup)
# Call original entrypoint
exec /tailzerotrust/entrypoint.sh "$@" 
WRAPPER
RUN chmod 755 /tailzerotrust/entrypoint-mihomo.sh

EXPOSE 7890

ENTRYPOINT ["/tailzerotrust/entrypoint-mihomo.sh"]

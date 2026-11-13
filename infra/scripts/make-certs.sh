#!/usr/bin/env bash
# Makes a locally trusted TLS certificate for the broker with mkcert and
# turns on the TLS (8883) and WSS (8884) listeners.
#
#   infra/scripts/make-certs.sh [extra-hostname-or-ip ...]
#
# The certificate is for localhost, 127.0.0.1 and ::1, plus anything you
# pass (your Mac's LAN name or IP, so a phone on the same Wi-Fi can connect).
#
# Writes (all git-ignored):
#   infra/certs/ca.crt, server.crt, server.key
#   infra/mosquitto/conf.d/tls.conf
#
# One-time setup: `brew install mkcert` then `mkcert -install`, which puts a
# local certificate authority in your keychain so browsers and native apps
# trust what this script makes. mkcert -install is yours to run: it asks for
# your password.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
certs="$here/certs"
mkdir -p "$certs" "$here/mosquitto/conf.d"

if ! command -v mkcert > /dev/null; then
  echo "mkcert is not installed: brew install mkcert && mkcert -install" >&2
  exit 1
fi
caroot="$(mkcert -CAROOT)"
if [ ! -f "$caroot/rootCA.pem" ]; then
  echo "No local CA yet. Run: mkcert -install" >&2
  exit 1
fi

mkcert -cert-file "$certs/server.crt" -key-file "$certs/server.key" \
  localhost 127.0.0.1 ::1 "$@"
cp "$caroot/rootCA.pem" "$certs/ca.crt"
# The broker runs as its own user inside the container and has to read the
# key. This is a development certificate from a CA that exists only on this
# machine, so world-readable is acceptable here and nowhere else.
chmod 644 "$certs/server.crt" "$certs/server.key" "$certs/ca.crt"

cat > "$here/mosquitto/conf.d/tls.conf" <<'CONF'
# Written by scripts/make-certs.sh. TLS and secure WebSocket listeners.

listener 8883
protocol mqtt
cafile /mosquitto/certs/ca.crt
certfile /mosquitto/certs/server.crt
keyfile /mosquitto/certs/server.key

listener 8884
protocol websockets
cafile /mosquitto/certs/ca.crt
certfile /mosquitto/certs/server.crt
keyfile /mosquitto/certs/server.key
CONF

echo "Certificate for: localhost 127.0.0.1 ::1 $*"
echo "TLS on 8883 and WSS on 8884 are on. Restart the broker: docker compose -f infra/docker-compose.yml restart mosquitto"

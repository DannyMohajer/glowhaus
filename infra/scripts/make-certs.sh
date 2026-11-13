#!/usr/bin/env bash
# Makes a locally trusted TLS certificate for the broker with mkcert and
# turns on the TLS (8883) and WSS (8884) listeners.
#
#   infra/scripts/make-certs.sh [--lan] [--no-install] [extra-name-or-ip ...]
#
#   --lan         also cover this Mac's LAN IP and <name>.local, so a phone on
#                 the same Wi-Fi can connect (start compose in LAN mode too,
#                 see infra/README.md)
#   --no-install  do not touch any trust store; use the CA file only (CI)
#
# The certificate always covers localhost, 127.0.0.1 and ::1.
#
# Writes (all git-ignored):
#   infra/certs/ca.crt, server.crt, server.key
#   infra/mosquitto/conf.d/tls.conf
#
# mkcert -install puts mkcert's local certificate authority in the macOS
# keychain. It asks for your password the first time and does nothing after.
set -euo pipefail

# Only the system trust store: the macOS keychain, which Safari, Chrome,
# Edge, curl, and Dart and Flutter on macOS and the iOS simulator all use.
# Without this, mkcert also tries Firefox's NSS store and Java's cacerts,
# which need certutil and a JDK and otherwise end in warnings. Firefox users
# can set security.enterprise_roots.enabled to make it read the keychain.
export TRUST_STORES=system

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
certs="$here/certs"
mkdir -p "$certs" "$here/mosquitto/conf.d"

lan=false
install=true
names=(localhost 127.0.0.1 ::1)
for arg in "$@"; do
  case "$arg" in
    --lan) lan=true ;;
    --no-install) install=false ;;
    -*) echo "unknown option: $arg" >&2; exit 64 ;;
    *) names+=("$arg") ;;
  esac
done

if ! command -v mkcert > /dev/null; then
  echo "mkcert is not installed: brew install mkcert" >&2
  exit 1
fi

if $lan; then
  ip=""
  for interface in en0 en1 en2; do
    ip="$(ipconfig getifaddr "$interface" 2> /dev/null || true)"
    [ -n "$ip" ] && break
  done
  if [ -z "$ip" ]; then
    echo "--lan: no LAN address found on en0-en2; pass the IP yourself" >&2
    exit 1
  fi
  names+=("$ip")
  host="$(scutil --get LocalHostName 2> /dev/null || true)"
  [ -n "$host" ] && names+=("$host.local")
fi

if $install; then
  mkcert -install
fi
caroot="$(mkcert -CAROOT)"

mkcert -cert-file "$certs/server.crt" -key-file "$certs/server.key" \
  "${names[@]}"
cp "$caroot/rootCA.pem" "$certs/ca.crt"
# The broker runs as its own user inside the container and has to read the
# key. This is a development certificate from a CA that exists only on this
# machine, so world-readable is acceptable here and nowhere else.
chmod 644 "$certs/server.crt" "$certs/server.key" "$certs/ca.crt"

cat > "$here/mosquitto/conf.d/tls.conf" << 'CONF'
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

echo "Certificate for: ${names[*]}"
echo "TLS on 8883 and WSS on 8884 are on. Restart the broker:"
echo "  docker compose -f infra/docker-compose.yml restart mosquitto"
if $lan; then
  echo "LAN mode: start compose with GLOWHAUS_BIND=0.0.0.0, then connect to ${ip}."
fi

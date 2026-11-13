# Infra: broker, simulator, test camera

Everything the app needs to run against a real network, on one machine:

| Service | Image | What | Ports on the host |
|---|---|---|---|
| `mosquitto` | `eclipse-mosquitto:2` | MQTT broker, password + ACL per identity | 1883 plain, 8883 TLS, 8884 WSS, all on loopback by default |
| `simulator` | built from [`simulator/Dockerfile`](simulator/Dockerfile) | the demo home's twelve devices ([`../simulator`](../simulator)), with a watchdog | none |
| `camera` | `bluenviron/mediamtx:latest-ffmpeg` | an RTSP test pattern as the doorbell camera | 8554 RTSP, 8888 HLS, loopback by default |

## Setup on a Mac

```bash
brew install --cask docker
```

```bash
brew install mkcert mosquitto
```

Open Docker Desktop once so the daemon runs. `mosquitto` from Homebrew is
only for its `mosquitto_passwd` and `mosquitto_sub` / `mosquitto_pub` tools;
the broker itself runs in Docker.

## Start

```bash
infra/scripts/make-users.sh
```

```bash
infra/scripts/make-certs.sh
```

```bash
docker compose -f infra/docker-compose.yml up --build
```

`make-users.sh` writes a random password for every identity in
[`mosquitto/acl.conf`](mosquitto/acl.conf) to `infra/secrets/credentials`
(`username:password` per line, git-ignored) and the hashed `passwd` the
broker reads. The simulator mounts the same file and each device logs in as
itself. The line starting `demo-home.app:` is what you type into the app.

`make-certs.sh` makes a certificate for `localhost`, `127.0.0.1` and `::1`
with mkcert and turns on the TLS and WSS listeners. The first time, it runs
`mkcert -install`, which puts a certificate authority that exists only on
this machine into your keychain and asks for your password. Later runs skip
that step.

The script sets `TRUST_STORES=system`, so mkcert installs into the macOS
keychain only. That covers Safari, Chrome, Edge, curl, and Dart and Flutter
on macOS. Without it, mkcert also tries Firefox's NSS store and Java's
`cacerts`, which need `certutil` and a JDK and otherwise end in warnings.
Firefox can read the keychain instead: set
`security.enterprise_roots.enabled` to `true` in `about:config`.
`--no-install` skips the trust store entirely and is what CI uses.

Without `make-certs.sh` the broker still runs, with plain MQTT on
`127.0.0.1:1883` only.

Check it from the host:

```bash
mosquitto_sub -h localhost -p 1883 -u demo-home.app -P "$(grep '^demo-home.app:' infra/secrets/credentials | cut -d: -f2)" -t 'glowhaus/demo-home/+/availability' -v
```

The camera stream is at `rtsp://localhost:8554/en-camera` (VLC, ffplay) and
`http://localhost:8888/en-camera/` (HLS). The simulator announces that URL
for the doorbell camera (`--camera-url`); the app plays it in milestone 7.

## Connect the app

In the app: Settings → Connection → My broker. The defaults match this
stack:

| Field | Value |
|---|---|
| Host | `localhost` (in LAN mode, the Mac's address) |
| Port | empty: 8884 (WSS) on the web, 8883 (TLS) on native |
| Path | `/mqtt` (web only) |
| Home | `demo-home` |
| Username | `demo-home.app` |
| Password | the `demo-home.app:` line of `secrets/credentials` |
| Extra CA | empty on this Mac; on a phone, see LAN mode below |

The password stays in memory, so after a restart the app shows the broker's
last-known devices and asks for it again. If the connection fails, the
form says why: the broker cannot be reached, its certificate is not
trusted, the login was refused, or the broker refused for another reason.
Use a local build (`flutter run -d chrome`, or `tool/build_web.sh` and a
local server) for the web app: browsers may block or prompt for a page
on the public internet that opens a connection to `localhost`.

### Checked end to end on macOS

`apps/glowhaus/integration_test/broker_tls_test.dart` runs inside the
real macOS app (its sandbox, its network entitlement, the keychain's trust
in the mkcert CA). It connects through the app's Connection settings code
to `mqtts://localhost:8883`, waits for all twelve devices, and switches the
reading light on and off, each change acked and reported back:

```bash
cd apps/glowhaus && flutter test integration_test/broker_tls_test.dart -d macos --dart-define=GLOWHAUS_TEST_PASSWORD="$(grep '^demo-home.app:' ../../infra/secrets/credentials | cut -d: -f2)"
```

Without the define it is skipped, so it never needs a secret in CI.

## Who may do what

The broker allows nothing by default (`allow_anonymous false`, and an ACL
file in which anything not listed is denied). Identity is the username, and
the ACL in [`mosquitto/acl.conf`](mosquitto/acl.conf) is written per
identity, not per pattern, so each client's rights are a block you can read:

```
user demo-home.app
topic readwrite glowhaus/demo-home/#

user demo-home.lr-lamp
topic write glowhaus/demo-home/lr-lamp/state
topic write glowhaus/demo-home/lr-lamp/ack
topic write glowhaus/demo-home/lr-lamp/availability
topic write glowhaus/demo-home/lr-lamp/info
topic read glowhaus/demo-home/lr-lamp/set
topic readwrite glowhaus/demo-home/discovery
```

| Identity | May | May not |
|---|---|---|
| `<homeId>.app` | everything under `glowhaus/<homeId>/` | touch any other home |
| `<homeId>.<deviceId>` | publish its own `state`, `ack`, `availability`, `info`; read its own `set`; publish and read the home's `discovery` | publish on another device's topics (a forged state, ack or info is dropped), subscribe to another device's `set`, touch any other home |

The last will goes through the same rules when the broker would publish
it (on an ungraceful disconnect), so a will on another device's
`availability` is never published. A denied publish is dropped silently
(MQTT 3.1.1 has no error for it); a denied subscription simply never
delivers.

The CI job `broker` proves this against the real thing:
[`packages/glowhaus_transport/test/broker_test.dart`](../packages/glowhaus_transport/test/broker_test.dart)
connects as `demo-home.lr-lamp` and shows that its forged state, ack and
info on `lr-ceiling` never reach the app, that it never receives `kt-motion`'s
commands, that nothing crosses into `other-home`, and that a will on another
device's availability is never published, while the same actions on its own
topics work. The same job runs `MqttTransport` over the real `mqtt_client` adapter
against the simulator container: all twelve devices are known, the offline
motion sensor included, the online ones with retained state, and a command
is acked and reflected in `state`. The job runs the file twice, over plain
MQTT and over TLS with `infra/certs/ca.crt` as the only trusted CA.
Locally, `GLOWHAUS_BROKER_MODE=wss` runs it over secure WebSocket too.

### Offline devices and a new app session

Fixed in protocol revision 1.1. Announces share the `discovery` topic, so
they cannot be retained, and an offline device cannot answer a query. Every
device therefore also keeps its descriptor on its own retained `info`
topic. An app that connects while `kt-motion` is unplugged still learns
what it is the moment it subscribes. See section 5.4 of
[`docs/protocol.md`](../docs/protocol.md).

### Adding a home

```bash
infra/scripts/make-users.sh my-home lamp-1 lamp-2 lock-1
```

appends a block for `my-home` (app user plus one user per device) to
`acl.conf`, creates passwords for the new users and keeps the existing ones.
Restart the broker afterwards. Run the simulator for it with
`--home my-home` and the same credentials file; it logs each device in as
`my-home.<deviceId>`.

## Plain, TLS or WSS

| Client | Endpoint |
|---|---|
| Native app, device simulator on the host | `mqtts://localhost:8883` (`MqttEndpoint.tcp`) |
| Web app | `wss://localhost:8884/mqtt` (`MqttEndpoint.webSocketSecure`) |
| Simulator container | `mqtt://mosquitto:1883`, inside the compose network |
| Tools on the host, CI | `mqtt://127.0.0.1:1883` |

Every port is published on the host's loopback address by default, so
nothing on the LAN can reach the broker or the camera. Plain 1883 stays on
loopback even in LAN mode. The simulator container uses it because the
compose network is private to the machine.

The iOS simulator and the Android emulator have their own trust stores, so
the mkcert CA is not trusted there. They can reach the broker without TLS:
`localhost:1883` from the iOS simulator and `10.0.2.2:1883` from the Android
emulator, both of which end on the host's loopback.

Check TLS from the host:

```bash
mosquitto_sub -h localhost -p 8883 --cafile infra/certs/ca.crt -u demo-home.app -P "$(grep '^demo-home.app:' infra/secrets/credentials | cut -d: -f2)" -t 'glowhaus/demo-home/+/availability' -v
```

## LAN mode: a real phone on the same Wi-Fi

LAN mode is opt-in. It publishes TLS 8883, WSS 8884 and the camera on every
interface of the Mac, and makes the certificate cover the Mac's LAN address.

```bash
infra/scripts/make-certs.sh --lan
```

```bash
GLOWHAUS_BIND=0.0.0.0 GLOWHAUS_CAMERA_HOST=192.168.1.20 docker compose -f infra/docker-compose.yml up -d
```

`--lan` adds the first address it finds on `en0` to `en2` and
`<LocalHostName>.local` to the certificate, and prints the address. Use that
address for `GLOWHAUS_CAMERA_HOST`, so the camera URL the doorbell announces
works from the phone. macOS may ask whether Docker may accept incoming
connections; allow it. Go back to loopback with a plain
`docker compose -f infra/docker-compose.yml up -d`.

The phone has to trust the mkcert CA. Its file is `infra/certs/ca.crt`, the
same as `"$(mkcert -CAROOT)/rootCA.pem"`. It is a development CA: anyone
holding its key, which stays on this Mac, can impersonate any site to a
device that trusts it. Remove it from the phone when you are done.

**Android, web app in Chrome.** Copy `ca.crt` to the phone. Open Settings,
then Security and privacy, More security settings, Encryption and
credentials, Install a certificate, CA certificate, and pick the file. The
wording differs a little between vendors; searching Settings for "CA
certificate" finds it. Chrome trusts user-installed CAs, so
`wss://192.168.1.20:8884/mqtt` works from the web build.

**Android, native Flutter app.** A user-installed CA is not enough. Dart's
TLS on Android reads only the read-only system store in
`/system/etc/security/cacerts` and ignores user certificates, and
`network_security_config` does not apply to Dart sockets. Hand the CA to the
app instead: `MqttEndpoint.trustedCertificatePem` adds it on top of the
system roots, and the app's Connection settings let
you paste it. Debug builds can also take it at build time:

```bash
flutter run --dart-define=GLOWHAUS_DEV_CA="$(base64 -i infra/certs/ca.crt)"
```

**iPhone.** AirDrop `ca.crt` to the phone and install the profile under
Settings, General, VPN and Device Management. Then turn on full trust for it
under Settings, General, About, Certificate Trust Settings. Safari and the
native app both use the system trust store, so nothing else is needed.

## Watchdog

The simulator writes a heartbeat every 5 seconds with the number of
connected devices. The compose healthcheck runs
`/simulator --check-health` on it, so the container is healthy only while at
least one device is connected, and `docker compose up --wait` returns only
then. If no device has been connected for two minutes, the simulator logs
why and exits with status 1, and `restart: on-failure` starts it again.
Change the limit with `--watchdog <seconds>`; `0` turns it off.

## Reset

```bash
docker compose -f infra/docker-compose.yml down -v
```

drops the broker's persistence (retained messages). Delete
`infra/secrets/` to start over with passwords, `infra/certs/` and
`infra/mosquitto/conf.d/tls.conf` for certificates.

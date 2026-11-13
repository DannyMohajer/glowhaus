# Infra: broker, simulator, test camera

Everything the app needs to run against a real network, on one machine:

| Service | Image | What | Ports on the host |
|---|---|---|---|
| `mosquitto` | `eclipse-mosquitto:2` | MQTT broker, password + ACL per identity | 1883 plain (loopback only), 8883 TLS, 8884 WSS |
| `simulator` | built from [`simulator/Dockerfile`](simulator/Dockerfile) | the demo home's twelve devices ([`../simulator`](../simulator)) | none |
| `camera` | `bluenviron/mediamtx:latest-ffmpeg` | an RTSP test pattern as the doorbell camera | 8554 RTSP, 8888 HLS |

## Setup on a Mac

```bash
brew install --cask docker
```

```bash
brew install mkcert mosquitto
```

Open Docker Desktop once so the daemon runs. `mosquitto` from Homebrew is
only for its `mosquitto_passwd` and `mosquitto_sub` / `mosquitto_pub` tools;
the broker itself runs in Docker. Then, once:

```bash
mkcert -install
```

That puts a certificate authority that exists only on this machine into your
keychain, so Safari, Chrome and native apps trust the broker's certificate.
It asks for your password; it is yours to run.

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
with mkcert and turns on the TLS and WSS listeners. Pass your Mac's LAN name
or IP as extra arguments for a phone on the same Wi-Fi:

```bash
infra/scripts/make-certs.sh "$(hostname)" 192.168.1.20
```

Without `make-certs.sh` the broker still runs, with plain MQTT on
`127.0.0.1:1883` only. That is what CI uses.

Check it from the host:

```bash
mosquitto_sub -h localhost -p 1883 -u demo-home.app -P "$(grep '^demo-home.app:' infra/secrets/credentials | cut -d: -f2)" -t 'glowhaus/demo-home/+/availability' -v
```

The camera stream is at `rtsp://localhost:8554/en-camera` (VLC, ffplay) and
`http://localhost:8888/en-camera/` (HLS). The simulator announces that URL
for the doorbell camera (`--camera-url`); the app plays it in milestone 7.

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
topic read glowhaus/demo-home/lr-lamp/set
topic readwrite glowhaus/demo-home/discovery
```

| Identity | May | May not |
|---|---|---|
| `<homeId>.app` | everything under `glowhaus/<homeId>/` | touch any other home |
| `<homeId>.<deviceId>` | publish its own `state`, `ack`, `availability`; read its own `set`; publish and read the home's `discovery` | publish on another device's topics (a forged state or ack is dropped), subscribe to another device's `set`, touch any other home |

The last will goes through the same rules when the broker would publish
it (on an ungraceful disconnect), so a will on another device's
`availability` is never published. A denied publish is dropped silently
(MQTT 3.1.1 has no error for it); a denied subscription simply never
delivers.

The CI job `broker` proves this against the real thing:
[`packages/glowhaus_transport/test/broker_test.dart`](../packages/glowhaus_transport/test/broker_test.dart)
connects as `demo-home.lr-lamp` and shows that its forged state and ack on
`lr-ceiling` never reach the app, that it never receives `kt-motion`'s
commands, that nothing crosses into `other-home`, and that a will on another
device's availability is never published, while the same actions on its own
topics work. The same job runs `MqttTransport` over the real `mqtt_client` adapter
against the simulator container: all twelve devices announce with retained
state, and a command is acked and reflected in `state`.

### Known gap: offline devices and a new app session

An announce is QoS 0 on the shared `discovery` topic and is not retained.
`kt-motion` is offline in the demo: it announced once when the simulator
started, then disconnected. An app that connects later gets its retained
`state` and `availability` but no answer to its query, so it never learns
what the device is. The in-memory demo does not show this because the app
connects before the devices start. The fix is a protocol change (a retained
per-device announce) and is proposed for the next step rather than slipped
into this one.

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

Plain 1883 is published on the host's loopback address only, so nothing on
the LAN can use it. The simulator container uses it because the compose
network is private to the machine. Everything that crosses a network uses
TLS.

The iOS simulator and the Android emulator do not share the Mac's keychain,
so the mkcert CA is not trusted there. They can reach the broker without
TLS: `localhost:1883` from the iOS simulator and `10.0.2.2:1883` from the
Android emulator, both of which end on the host's loopback. A real phone
needs TLS and the mkcert CA installed on it (`mkcert -CAROOT` has the file).

## Reset

```bash
docker compose -f infra/docker-compose.yml down -v
```

drops the broker's persistence (retained messages). Delete
`infra/secrets/` to start over with passwords, `infra/certs/` and
`infra/mosquitto/conf.d/tls.conf` for certificates.

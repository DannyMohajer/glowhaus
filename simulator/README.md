# Device simulator

A command-line tool that runs the demo home's twelve virtual devices against
a real MQTT broker. It is the `glowhaus_device` engine (`VirtualHome`) on the
`mqtt_client` adapter; the same engine runs the offline demo in the app,
the in-browser device panel and the devices tab of the two-tab demo.

```bash
dart run simulator/bin/simulator.dart --host localhost --no-tls
```

```bash
dart run simulator/bin/simulator.dart --help
```

Options: `--host`, `--port`, `--no-tls`, `--home`, `--credentials` (a
`username:password` file; each device logs in as `<home>.<deviceId>`),
`--username` / `--password` (one login for all, or `GLOWHAUS_PASSWORD`),
`--ca-file` (trust this CA too, for TLS without the keychain),
`--camera-url`, `--latency`, `--failure-rate`, `--timeout-rate`,
`--watchdog`, `--health-file`, `--check-health`.

Against the broker in `infra/`, from the host:

```bash
dart run simulator/bin/simulator.dart --credentials infra/secrets/credentials --ca-file infra/certs/ca.crt
```

`--ca-file` is only needed where the mkcert CA is not in the system store,
such as Linux or CI. On a Mac after `infra/scripts/make-certs.sh` it is
already trusted.

The devices behave as `docs/protocol.md` says a device must: clean session,
retained last will on `availability`, a retained `info` and `state`,
exactly one ack per command (a redelivered command gets the same ack
again), an announce on connect and on every discovery query. If the broker
is not there yet at start, or goes away later, the devices keep trying by
themselves (1 s, doubling to 30 s, with jitter). On Ctrl-C every device
publishes `offline` and disconnects cleanly.

A watchdog exits the process with status 1 when no device has been
connected for `--watchdog` seconds (default 120, `0` turns it off), so a
supervisor can restart it. `--health-file` writes a heartbeat every 5
seconds that `--check-health` reads; the container healthcheck in `infra/`
uses both.

The broker, with TLS, WebSocket and per-identity access control, is in
[`infra/`](../infra/README.md), which also builds this tool into a container
and runs it next to the broker.

# Device simulator

A command-line tool that runs the demo home's twelve virtual devices against
a real MQTT broker. It is the `glowhaus_device` engine (`VirtualHome`) on the
`mqtt_client` adapter; the same engine runs the offline demo in the app and
the in-browser device panel.

```bash
dart run simulator/bin/simulator.dart --host localhost --no-tls
```

```bash
dart run simulator/bin/simulator.dart --help
```

Options: `--host`, `--port`, `--no-tls`, `--home`, `--credentials` (a
`username:password` file; each device logs in as `<home>.<deviceId>`),
`--username` / `--password` (one login for all, or `GLOWHAUS_PASSWORD`),
`--camera-url`, `--latency`, `--failure-rate`, `--timeout-rate`.

Against the broker in `infra/`, from the host:

```bash
dart run simulator/bin/simulator.dart --credentials infra/secrets/credentials
```

The devices behave as `docs/protocol.md` says a device must: clean session,
retained last will on `availability`, retained `state`, exactly one ack per
command (a redelivered command gets the same ack again), an announce on
connect and on every discovery query. If the broker goes away the devices
come back by themselves (1 s, doubling to 30 s, with jitter). On Ctrl-C
every device publishes `offline` and disconnects cleanly.

The broker, with TLS, WebSocket and per-identity access control, is in
[`infra/`](../infra/README.md), which also builds this tool into a container
and runs it next to the broker.

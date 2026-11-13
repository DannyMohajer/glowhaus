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

Options: `--host`, `--port`, `--no-tls`, `--home`, `--username`,
`--password` (or `GLOWHAUS_PASSWORD`), `--latency`, `--failure-rate`,
`--timeout-rate`.

The devices behave as `docs/protocol.md` says a device must: clean session,
retained last will on `availability`, retained `state`, exactly one ack per
command (a redelivered command gets the same ack again), an announce on
connect and on every discovery query. On Ctrl-C every device publishes
`offline` and disconnects cleanly.

The broker, with TLS, WebSocket and per-home access control, comes with
`infra/` (milestone 3, step 4).

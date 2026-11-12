# Glowhaus

An open-source smart home demo app built with Flutter. It shows real-time
device control with optimistic UI, a capability-based device model, a
documented MQTT protocol, adaptive phone / tablet layouts, light and dark
themes with a swappable accent, and English, Persian (RTL) and Turkish.

> Status: milestone 1 (foundation) is in progress. See the [roadmap](docs/roadmap.md).

## Screenshots

_Coming with the first UI milestone._

## Features

- Rooms, devices and a dashboard for a seeded demo home
- Lights (on/off, dimmer, RGB), multi-channel switches, curtains, thermostat,
  outlets with live power, door lock, sensors
- Optimistic control with pending state and rollback on failure or timeout
- Simulated transport with adjustable latency and failure rate
- Phone and tablet / desktop layouts from one set of routes
- Light / dark / system theme, runtime accent colour, reduced motion
- English, Persian (RTL), Turkish with live switching
- Design system package with a Widgetbook catalog

Coming:

- Scenes UI (milestone 2)
- Real MQTT transport, docker-compose broker and device simulator (milestone 3)
- Scenarios, automations, timers (milestone 4)
- Multiple homes, users and roles, add-device wizard (milestone 5)
- Offline / local control (milestone 6)
- Cameras: ONVIF, RTSP live view, PTZ (milestone 7)

## Repository layout

```
apps/glowhaus/            Flutter app (web, android, macos, ios)
packages/
  glowhaus_domain/        pure Dart: models, capabilities, protocol
  glowhaus_transport/     Transport interface + SimulatedTransport
  glowhaus_ui/            design system: tokens, themes, components
widgetbook/               Widgetbook catalog of the design system
simulator/                device simulator CLI (milestone 3)
infra/                    docker-compose (milestone 3)
docs/                     architecture, protocol, roadmap
```

## Running

Requires Flutter 3.47 or newer.

```bash
dart pub get
```

```bash
cd apps/glowhaus && flutter run -d chrome
```

Workspace scripts (analyze, test, codegen) run through melos:

```bash
dart run melos run analyze
```

```bash
dart run melos run test
```

## Architecture

UI → bloc → repository → `Transport`. The UI never knows whether a device is
simulated, behind an MQTT broker, or on the local network. Details and
diagrams: [docs/architecture.md](docs/architecture.md).

## Protocol

Glowhaus defines its own small MQTT protocol, specified so that anyone can
build a compatible device: [docs/protocol.md](docs/protocol.md).

## License

[MIT](LICENSE)

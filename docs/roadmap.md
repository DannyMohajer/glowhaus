# Roadmap

## 1. Foundation (done)

Monorepo, design system + Widgetbook, capability-based domain model, protocol
spec, `SimulatedTransport` with a seeded demo home, core screens (intro,
dashboard, room, device detail, settings), optimistic UI, EN/FA/TR, CI.

## 2. Device controls and scenes UI

All device controls polished; scenes UI.

## 3. Real MQTT (done)

Protocol revision 1.1 (retained per-device `info`), revision 1.2 (`leakSensor`), a pure Dart device
engine, `MqttTransport` (TLS on native, WSS on web) with acks, timeouts and
reconnect, docker compose (Mosquitto with per-identity ACLs, the device
simulator with a watchdog, a MediaMTX RTSP test camera), Connection settings
for a real broker, the devices panel with live MQTT traffic (`#/demo`) and
the two-tab demo over `BroadcastChannel`.

Optional, later: the demo over the internet through a hosted broker, with a
public demo identity limited by ACL to demo homes and a random home per
visitor.

## 4. Scenarios and automations

Scenarios, automations (time and sensor triggers), timers.

## 5. Homes, people, onboarding

Multiple homes, users / roles / sharing, add-device wizard (QR + Wi-Fi
provisioning, simulated).

## 6. Offline / local mode

UDP discovery + local WebSocket on native; simulated on web.

## 7. Cameras

ONVIF discovery, RTSP live view (media_kit), PTZ, snapshots, multi-camera grid
on native; sample video on web.

## 8. Polish

README GIFs, performance, accessibility pass, portfolio embed.

# Roadmap

## 1. Foundation (done)

Monorepo, design system + Widgetbook, capability-based domain model, protocol
spec, `SimulatedTransport` with a seeded demo home, core screens (welcome,
dashboard, room, device detail, settings), optimistic UI, EN/FA/TR, CI.

## 2. Device controls and scenes UI

All device controls polished; scenes UI.

## 3. Real MQTT

`MqttTransport` (TCP on native, WSS on web), docker-compose (Mosquitto + Dart
device simulator + MediaMTX RTSP test camera), acks / timeouts / reconnect,
two-tab live demo, in-browser device panel for the portfolio.

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

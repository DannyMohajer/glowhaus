# Glowhaus protocol, version 1

This document specifies how Glowhaus apps and devices talk over MQTT. It is
written so that you can build a compatible device (or app) without reading any
Glowhaus source code.

The key words MUST, SHOULD and MAY are used as in RFC 2119.

## 1. Overview

- Transport: MQTT 3.1.1 or 5. Payloads are UTF-8 JSON objects.
- Every payload carries the protocol version: `"v": 1`.
- A **home** contains **devices**. A device exposes **capabilities**
  (`onOff`, `brightness`, ...). State and commands are both expressed as
  values keyed by capability.
- Apps send **commands**. A device answers each command with an **ack** and
  publishes its resulting **state**. State is the source of truth; the ack only
  says whether the command was accepted.

```
App                         Broker                        Device
 |  set {commandId, set}  ->  |  ->                          |
 |                            |  <-  ack {commandId, ok}     |
 |                            |  <-  state {...} (retained)  |
```

## 2. Identifiers

| Identifier | Format | Example |
|---|---|---|
| `homeId` | `[a-z0-9][a-z0-9_-]{0,31}` | `demo-home` |
| `deviceId` | `[a-z0-9][a-z0-9_-]{0,31}`, unique within the home, not `discovery` | `lr-lamp` |
| capability `id` | `[a-zA-Z][a-zA-Z0-9]{0,31}`, unique within the device | `onOff`, `ch2` |
| `commandId` | `[A-Za-z0-9_-]{1,64}`, unique per command (UUID or ULID recommended) | `01JCK3V9M2Q8` |

Timestamps (`ts`) are integer milliseconds since the Unix epoch, UTC.

## 3. Topics

| Topic | Direction | QoS | Retained | Purpose |
|---|---|---|---|---|
| `glowhaus/{homeId}/discovery` | both | 1 | no | Device announcements and app queries |
| `glowhaus/{homeId}/{deviceId}/set` | app to device | 1 | **no** | Commands |
| `glowhaus/{homeId}/{deviceId}/ack` | device to app | 1 | no | Command results |
| `glowhaus/{homeId}/{deviceId}/state` | device to app | 1 | **yes** | Full current state |
| `glowhaus/{homeId}/{deviceId}/availability` | device to app | 1 | **yes** | Online / offline (last will) |

Typical subscriptions:

- App: `glowhaus/{homeId}/discovery` and `glowhaus/{homeId}/+/state`, `.../+/ack`, `.../+/availability`.
- Device: `glowhaus/{homeId}/{deviceId}/set` and `glowhaus/{homeId}/discovery`.

Rules:

- `set` MUST NEVER be published with the retain flag. A device MUST ignore any
  `set` message that arrives flagged as retained.
- Devices MUST connect with a clean session (clean start, no session expiry)
  so commands sent while the device was offline are not delivered later. A door
  must not unlock ten minutes after someone tapped the button.

## 4. Common payload rules

- Every payload is a JSON object with `"v": 1`.
- Receivers MUST ignore unknown fields and unknown capability kinds.
- A receiver that gets a payload with a higher `v` than it supports MUST NOT
  act on it. For a command, the device replies with error `unsupported_version`.
- Additions that old receivers can safely ignore (new optional fields, new
  capability kinds, new error codes) do not change `v`. Anything else does.

## 5. Discovery

Topic: `glowhaus/{homeId}/discovery`. Messages have a `type`.

### 5.1 `announce` (device)

A device MUST publish an announce after connecting, whenever its descriptor
changes, and in response to a query.

```json
{
  "v": 1,
  "type": "announce",
  "ts": 1794500000000,
  "device": {
    "id": "lr-lamp",
    "type": "light",
    "name": "Floor lamp",
    "manufacturer": "Glowhaus Labs",
    "model": "GL-RGB-1",
    "firmware": "1.0.0",
    "roomHint": "living-room",
    "capabilities": [
      { "id": "onOff", "kind": "onOff" },
      { "id": "brightness", "kind": "brightness" },
      { "id": "color", "kind": "color" },
      { "id": "colorTemperature", "kind": "colorTemperature",
        "config": { "minKelvin": 2200, "maxKelvin": 6500 } }
    ]
  }
}
```

| Field | Required | Notes |
|---|---|---|
| `device.id` | yes | Same as `{deviceId}` in topics |
| `device.type` | yes | `light`, `switch`, `curtain`, `thermostat`, `outlet`, `lock`, `sensor`, `camera`. A presentation hint (icon, grouping). Unknown values are shown as a generic device |
| `device.name` | yes | Default display name; the app may let the user rename |
| `device.capabilities` | yes | At least one. See section 9 |
| `capabilities[].id` | yes | Key used in `state` and `set` |
| `capabilities[].kind` | yes | What the capability is |
| `capabilities[].label` | no | Display label, e.g. per channel on a multi-gang switch |
| `capabilities[].config` | no | Static limits and options, per kind |
| `manufacturer`, `model`, `firmware` | no | Informational |
| `roomHint` | no | Suggested room id. Room assignment is owned by the app |

When a capability's `id` equals its `kind`, that is simply the convention for
"the only one of its kind on this device".

### 5.2 `query` (app)

Announces are not retained (one topic is shared by all devices), so an app
that has just connected asks for them:

```json
{ "v": 1, "type": "query", "ts": 1794500000000 }
```

Every device MUST answer with an `announce`, after a random delay of 0 to
500 ms to avoid a burst.

### 5.3 `bye` (device)

Published when a device is removed from the home (factory reset, unpairing):

```json
{ "v": 1, "type": "bye", "ts": 1794500000000, "deviceId": "lr-lamp" }
```

The device MUST also clear its retained messages by publishing empty retained
payloads to its `state` and `availability` topics.

## 6. Availability

Topic: `glowhaus/{homeId}/{deviceId}/availability`, retained.

- On connect the device publishes `{ "v": 1, "status": "online", "ts": ... }`.
- The device registers a **last will** on the same topic, retained, QoS 1:
  `{ "v": 1, "status": "offline" }` (`ts` is optional, a will cannot know it).
- Before a clean disconnect the device publishes the offline payload itself.

An app treats a device as `unknown` until it has received an availability
message, then `online` or `offline`. State from an offline device is shown as
last known.

## 7. State

Topic: `glowhaus/{homeId}/{deviceId}/state`, retained.

```json
{
  "v": 1,
  "ts": 1794500000000,
  "state": {
    "onOff": { "on": true },
    "brightness": { "level": 80 },
    "color": { "hue": 28, "saturation": 90 },
    "colorTemperature": { "kelvin": 2700 }
  }
}
```

- `state` is keyed by capability `id`. Each value is that capability's state
  object (section 9).
- A state message is always a **full snapshot** of every capability, never a
  delta. A receiver can replace what it has.
- An app MUST ignore fields it does not know inside a capability's state, and
  entries whose capability id or kind it does not know.
- A device MUST publish state after connecting and whenever any value changes,
  whatever the cause (command, physical button, schedule).
- Fast-changing values (power, position while moving) SHOULD be limited to
  about one message per second.

## 8. Commands and acks

### 8.1 `set`

Topic: `glowhaus/{homeId}/{deviceId}/set`.

```json
{
  "v": 1,
  "commandId": "01JCK3V9M2Q8",
  "ts": 1794500000000,
  "set": {
    "onOff": { "on": true },
    "brightness": { "level": 60 }
  }
}
```

- `set` is keyed by capability `id` and contains only the fields to change.
  Only writable fields (section 9) may appear.
- `ts` is required. A device MUST reject a command whose `ts` is more than
  10 seconds older than its own clock with error `expired`, without applying
  it. Devices therefore need a synchronized clock (SNTP or equivalent).
- A command is **atomic**: the device validates everything first and either
  applies all of it or none of it. One unknown capability id or one bad value
  rejects the whole command.
- A device MUST remember at least the last 8 `commandId`s it handled. If one
  arrives again (QoS 1 redelivery) it re-sends the same ack and does not apply
  the command twice.

### 8.2 `ack`

Topic: `glowhaus/{homeId}/{deviceId}/ack`.

Success:

```json
{ "v": 1, "commandId": "01JCK3V9M2Q8", "ok": true, "ts": 1794500000120 }
```

Failure:

```json
{
  "v": 1,
  "commandId": "01JCK3V9M2Q8",
  "ok": false,
  "ts": 1794500000120,
  "error": { "code": "out_of_range", "message": "level must be 0..100" }
}
```

- The device MUST ack every command it receives, within 2 seconds.
- `ok: true` means *accepted*. For actions that take time (a curtain moving, a
  lock bolt turning) the device acks when it starts and reports progress and
  the final result through `state`.
- After a successful command the device MUST publish its new state.
- `error.message` is for developers and logs. Apps show their own localized
  text based on `error.code`.

| `error.code` | Meaning |
|---|---|
| `invalid_payload` | Not valid JSON, or required fields missing or of the wrong type |
| `unsupported_version` | `v` is higher than the device supports |
| `unsupported_capability` | A key in `set` is not a capability id of this device. The whole command is rejected |
| `read_only` | A field in `set` is not writable |
| `out_of_range` | A value is outside the allowed range or not an allowed option |
| `busy` | The device cannot take the command right now; try again |
| `hardware_fault` | The device tried and failed (jammed lock, blocked motor) |
| `not_allowed` | Refused by device policy (child lock, local override) |
| `expired` | `ts` is more than 10 s in the past; the command was not applied |

Apps MUST treat unknown codes as a generic failure.

### 8.3 Command lifecycle (app side)

```
            ack ok:true
pending ─────────────────▶ acked
   │        ack ok:false
   ├─────────────────────▶ failed
   │        no ack within timeout (default 5 s)
   └─────────────────────▶ timedOut
```

- While `pending`, an app MAY show the requested value optimistically.
- An ack does **not** end the optimistic display. The app keeps showing the
  requested value until a `state` message arrives whose values match what the
  command asked for; only then is the reported state shown again. If no
  matching state arrives within 10 s of the ack, the app drops the optimistic
  value and shows whatever the device last reported.
- On `failed` or `timedOut` it MUST fall back to the last state the device
  reported.
- Acks are visible to every app in the home. An app ignores acks whose
  `commandId` it did not send.

## 9. Capabilities

Fields marked **W** may appear in `set`. All others are read-only.
Percentages are integers 0 to 100.

### `onOff`
| Field | Type | | Notes |
|---|---|---|---|
| `on` | bool | W | |

### `brightness`
| Field | Type | | Notes |
|---|---|---|---|
| `level` | int 0..100 | W | Percent. Independent of `onOff`: setting a level does not turn the light on |

### `color`
| Field | Type | | Notes |
|---|---|---|---|
| `hue` | int 0..359 | W | Degrees |
| `saturation` | int 0..100 | W | Percent |

Brightness is the `brightness` capability, not part of colour.

### `colorTemperature`
| Field | Type | | Notes |
|---|---|---|---|
| `kelvin` | int | W | Within `config.minKelvin`..`config.maxKelvin` |

Config: `minKelvin`, `maxKelvin` (int, required).

### `position`
For curtains, blinds and shutters. 0 is fully closed, 100 fully open.

| Field | Type | | Notes |
|---|---|---|---|
| `position` | int 0..100 | | Current position |
| `target` | int 0..100 | W | Position it is moving to. Equals `position` when at rest |
| `moving` | bool | | True while the motor is running |
| `stop` | `true` | W | Write-only. Stops movement; `target` becomes the current position. Never appears in state |

A long-running device acks when it starts moving and then publishes state
(about once per second) with `moving: true` and the advancing `position` until
it arrives, followed by a final state with `moving: false`.

### `thermostat`
| Field | Type | | Notes |
|---|---|---|---|
| `setpoint` | number | W | Degrees Celsius, within config limits, multiple of `config.step` |
| `mode` | `off` \| `heat` \| `cool` \| `auto` | W | One of `config.modes` |
| `fan` | `auto` \| `low` \| `medium` \| `high` | W | One of `config.fanModes`. Omitted if the device has no fan control |
| `action` | `idle` \| `heating` \| `cooling` | | What the device is doing right now |

Config: `minSetpoint`, `maxSetpoint`, `step` (number, required), `modes`
(required), `fanModes` (optional). The measured room temperature is a separate
`temperatureSensor` capability on the same device.

### `powerMeter`
| Field | Type | | Notes |
|---|---|---|---|
| `watts` | number | | Instantaneous power |
| `energyKwh` | number | | Optional. Cumulative energy |

### `lock`
| Field | Type | | Notes |
|---|---|---|---|
| `locked` | bool | W | |
| `jammed` | bool | | Optional. True if the bolt could not complete its travel |

### `temperatureSensor`
| Field | Type | | Notes |
|---|---|---|---|
| `celsius` | number | | |

### `humiditySensor`
| Field | Type | | Notes |
|---|---|---|---|
| `percent` | number 0..100 | | Relative humidity |

### `motionSensor`
| Field | Type | | Notes |
|---|---|---|---|
| `motion` | bool | | Motion currently detected |
| `lastMotionAt` | int (ts) | | Optional |

### `contactSensor`
| Field | Type | | Notes |
|---|---|---|---|
| `open` | bool | | |

### `camera`
| Field | Type | | Notes |
|---|---|---|---|
| `streaming` | bool | | Whether the stream is currently available |

Config: `streams`, a list of `{ "protocol": "rtsp" \| "hls", "url": "..." }`,
and optional `snapshotUrl`. Pan/tilt/zoom commands will be added as optional
writable fields in a later revision of this document.

## 10. Examples by device type

Each example shows the `device` object from the announce, a `state` payload,
and a typical command. Envelope fields (`v`, `ts`, `type`) are omitted from
descriptors for brevity.

### Light (on/off only)

```json
{ "id": "br-reading", "type": "light", "name": "Reading light",
  "capabilities": [ { "id": "onOff", "kind": "onOff" } ] }
```
```json
{ "v": 1, "ts": 1794500000000, "state": { "onOff": { "on": false } } }
```
```json
{ "v": 1, "commandId": "c-1001", "ts": 1794500001000,
  "set": { "onOff": { "on": true } } }
```

### Dimmer light

```json
{ "id": "lr-ceiling", "type": "light", "name": "Ceiling light",
  "capabilities": [
    { "id": "onOff", "kind": "onOff" },
    { "id": "brightness", "kind": "brightness" } ] }
```
```json
{ "v": 1, "ts": 1794500000000,
  "state": { "onOff": { "on": true }, "brightness": { "level": 70 } } }
```
```json
{ "v": 1, "commandId": "c-1002", "ts": 1794500001000,
  "set": { "brightness": { "level": 35 } } }
```

### RGB light

Descriptor and state: see sections 5.1 and 7.

```json
{ "v": 1, "commandId": "c-1003", "ts": 1794500001000,
  "set": { "onOff": { "on": true }, "color": { "hue": 210, "saturation": 80 } } }
```

### Multi-channel switch

Three capabilities of the same kind, told apart by `id`.

```json
{ "id": "kt-switch", "type": "switch", "name": "Kitchen switch",
  "capabilities": [
    { "id": "ch1", "kind": "onOff", "label": "Ceiling" },
    { "id": "ch2", "kind": "onOff", "label": "Counter" },
    { "id": "ch3", "kind": "onOff", "label": "Hood" } ] }
```
```json
{ "v": 1, "ts": 1794500000000,
  "state": { "ch1": { "on": true }, "ch2": { "on": false }, "ch3": { "on": false } } }
```
```json
{ "v": 1, "commandId": "c-1004", "ts": 1794500001000,
  "set": { "ch2": { "on": true } } }
```

### Curtain

```json
{ "id": "lr-curtain", "type": "curtain", "name": "Curtain",
  "capabilities": [ { "id": "position", "kind": "position" } ] }
```
```json
{ "v": 1, "ts": 1794500000000,
  "state": { "position": { "position": 40, "target": 100, "moving": true } } }
```
```json
{ "v": 1, "commandId": "c-1005", "ts": 1794500001000,
  "set": { "position": { "target": 100 } } }
```
```json
{ "v": 1, "commandId": "c-1006", "ts": 1794500003000,
  "set": { "position": { "stop": true } } }
```

### Thermostat / AC

```json
{ "id": "lr-thermostat", "type": "thermostat", "name": "Thermostat",
  "capabilities": [
    { "id": "thermostat", "kind": "thermostat",
      "config": { "minSetpoint": 16, "maxSetpoint": 30, "step": 0.5,
                  "modes": ["off", "heat", "cool", "auto"],
                  "fanModes": ["auto", "low", "medium", "high"] } },
    { "id": "temperatureSensor", "kind": "temperatureSensor" } ] }
```
```json
{ "v": 1, "ts": 1794500000000,
  "state": {
    "thermostat": { "setpoint": 22.5, "mode": "heat", "fan": "auto", "action": "heating" },
    "temperatureSensor": { "celsius": 20.8 } } }
```
```json
{ "v": 1, "commandId": "c-1007", "ts": 1794500001000,
  "set": { "thermostat": { "setpoint": 24, "mode": "cool" } } }
```

### Outlet with power metering

```json
{ "id": "kt-outlet", "type": "outlet", "name": "Coffee machine",
  "capabilities": [
    { "id": "onOff", "kind": "onOff" },
    { "id": "powerMeter", "kind": "powerMeter" } ] }
```
```json
{ "v": 1, "ts": 1794500000000,
  "state": { "onOff": { "on": true }, "powerMeter": { "watts": 1180.5, "energyKwh": 42.7 } } }
```
```json
{ "v": 1, "commandId": "c-1008", "ts": 1794500001000,
  "set": { "onOff": { "on": false } } }
```

### Door lock

```json
{ "id": "en-lock", "type": "lock", "name": "Front door",
  "capabilities": [ { "id": "lock", "kind": "lock" } ] }
```
```json
{ "v": 1, "ts": 1794500000000, "state": { "lock": { "locked": true, "jammed": false } } }
```
```json
{ "v": 1, "commandId": "c-1009", "ts": 1794500001000,
  "set": { "lock": { "locked": false } } }
```

A jammed bolt is reported as an ack with `hardware_fault` if it is detected
immediately, otherwise through `jammed: true` in state.

### Temperature and humidity sensor

```json
{ "id": "br-climate", "type": "sensor", "name": "Bedroom climate",
  "capabilities": [
    { "id": "temperatureSensor", "kind": "temperatureSensor" },
    { "id": "humiditySensor", "kind": "humiditySensor" } ] }
```
```json
{ "v": 1, "ts": 1794500000000,
  "state": { "temperatureSensor": { "celsius": 21.4 }, "humiditySensor": { "percent": 46 } } }
```

Sensors have no writable fields. Any command gets `read_only`.

### Motion sensor

```json
{ "id": "kt-motion", "type": "sensor", "name": "Kitchen motion",
  "capabilities": [ { "id": "motionSensor", "kind": "motionSensor" } ] }
```
```json
{ "v": 1, "ts": 1794500000000,
  "state": { "motionSensor": { "motion": true, "lastMotionAt": 1794499999000 } } }
```

### Door sensor

```json
{ "id": "en-door", "type": "sensor", "name": "Front door sensor",
  "capabilities": [ { "id": "contactSensor", "kind": "contactSensor" } ] }
```
```json
{ "v": 1, "ts": 1794500000000, "state": { "contactSensor": { "open": false } } }
```

### Camera

```json
{ "id": "en-camera", "type": "camera", "name": "Doorbell camera",
  "capabilities": [
    { "id": "camera", "kind": "camera",
      "config": { "streams": [ { "protocol": "rtsp", "url": "rtsp://192.168.1.40:8554/door" } ] } } ] }
```
```json
{ "v": 1, "ts": 1794500000000, "state": { "camera": { "streaming": true } } }
```

## 11. Device implementation checklist

1. Connect with a clean session and a retained last will of
   `{"v":1,"status":"offline"}` on your `availability` topic.
2. Publish `online` to `availability` (retained).
3. Publish an `announce` to `discovery`.
4. Publish your full `state` (retained).
5. Subscribe to your `set` topic and to `discovery`.
6. On `query`: wait 0 to 500 ms, then announce again.
7. On `set`: ignore it if retained; reject with `expired` if `ts` is older
   than 10 s; validate everything, apply all or nothing, ack within 2 s, then
   publish state. Re-ack duplicate `commandId`s without re-applying.
8. On any local change: publish state.
9. On removal: publish `bye`, then empty retained payloads to `state` and
   `availability`.

## 12. Security

The protocol itself carries no authentication; it relies on the broker.
A real deployment MUST provide:

- **Encryption**: MQTT over TLS (port 8883) for native clients and devices,
  MQTT over secure WebSocket (WSS) for web clients. No plaintext listeners.
- **Per-home credentials**: every app session and every device authenticates
  with credentials that are scoped to one home (username/password or client
  certificate). Credentials are never shared between homes.
- **Topic ACLs per `homeId`**: a client may only touch `glowhaus/{homeId}/#`
  for its own home. Within that, a device may publish only to its own `state`,
  `ack`, `availability` and to `discovery`, and subscribe only to its own
  `set` and to `discovery`. Apps may publish to `set` and `discovery` and
  subscribe to the rest.

Broker configuration implementing this ships with milestone 3. Until then the
app runs against the in-memory simulation only. The public demo broker will be
a throwaway instance with no secrets and no real devices.

## 13. In the Glowhaus codebase

- Topic strings are built and parsed only by `TopicCodec` in
  `packages/glowhaus_domain`.
- The payloads above map one to one to the protocol models in the same package.
- `SimulatedTransport` does not use MQTT, but its devices follow the same
  rules (atomic commands, error codes, state after ack), so behaviour seen in
  the simulation matches a compliant device.

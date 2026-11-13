# Glowhaus protocol, version 1 (revision 1.1)

This document specifies how Glowhaus apps and devices talk over MQTT. It is
written so that you can build a compatible device (or app) without reading any
Glowhaus source code.

The key words MUST, SHOULD and MAY are used as in RFC 2119.

| Revision | Change |
|---|---|
| 1.0 | First published version |
| 1.1 | Retained per-device `info` topic (section 5.4), so an app learns every device as soon as it subscribes, offline ones included. Additive: `v` stays `1` (section 4), and a 1.0 app or device simply never uses the topic |

## 1. Overview

- Transport: **MQTT 3.1.1**. Payloads are UTF-8 JSON objects. An MQTT 5
  broker works too, but nothing in this protocol uses MQTT 5 features: there
  are no user properties, no message expiry, no shared subscriptions. The
  `ts` field does what message expiry would (section 8.1), so the protocol
  behaves the same on every broker.
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
| `glowhaus/{homeId}/discovery` | both | 0 | no | Device announcements and app queries |
| `glowhaus/{homeId}/{deviceId}/set` | app to device | 1 | **no** | Commands |
| `glowhaus/{homeId}/{deviceId}/ack` | device to app | 1 | no | Command results |
| `glowhaus/{homeId}/{deviceId}/state` | device to app | 1 | **yes** | Full current state |
| `glowhaus/{homeId}/{deviceId}/availability` | device to app | 1 | **yes** | Online / offline (last will) |
| `glowhaus/{homeId}/{deviceId}/info` | device to app | 1 | **yes** | What the device is (1.1, section 5.4) |

QoS, in detail:

- `set` and `ack` are QoS 1 in both the publish and the subscription. A
  command may therefore be delivered twice; section 8.1 says how a device
  stays idempotent. An ack may be delivered twice; an app ignores an ack for
  a command that is no longer pending.
- `state`, `availability` and `info` are QoS 1 and retained, so a client
  that connects later gets the latest value at once and a lost publish is
  retried.
- `discovery` is QoS 0: best effort. Announces repeat (on connect, on every
  query), so losing one costs nothing; a lost query is answered by the next
  one. Subscribe with QoS 0 as well; a subscription at a higher QoS gains
  nothing because the broker delivers at the lower of the two.
- A broker delivers every message at the lower of the publish QoS and the
  subscription QoS. Subscribing to `state` at QoS 0 would silently make it
  best effort; apps MUST subscribe to `set`, `ack`, `state` and
  `availability` at QoS 1.
- QoS 2 is never used.

Typical subscriptions:

- App: `glowhaus/{homeId}/+/info` first, then `.../+/state`, `.../+/ack`, `.../+/availability` and `glowhaus/{homeId}/discovery`.
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
| `device.nameKey` | no | Translation key for the default `name` (e.g. `demo.floorLamp`). An app that knows the key shows its translation; otherwise it shows `name`. Once the user renames the device the app drops the key and shows the new name as typed, in every language |
| `device.capabilities` | yes | At least one. See section 9 |
| `capabilities[].id` | yes | Key used in `state` and `set` |
| `capabilities[].kind` | yes | What the capability is |
| `capabilities[].label` | no | Display label, e.g. per channel on a multi-gang switch |
| `capabilities[].labelKey` | no | Translation key for the default `label`, same rules as `nameKey` |
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

Since revision 1.1 an app learns 1.1 devices from their retained `info`
(section 5.4), which also covers devices that are offline right now and so
cannot answer. An app still sends the query, for 1.0 devices.

### 5.3 `bye` (device)

Published when a device is removed from the home (factory reset, unpairing):

```json
{ "v": 1, "type": "bye", "ts": 1794500000000, "deviceId": "lr-lamp" }
```

The device MUST also clear its retained messages by publishing empty retained
payloads to its `state`, `availability` and (1.1) `info` topics.

### 5.4 `info` (device, revision 1.1)

Topic: `glowhaus/{homeId}/{deviceId}/info`, QoS 1, retained. The `device`
object is exactly the one an announce carries (section 5.1):

```json
{ "v": 1, "ts": 1794500000000, "device": { "id": "lr-lamp", "type": "light", "name": "Floor lamp", "capabilities": [ { "id": "onOff", "kind": "onOff" } ] } }
```

Why: announces share one topic, so they cannot be retained, and a device
that is offline cannot answer a query. Without `info` an app that connects
while a device is unplugged gets its retained `state` and `availability` but
never learns what the device is.

- A 1.1 device MUST publish `info` after every connect, before its
  `availability` and `state`, and again whenever its descriptor changes.
  It keeps announcing as well (sections 5.1 and 5.2), for 1.0 apps.
- `device.id` MUST equal `{deviceId}` in the topic. An app MUST ignore an
  `info` whose `device.id` differs.
- An app subscribes to `+/info` before `state` and `availability`, so the
  broker's retained `info` arrives first, and treats an `info` exactly like
  an announce. An `info` or announce that repeats a descriptor the app
  already has is not news.
- An empty retained payload on `info` (a removed device clearing it, section
  5.3) means the device is gone, the same as `bye`.

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
  This is the protocol's only command expiry. It is deliberately not the
  MQTT 5 message-expiry property, which MQTT 3.1.1 lacks and which would
  make a door unlock late on one broker and not on another.
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
   ├─────────────────────▶ timedOut
   │        the app has no broker connection
   └─────────────────────▶ unreachable
```

`unreachable` is app-side only: the app was not connected when it wanted to
send, or lost the broker while the command was pending. The device never saw
such a command (a lost link cannot deliver a QoS 1 publish that the app had
not finished sending, and anything the broker already had is answered by an
ack that the app, once reconnected, no longer waits for). The app rolls back
exactly as for `failed`.

- While `pending`, an app MAY show the requested value optimistically.
- An ack does **not** end the optimistic display. The app keeps showing the
  requested value until a `state` message arrives whose values match what the
  command asked for; only then is the reported state shown again. If no
  matching state arrives within 10 s of the ack, the app drops the optimistic
  value and shows whatever the device last reported.
- On `failed`, `timedOut` or `unreachable` it MUST fall back to the last
  state the device reported.
- Losing the broker says nothing about the devices. The app keeps showing the
  last reported state and availability of every device and marks the
  *connection* as reconnecting; a device becomes `offline` only through its
  own `availability` topic. On reconnect the app re-subscribes and re-queries;
  the retained `state` and `availability` it then receives replace whatever
  it was showing, including values of commands acked just before the link
  dropped.
- Acks are visible to every app in the home. An app ignores acks whose
  `commandId` it did not send.
- A device may apply a command after the app gave up on it (the ack was
  late or lost). The app has already rolled back; when a `state` then shows
  the requested values within a short window (30 s) it MAY tell the user
  the change happened after all, but it MUST NOT re-apply the optimistic
  value. A newer command for the same device ends that window.

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
| `lastActiveMode` | `heat` \| `cool` \| `auto` | | Optional. The last mode other than `off`; what an app's on/off switch turns back on. The device keeps it across restarts, so every app resumes the same mode |

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
2. Publish your `info` (retained, 1.1).
3. Publish `online` to `availability` (retained).
4. Publish your full `state` (retained).
5. Publish an `announce` to `discovery`.
6. Subscribe to your `set` topic and to `discovery`.
7. On `query`: wait 0 to 500 ms, then announce again.
8. On `set`: ignore it if retained; reject with `expired` if `ts` is older
   than 10 s; validate everything, apply all or nothing, ack within 2 s, then
   publish state. Re-ack duplicate `commandId`s without re-applying.
9. On any local change: publish state.
10. On removal: publish `bye`, then empty retained payloads to `state`,
    `availability` and `info`.
11. If the broker is not there, at boot or after a drop, keep trying with
    growing pauses. A device has nobody to ask for help.

## 12. Security

The protocol itself carries no authentication; it relies on the broker.
A real deployment MUST provide:

- **Encryption**: MQTT over TLS (port 8883) for native clients and devices,
  MQTT over secure WebSocket (WSS) for web clients. No plaintext listener
  that is reachable from a network.
- **One identity per client**: every app session and every device
  authenticates as its own identity (username/password or client
  certificate), scoped to one home. Nothing is shared between homes.
- **Topic ACLs bound to identity**, not to patterns a client fills in:
  - the app identity of a home may read and write `glowhaus/{homeId}/#`;
  - a device identity may publish only its own `state`, `ack`,
    `availability` and `info`, subscribe only to its own `set`, and publish and
    subscribe on the home's `discovery`;
  - nothing else. In particular a device cannot forge another device's
    state, acks or info, cannot read another device's commands, and no identity
    reaches another home.
- The broker MUST apply the same rules to the last will, so a will on
  another device's `availability` is never published.

The reference setup in `infra/` is Mosquitto 2 with a password file and an
ACL file written per identity: usernames are `{homeId}.app` and
`{homeId}.{deviceId}`. Its README shows the ACL, and CI runs a test that a
device identity cannot publish to another device's topics. The public demo
broker (if any) is a throwaway instance with no secrets and no real devices.

## 13. In the Glowhaus codebase

- Topic strings are built and parsed only by `TopicCodec` in
  `packages/glowhaus_domain`.
- `packages/glowhaus_mqtt` holds the `MqttConnection` interface (connect with
  a will, subscribe, publish, messages) that a real MQTT client and the
  `InMemoryBroker` both implement. The in-memory broker honours the rules
  above that matter here: retained messages, wildcard matching, the last
  will on a dropped connection, QoS downgrade to the lower of the two sides,
  and loss only for QoS 0. It is the broker behind the offline demo, the
  tests, and the in-browser device panel.
- The payloads above map one to one to the protocol models in the same package.
- `MqttTransport` in `packages/glowhaus_transport` is the app side of this
  document over any `MqttConnection`: `MqttClientConnection` (the
  `mqtt_client` package: TCP with TLS on native, WSS in the browser) or the
  `InMemoryBroker`. It reconnects with exponential backoff and jitter.
- `packages/glowhaus_device` is the device side: `DeviceModel` implements
  section 8 with no I/O (atomic commands, the error codes, expiry, a memory
  of the last 8 command ids); `VirtualDevice` puts a model on an
  `MqttConnection` and does sections 5 to 7 (announce on connect and on
  query with jitter, retained availability with a last will, retained
  state, retained `set` ignored, reconnect with backoff when the broker
  goes away). It depends on `glowhaus_domain` and `glowhaus_mqtt` only, never on the app or the transport: it is the proof
  that this document is enough to build a device. `simulator/` runs it
  against a real broker.
- `SimulatedTransport` is not a simulation of the protocol: it is an
  `InMemoryBroker`, a `VirtualHome` of such devices and an `MqttTransport`
  in one isolate. Every tap in the offline demo is a real `set`, ack and
  retained `state`. Only the network is imitated.
- `MqttTransport` subscribes to `info` first, so 1.1 devices are known
  before their state arrives. For 1.0 devices, discovery is QoS 0:
  `MqttTransport` holds retained state and availability for a device until
  its announce arrives, and while any device is in that position repeats
  the query (3 s, then doubling, up to 8 times). `VirtualDevice` publishes
  `info` on every connect, offline-at-boot devices included.

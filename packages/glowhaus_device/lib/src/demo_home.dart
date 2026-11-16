import 'package:glowhaus_device/src/device_model.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';

/// Translation keys of the demo's default names. The app translates these;
/// a renamed room or device has no key and is shown exactly as typed.
abstract final class DemoNames {
  static const String livingRoom = 'demo.livingRoom';
  static const String bedroom = 'demo.bedroom';
  static const String kitchen = 'demo.kitchen';
  static const String entrance = 'demo.entrance';
  static const String movieNight = 'demo.movieNight';
  static const String goodMorning = 'demo.goodMorning';
  static const String away = 'demo.away';
  static const String ceilingLight = 'demo.ceilingLight';
  static const String floorLamp = 'demo.floorLamp';
  static const String curtain = 'demo.curtain';
  static const String thermostat = 'demo.thermostat';
  static const String readingLight = 'demo.readingLight';
  static const String climateSensor = 'demo.climateSensor';
  static const String wallSwitch = 'demo.wallSwitch';
  static const String coffeeMachine = 'demo.coffeeMachine';
  static const String motionSensor = 'demo.motionSensor';
  static const String frontDoorLock = 'demo.frontDoorLock';
  static const String doorSensor = 'demo.doorSensor';
  static const String doorbellCamera = 'demo.doorbellCamera';
  static const String leakSensor = 'demo.leakSensor';
  static const String channelCeiling = 'demo.channelCeiling';
  static const String channelCounter = 'demo.channelCounter';
  static const String channelHood = 'demo.channelHood';

  static const List<String> all = [
    livingRoom,
    bedroom,
    kitchen,
    entrance,
    movieNight,
    goodMorning,
    away,
    ceilingLight,
    floorLamp,
    curtain,
    thermostat,
    readingLight,
    climateSensor,
    wallSwitch,
    coffeeMachine,
    motionSensor,
    frontDoorLock,
    doorSensor,
    doorbellCamera,
    leakSensor,
    channelCeiling,
    channelCounter,
    channelHood,
  ];
}

/// The seeded demo: one home, four rooms, thirteen devices covering every
/// device type and capability.
abstract final class DemoHome {
  static const String homeId = 'demo-home';

  static const String livingRoom = 'living-room';
  static const String bedroom = 'bedroom';
  static const String kitchen = 'kitchen';
  static const String entrance = 'entrance';

  static const Home home = Home(
    id: homeId,
    name: 'Glowhaus Demo',
    rooms: [
      Room(
        id: livingRoom,
        name: 'Living Room',
        nameKey: DemoNames.livingRoom,
        kind: RoomKind.livingRoom,
      ),
      Room(
        id: bedroom,
        name: 'Bedroom',
        nameKey: DemoNames.bedroom,
        kind: RoomKind.bedroom,
      ),
      Room(
        id: kitchen,
        name: 'Kitchen',
        nameKey: DemoNames.kitchen,
        kind: RoomKind.kitchen,
      ),
      Room(
        id: entrance,
        name: 'Entrance',
        nameKey: DemoNames.entrance,
        kind: RoomKind.entrance,
      ),
    ],
    scenes: [
      Scene(
        id: 'movie-night',
        name: 'Movie night',
        nameKey: DemoNames.movieNight,
        actions: [
          SceneAction(
            deviceId: 'lr-ceiling',
            patches: {'onOff': CapabilityPatch.onOff(on: false)},
          ),
          SceneAction(
            deviceId: 'lr-lamp',
            patches: {
              'onOff': CapabilityPatch.onOff(on: true),
              'brightness': CapabilityPatch.brightness(level: 20),
            },
          ),
          SceneAction(
            deviceId: 'lr-curtain',
            patches: {'position': CapabilityPatch.position(target: 0)},
          ),
        ],
      ),
      Scene(
        id: 'good-morning',
        name: 'Good morning',
        nameKey: DemoNames.goodMorning,
        actions: [
          SceneAction(
            deviceId: 'lr-curtain',
            patches: {'position': CapabilityPatch.position(target: 100)},
          ),
          SceneAction(
            deviceId: 'kt-outlet',
            patches: {'onOff': CapabilityPatch.onOff(on: true)},
          ),
        ],
      ),
      Scene(
        id: 'away',
        name: 'Away',
        nameKey: DemoNames.away,
        actions: [
          SceneAction(
            deviceId: 'en-lock',
            patches: {'lock': CapabilityPatch.lock(locked: true)},
          ),
          SceneAction(
            deviceId: 'lr-thermostat',
            patches: {
              'thermostat': CapabilityPatch.thermostat(
                mode: ThermostatMode.off,
              ),
            },
          ),
        ],
      ),
    ],
    members: [
      HomeMember(
        user: User(id: 'daniel', name: 'Daniel'),
        role: Role.owner,
      ),
    ],
  );

  static const String _maker = 'Glowhaus Labs';

  static Capability _cap(CapabilityKind kind, [Map<String, dynamic>? config]) =>
      Capability.of(kind, config: config ?? const <String, dynamic>{});

  static List<DeviceSpec> devices() => [
    // Living room
    DeviceSpec(
      descriptor: DeviceDescriptor(
        id: 'lr-ceiling',
        type: DeviceType.light,
        name: 'Ceiling light',
        nameKey: DemoNames.ceilingLight,
        manufacturer: _maker,
        model: 'GL-DIM-1',
        firmware: '1.2.0',
        roomHint: livingRoom,
        capabilities: [
          _cap(CapabilityKind.onOff),
          _cap(CapabilityKind.brightness),
        ],
      ),
      initialState: const {
        'onOff': CapabilityState.onOff(on: true),
        'brightness': CapabilityState.brightness(level: 70),
      },
    ),
    DeviceSpec(
      descriptor: DeviceDescriptor(
        id: 'lr-lamp',
        type: DeviceType.light,
        name: 'Floor lamp',
        nameKey: DemoNames.floorLamp,
        manufacturer: _maker,
        model: 'GL-RGB-1',
        firmware: '1.0.0',
        roomHint: livingRoom,
        capabilities: [
          _cap(CapabilityKind.onOff),
          _cap(CapabilityKind.brightness),
          _cap(CapabilityKind.color),
          _cap(CapabilityKind.colorTemperature, const {
            'minKelvin': 2200,
            'maxKelvin': 6500,
          }),
        ],
      ),
      initialState: const {
        'onOff': CapabilityState.onOff(on: true),
        'brightness': CapabilityState.brightness(level: 55),
        'color': CapabilityState.color(hue: 28, saturation: 85),
        'colorTemperature': CapabilityState.colorTemperature(kelvin: 2700),
      },
    ),
    DeviceSpec(
      descriptor: DeviceDescriptor(
        id: 'lr-curtain',
        type: DeviceType.curtain,
        name: 'Curtain',
        nameKey: DemoNames.curtain,
        manufacturer: _maker,
        model: 'GL-CRT-1',
        firmware: '1.1.3',
        roomHint: livingRoom,
        capabilities: [_cap(CapabilityKind.position)],
      ),
      initialState: const {
        'position': CapabilityState.position(position: 60, target: 60),
      },
    ),
    DeviceSpec(
      descriptor: DeviceDescriptor(
        id: 'lr-thermostat',
        type: DeviceType.thermostat,
        name: 'Thermostat',
        nameKey: DemoNames.thermostat,
        manufacturer: _maker,
        model: 'GL-THM-2',
        firmware: '2.0.1',
        roomHint: livingRoom,
        capabilities: [
          _cap(CapabilityKind.thermostat, const {
            'minSetpoint': 16,
            'maxSetpoint': 30,
            'step': 0.5,
            'modes': ['off', 'heat', 'cool', 'auto'],
            'fanModes': ['auto', 'low', 'medium', 'high'],
          }),
          _cap(CapabilityKind.temperatureSensor),
        ],
      ),
      initialState: const {
        'thermostat': CapabilityState.thermostat(
          setpoint: 22.5,
          mode: ThermostatMode.heat,
          fan: FanMode.auto,
          lastActiveMode: ThermostatMode.heat,
        ),
        'temperatureSensor': CapabilityState.temperatureSensor(celsius: 20.8),
      },
    ),
    // Bedroom
    DeviceSpec(
      descriptor: DeviceDescriptor(
        id: 'br-reading',
        type: DeviceType.light,
        name: 'Reading light',
        nameKey: DemoNames.readingLight,
        manufacturer: _maker,
        model: 'GL-SW-L',
        firmware: '1.0.4',
        roomHint: bedroom,
        capabilities: [_cap(CapabilityKind.onOff)],
      ),
      initialState: const {'onOff': CapabilityState.onOff(on: false)},
    ),
    DeviceSpec(
      descriptor: DeviceDescriptor(
        id: 'br-climate',
        type: DeviceType.sensor,
        name: 'Climate sensor',
        nameKey: DemoNames.climateSensor,
        manufacturer: _maker,
        model: 'GL-TH-1',
        firmware: '1.0.0',
        roomHint: bedroom,
        capabilities: [
          _cap(CapabilityKind.temperatureSensor),
          _cap(CapabilityKind.humiditySensor),
        ],
      ),
      initialState: const {
        'temperatureSensor': CapabilityState.temperatureSensor(celsius: 21.4),
        'humiditySensor': CapabilityState.humiditySensor(percent: 46),
      },
    ),
    // Kitchen
    const DeviceSpec(
      descriptor: DeviceDescriptor(
        id: 'kt-switch',
        type: DeviceType.wallSwitch,
        name: 'Wall switch',
        nameKey: DemoNames.wallSwitch,
        manufacturer: _maker,
        model: 'GL-SW-3',
        firmware: '1.3.0',
        roomHint: kitchen,
        capabilities: [
          Capability(
            id: 'ch1',
            kind: CapabilityKind.onOff,
            label: 'Ceiling',
            labelKey: DemoNames.channelCeiling,
          ),
          Capability(
            id: 'ch2',
            kind: CapabilityKind.onOff,
            label: 'Counter',
            labelKey: DemoNames.channelCounter,
          ),
          Capability(
            id: 'ch3',
            kind: CapabilityKind.onOff,
            label: 'Hood',
            labelKey: DemoNames.channelHood,
          ),
        ],
      ),
      initialState: {
        'ch1': CapabilityState.onOff(on: true),
        'ch2': CapabilityState.onOff(on: false),
        'ch3': CapabilityState.onOff(on: false),
      },
    ),
    DeviceSpec(
      descriptor: DeviceDescriptor(
        id: 'kt-outlet',
        type: DeviceType.outlet,
        name: 'Coffee machine',
        nameKey: DemoNames.coffeeMachine,
        manufacturer: _maker,
        model: 'GL-PLG-M',
        firmware: '1.1.0',
        roomHint: kitchen,
        capabilities: [
          _cap(CapabilityKind.onOff),
          _cap(CapabilityKind.powerMeter),
        ],
      ),
      initialState: const {
        'onOff': CapabilityState.onOff(on: true),
        'powerMeter': CapabilityState.powerMeter(watts: 1180, energyKwh: 42.7),
      },
      onWatts: 1180,
    ),
    DeviceSpec(
      descriptor: DeviceDescriptor(
        id: 'kt-motion',
        type: DeviceType.sensor,
        name: 'Motion sensor',
        nameKey: DemoNames.motionSensor,
        manufacturer: _maker,
        model: 'GL-PIR-1',
        firmware: '1.0.2',
        roomHint: kitchen,
        capabilities: [_cap(CapabilityKind.motionSensor)],
      ),
      initialState: const {
        'motionSensor': CapabilityState.motionSensor(motion: false),
      },
      // Shows the offline state in the demo.
      online: false,
    ),
    DeviceSpec(
      descriptor: DeviceDescriptor(
        id: 'kt-leak',
        type: DeviceType.sensor,
        name: 'Leak sensor',
        nameKey: DemoNames.leakSensor,
        manufacturer: _maker,
        model: 'GL-LEAK-1',
        firmware: '1.0.1',
        roomHint: kitchen,
        capabilities: [_cap(CapabilityKind.leakSensor)],
      ),
      initialState: const {
        'leakSensor': CapabilityState.leakSensor(wet: false),
      },
    ),
    // Entrance
    DeviceSpec(
      descriptor: DeviceDescriptor(
        id: 'en-lock',
        type: DeviceType.lock,
        name: 'Front door lock',
        nameKey: DemoNames.frontDoorLock,
        manufacturer: _maker,
        model: 'GL-LCK-1',
        firmware: '3.0.0',
        roomHint: entrance,
        capabilities: [_cap(CapabilityKind.lock)],
      ),
      initialState: const {'lock': CapabilityState.lock(locked: true)},
    ),
    DeviceSpec(
      descriptor: DeviceDescriptor(
        id: 'en-door',
        type: DeviceType.sensor,
        name: 'Door sensor',
        nameKey: DemoNames.doorSensor,
        manufacturer: _maker,
        model: 'GL-CNT-1',
        firmware: '1.0.0',
        roomHint: entrance,
        capabilities: [_cap(CapabilityKind.contactSensor)],
      ),
      initialState: const {
        'contactSensor': CapabilityState.contactSensor(open: false),
      },
    ),
    DeviceSpec(
      descriptor: DeviceDescriptor(
        id: 'en-camera',
        type: DeviceType.camera,
        name: 'Doorbell camera',
        nameKey: DemoNames.doorbellCamera,
        manufacturer: _maker,
        model: 'GL-CAM-1',
        firmware: '0.9.0',
        roomHint: entrance,
        capabilities: [
          _cap(CapabilityKind.camera, const {
            'streams': [
              {'protocol': 'rtsp', 'url': 'rtsp://192.168.1.40:8554/door'},
            ],
          }),
        ],
      ),
      initialState: const {'camera': CapabilityState.camera(streaming: true)},
    ),
  ];
}

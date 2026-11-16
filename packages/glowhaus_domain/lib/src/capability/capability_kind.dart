/// What a capability is. Wire names equal the enum names.
enum CapabilityKind {
  onOff,
  brightness,
  color,
  colorTemperature,
  position,
  thermostat,
  powerMeter,
  lock,
  temperatureSensor,
  humiditySensor,
  motionSensor,
  contactSensor,
  leakSensor,
  camera,

  /// A kind this version of the app does not know. Preserved in the
  /// descriptor, ignored everywhere else.
  unknown;

  /// Whether the capability has at least one field a command may set.
  bool get isWritable => switch (this) {
    onOff ||
    brightness ||
    color ||
    colorTemperature ||
    position ||
    thermostat ||
    lock => true,
    powerMeter ||
    temperatureSensor ||
    humiditySensor ||
    motionSensor ||
    contactSensor ||
    leakSensor ||
    camera ||
    unknown => false,
  };
}

enum ThermostatMode { off, heat, cool, auto }

enum FanMode { auto, low, medium, high }

enum ThermostatAction { idle, heating, cooling }

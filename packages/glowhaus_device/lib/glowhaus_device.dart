/// The device side of the Glowhaus protocol.
///
/// `DeviceModel` is the behaviour of one device (commands, derived readings,
/// motion of covers, ambient drift) with no I/O at all. `VirtualDevice` puts
/// a model on an `MqttConnection` and follows `docs/protocol.md` to the
/// letter: announce, availability with a last will, retained state, acks.
/// `VirtualHome` runs a set of them. `DemoHome` is the seeded demo.
///
/// This package depends on `glowhaus_domain` (the protocol models) and
/// `glowhaus_mqtt` (the connection interface) only. It must never import
/// the app or the transport package: it exists to prove that the protocol
/// document is enough to build a device.
library;

export 'src/demo_home.dart';
export 'src/device_model.dart';
export 'src/link_config.dart';
export 'src/virtual_device.dart';
export 'src/virtual_home.dart';

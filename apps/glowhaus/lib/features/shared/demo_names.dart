import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';

/// Names are data: whatever a user types is shown as typed in every
/// language. Only seeded default names carry a translation key; renaming
/// clears it. A key this app does not know falls back to the name.
String translatedName(
  AppLocalizations l10n, {
  required String name,
  required String? key,
}) => switch (key) {
  DemoNames.livingRoom => l10n.demoRoomLivingRoom,
  DemoNames.bedroom => l10n.demoRoomBedroom,
  DemoNames.kitchen => l10n.demoRoomKitchen,
  DemoNames.entrance => l10n.demoRoomEntrance,
  DemoNames.ceilingLight => l10n.demoCeilingLight,
  DemoNames.floorLamp => l10n.demoFloorLamp,
  DemoNames.curtain => l10n.demoCurtain,
  DemoNames.thermostat => l10n.demoThermostat,
  DemoNames.readingLight => l10n.demoReadingLight,
  DemoNames.climateSensor => l10n.demoClimateSensor,
  DemoNames.wallSwitch => l10n.demoWallSwitch,
  DemoNames.coffeeMachine => l10n.demoCoffeeMachine,
  DemoNames.motionSensor => l10n.demoMotionSensor,
  DemoNames.frontDoorLock => l10n.demoFrontDoorLock,
  DemoNames.doorSensor => l10n.demoDoorSensor,
  DemoNames.doorbellCamera => l10n.demoDoorbellCamera,
  DemoNames.channelCeiling => l10n.demoChannelCeiling,
  DemoNames.channelCounter => l10n.demoChannelCounter,
  DemoNames.channelHood => l10n.demoChannelHood,
  DemoNames.movieNight => l10n.demoSceneMovieNight,
  DemoNames.goodMorning => l10n.demoSceneGoodMorning,
  DemoNames.away => l10n.demoSceneAway,
  _ => name,
};

extension RoomDisplayName on Room {
  String displayName(AppLocalizations l10n) =>
      translatedName(l10n, name: name, key: nameKey);
}

extension DeviceDisplayName on Device {
  String displayName(AppLocalizations l10n) =>
      translatedName(l10n, name: name, key: nameKey);
}

extension SceneDisplayName on Scene {
  String displayName(AppLocalizations l10n) =>
      translatedName(l10n, name: name, key: nameKey);
}

extension CapabilityDisplayLabel on Capability {
  /// The channel label, or null when the capability has none.
  String? displayLabel(AppLocalizations l10n) {
    final text = label;
    return text == null
        ? null
        : translatedName(l10n, name: text, key: labelKey);
  }
}

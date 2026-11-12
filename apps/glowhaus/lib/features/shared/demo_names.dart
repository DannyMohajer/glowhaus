import 'package:glowhaus/l10n/generated/app_localizations.dart';

/// Translations for the names the demo home ships with.
///
/// Names are data: whatever a user types is shown as typed in every
/// language. Only the untouched default names of the seeded demo are
/// translated, by exact match.
String localizedName(AppLocalizations l10n, String name) => switch (name) {
  'Living Room' => l10n.demoRoomLivingRoom,
  'Bedroom' => l10n.demoRoomBedroom,
  'Kitchen' => l10n.demoRoomKitchen,
  'Entrance' => l10n.demoRoomEntrance,
  'Ceiling light' => l10n.demoCeilingLight,
  'Floor lamp' => l10n.demoFloorLamp,
  'Curtain' => l10n.demoCurtain,
  'Thermostat' => l10n.demoThermostat,
  'Reading light' => l10n.demoReadingLight,
  'Climate sensor' => l10n.demoClimateSensor,
  'Wall switch' => l10n.demoWallSwitch,
  'Coffee machine' => l10n.demoCoffeeMachine,
  'Motion sensor' => l10n.demoMotionSensor,
  'Front door lock' => l10n.demoFrontDoorLock,
  'Door sensor' => l10n.demoDoorSensor,
  'Doorbell camera' => l10n.demoDoorbellCamera,
  'Ceiling' => l10n.demoChannelCeiling,
  'Counter' => l10n.demoChannelCounter,
  'Hood' => l10n.demoChannelHood,
  'Movie night' => l10n.demoSceneMovieNight,
  'Good morning' => l10n.demoSceneGoodMorning,
  'Away' => l10n.demoSceneAway,
  _ => name,
};

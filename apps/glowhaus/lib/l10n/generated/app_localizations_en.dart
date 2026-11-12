// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Glowhaus';

  @override
  String get navHome => 'Home';

  @override
  String get navRooms => 'Rooms';

  @override
  String get navSettings => 'Settings';

  @override
  String get welcomeTitle => 'Welcome to your';

  @override
  String get welcomeTitleAccent => 'smart home';

  @override
  String get welcomeSubtitle =>
      'Lights, climate and security in one place. This is a live demo with simulated devices, so tap anything.';

  @override
  String get welcomeStart => 'Let\'s start';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get settingsAccent => 'Accent colour';

  @override
  String get accentOrange => 'Orange';

  @override
  String get accentBlue => 'Blue';

  @override
  String get accentGreen => 'Green';

  @override
  String get accentViolet => 'Violet';

  @override
  String get accentRose => 'Rose';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePersian => 'فارسی';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsReduceMotionHint => 'Turn off animations and transitions';

  @override
  String get settingsSimulation => 'Simulation';

  @override
  String get settingsSimulationHint =>
      'The devices in this demo are simulated. Make the network worse to see how the app copes.';

  @override
  String get settingsLatency => 'Network delay';

  @override
  String settingsLatencyValue(int ms) {
    final intl.NumberFormat msNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String msString = msNumberFormat.format(ms);

    return '$msString ms';
  }

  @override
  String get settingsFailureRate => 'Failure rate';

  @override
  String get settingsFailureRateHint =>
      'Share of commands that fail or time out';

  @override
  String percentValue(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString%';
  }

  @override
  String get roomsTitle => 'Rooms';

  @override
  String get selectRoom => 'Select a room';

  @override
  String get selectDevice => 'Select a device';

  @override
  String get back => 'Back';

  @override
  String get settingsShowWelcome => 'Show welcome screen';

  @override
  String get settingsShowWelcomeHint =>
      'Open with the welcome screen next time';

  @override
  String greetingHi(String name) {
    return 'Hi $name,';
  }

  @override
  String get greetingWelcomeHome => 'Welcome home!';

  @override
  String activeDevices(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString devices active',
      one: '1 device active',
      zero: 'No devices active',
    );
    return '$_temp0';
  }

  @override
  String get connectionOnline => 'Connected';

  @override
  String get connectionConnecting => 'Connecting…';

  @override
  String get connectionOffline => 'Offline';

  @override
  String get filterAll => 'All';

  @override
  String roomDeviceCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString devices',
      one: '1 device',
    );
    return '$_temp0';
  }

  @override
  String roomOnCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString on';
  }

  @override
  String get scenesTitle => 'Scenes';

  @override
  String get scenesSoon => 'One tap for the whole house. Coming soon.';

  @override
  String get emptyRoom => 'No devices here yet';

  @override
  String get deviceNotFound => 'This device is no longer available';

  @override
  String get roomNotFound => 'This room no longer exists';

  @override
  String get loading => 'Loading your home…';

  @override
  String get typeLights => 'Lights';

  @override
  String get typeSwitches => 'Switches';

  @override
  String get typeCurtains => 'Curtains';

  @override
  String get typeClimate => 'Climate';

  @override
  String get typeOutlets => 'Outlets';

  @override
  String get typeLocks => 'Locks';

  @override
  String get typeSensors => 'Sensors';

  @override
  String get typeCameras => 'Cameras';

  @override
  String get typeOther => 'Other';

  @override
  String get stateOn => 'On';

  @override
  String get stateOff => 'Off';

  @override
  String get stateOffline => 'Offline';

  @override
  String stateOnLevel(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'On · $percentString%';
  }

  @override
  String get stateLocked => 'Locked';

  @override
  String get stateUnlocked => 'Unlocked';

  @override
  String get stateJammed => 'Jammed';

  @override
  String stateOpenPercent(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$percentString% open';
  }

  @override
  String get stateClosed => 'Closed';

  @override
  String get stateOpen => 'Open';

  @override
  String get stateOpening => 'Opening…';

  @override
  String get stateClosing => 'Closing…';

  @override
  String get stateHeating => 'Heating';

  @override
  String get stateCooling => 'Cooling';

  @override
  String get stateIdle => 'Idle';

  @override
  String get stateMotion => 'Motion detected';

  @override
  String get stateNoMotion => 'No motion';

  @override
  String stateChannelsOn(int on, int total) {
    final intl.NumberFormat onNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String onString = onNumberFormat.format(on);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$onString of $totalString on';
  }

  @override
  String get stateLive => 'Live';

  @override
  String get stateUnknown => 'Waiting for device…';

  @override
  String temperatureValue(String value) {
    return '$value°';
  }

  @override
  String wattsValue(String value) {
    return '$value W';
  }

  @override
  String kwhValue(String value) {
    return '$value kWh';
  }

  @override
  String get detailPower => 'Power';

  @override
  String get detailBrightness => 'Brightness';

  @override
  String get detailColor => 'Colour';

  @override
  String get detailColorTemperature => 'White tone';

  @override
  String get tempWarm => 'Warm';

  @override
  String get tempNeutral => 'Neutral';

  @override
  String get tempCool => 'Cool';

  @override
  String get tempDaylight => 'Daylight';

  @override
  String get detailPosition => 'Position';

  @override
  String get actionOpen => 'Open';

  @override
  String get actionClose => 'Close';

  @override
  String get actionStop => 'Stop';

  @override
  String get detailSetpoint => 'Target temperature';

  @override
  String get thermostatHeatingTo => 'Heating to';

  @override
  String get thermostatCoolingTo => 'Cooling to';

  @override
  String get thermostatAutoTo => 'Keeping at';

  @override
  String get thermostatOff => 'Off';

  @override
  String get detailMode => 'Mode';

  @override
  String get modeOff => 'Off';

  @override
  String get modeHeat => 'Heat';

  @override
  String get modeCool => 'Cool';

  @override
  String currentTemperature(String value) {
    return 'Now $value';
  }

  @override
  String get detailFan => 'Fan';

  @override
  String get fanAuto => 'Auto';

  @override
  String get fanLow => 'Low';

  @override
  String get fanMedium => 'Medium';

  @override
  String get fanHigh => 'High';

  @override
  String get detailLivePower => 'Power use';

  @override
  String get detailEnergy => 'Total energy';

  @override
  String get detailLock => 'Door lock';

  @override
  String get detailTemperature => 'Temperature';

  @override
  String get detailHumidity => 'Humidity';

  @override
  String get detailMotion => 'Motion';

  @override
  String get detailContact => 'Door';

  @override
  String get detailCamera => 'Camera';

  @override
  String get cameraSoon => 'Live view arrives in a later release';

  @override
  String get offlineBanner => 'Offline. Showing the last known state.';

  @override
  String get pendingLabel => 'Sending…';

  @override
  String deviceInfo(String model, String firmware) {
    return '$model · firmware $firmware';
  }

  @override
  String feedbackTimedOut(String device) {
    return '$device didn\'t respond. Your change was undone.';
  }

  @override
  String feedbackBusy(String device) {
    return '$device is busy and rejected the change. It was undone.';
  }

  @override
  String feedbackRejected(String device) {
    return '$device couldn\'t apply the change. It was undone.';
  }

  @override
  String get demoRoomLivingRoom => 'Living Room';

  @override
  String get demoRoomBedroom => 'Bedroom';

  @override
  String get demoRoomKitchen => 'Kitchen';

  @override
  String get demoRoomEntrance => 'Entrance';

  @override
  String get demoCeilingLight => 'Ceiling light';

  @override
  String get demoFloorLamp => 'Floor lamp';

  @override
  String get demoCurtain => 'Curtain';

  @override
  String get demoThermostat => 'Thermostat';

  @override
  String get demoReadingLight => 'Reading light';

  @override
  String get demoClimateSensor => 'Climate sensor';

  @override
  String get demoWallSwitch => 'Wall switch';

  @override
  String get demoCoffeeMachine => 'Coffee machine';

  @override
  String get demoMotionSensor => 'Motion sensor';

  @override
  String get demoFrontDoorLock => 'Front door lock';

  @override
  String get demoDoorSensor => 'Door sensor';

  @override
  String get demoDoorbellCamera => 'Doorbell camera';

  @override
  String get demoChannelCeiling => 'Ceiling';

  @override
  String get demoChannelCounter => 'Counter';

  @override
  String get demoChannelHood => 'Hood';

  @override
  String get demoSceneMovieNight => 'Movie night';

  @override
  String get demoSceneGoodMorning => 'Good morning';

  @override
  String get demoSceneAway => 'Away';

  @override
  String get modeAuto => 'Auto';

  @override
  String get listSeparator => ' · ';
}

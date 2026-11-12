import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Glowhaus'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get navRooms;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your'**
  String get welcomeTitle;

  /// No description provided for @welcomeTitleAccent.
  ///
  /// In en, this message translates to:
  /// **'smart home'**
  String get welcomeTitleAccent;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lights, climate and security in one place. This is a live demo with simulated devices, so tap anything.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start'**
  String get welcomeStart;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @settingsAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent colour'**
  String get settingsAccent;

  /// No description provided for @accentOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get accentOrange;

  /// No description provided for @accentBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get accentBlue;

  /// No description provided for @accentGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get accentGreen;

  /// No description provided for @accentViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get accentViolet;

  /// No description provided for @accentRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get accentRose;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languagePersian.
  ///
  /// In en, this message translates to:
  /// **'فارسی'**
  String get languagePersian;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReduceMotion;

  /// No description provided for @settingsReduceMotionHint.
  ///
  /// In en, this message translates to:
  /// **'Turn off animations and transitions'**
  String get settingsReduceMotionHint;

  /// No description provided for @settingsSimulation.
  ///
  /// In en, this message translates to:
  /// **'Simulation'**
  String get settingsSimulation;

  /// No description provided for @settingsSimulationHint.
  ///
  /// In en, this message translates to:
  /// **'The devices in this demo are simulated. Make the network worse to see how the app copes.'**
  String get settingsSimulationHint;

  /// No description provided for @settingsLatency.
  ///
  /// In en, this message translates to:
  /// **'Network delay'**
  String get settingsLatency;

  /// No description provided for @settingsLatencyValue.
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String settingsLatencyValue(int ms);

  /// No description provided for @settingsFailureRate.
  ///
  /// In en, this message translates to:
  /// **'Failure rate'**
  String get settingsFailureRate;

  /// No description provided for @settingsFailureRateHint.
  ///
  /// In en, this message translates to:
  /// **'Share of commands that fail or time out'**
  String get settingsFailureRateHint;

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percentValue(int value);

  /// No description provided for @roomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get roomsTitle;

  /// No description provided for @selectRoom.
  ///
  /// In en, this message translates to:
  /// **'Select a room'**
  String get selectRoom;

  /// No description provided for @selectDevice.
  ///
  /// In en, this message translates to:
  /// **'Select a device'**
  String get selectDevice;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @settingsShowWelcome.
  ///
  /// In en, this message translates to:
  /// **'Show welcome screen'**
  String get settingsShowWelcome;

  /// No description provided for @settingsShowWelcomeHint.
  ///
  /// In en, this message translates to:
  /// **'Open with the welcome screen next time'**
  String get settingsShowWelcomeHint;

  /// No description provided for @greetingHi.
  ///
  /// In en, this message translates to:
  /// **'Hi {name},'**
  String greetingHi(String name);

  /// No description provided for @greetingWelcomeHome.
  ///
  /// In en, this message translates to:
  /// **'Welcome home!'**
  String get greetingWelcomeHome;

  /// No description provided for @activeDevices.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No devices active} =1{1 device active} other{{count} devices active}}'**
  String activeDevices(int count);

  /// No description provided for @connectionOnline.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connectionOnline;

  /// No description provided for @connectionConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connectionConnecting;

  /// No description provided for @connectionOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get connectionOffline;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @roomDeviceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 device} other{{count} devices}}'**
  String roomDeviceCount(int count);

  /// No description provided for @roomOnCount.
  ///
  /// In en, this message translates to:
  /// **'{count} on'**
  String roomOnCount(int count);

  /// No description provided for @scenesTitle.
  ///
  /// In en, this message translates to:
  /// **'Scenes'**
  String get scenesTitle;

  /// No description provided for @scenesSoon.
  ///
  /// In en, this message translates to:
  /// **'One tap for the whole house. Coming soon.'**
  String get scenesSoon;

  /// No description provided for @emptyRoom.
  ///
  /// In en, this message translates to:
  /// **'No devices here yet'**
  String get emptyRoom;

  /// No description provided for @deviceNotFound.
  ///
  /// In en, this message translates to:
  /// **'This device is no longer available'**
  String get deviceNotFound;

  /// No description provided for @roomNotFound.
  ///
  /// In en, this message translates to:
  /// **'This room no longer exists'**
  String get roomNotFound;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading your home…'**
  String get loading;

  /// No description provided for @typeLights.
  ///
  /// In en, this message translates to:
  /// **'Lights'**
  String get typeLights;

  /// No description provided for @typeSwitches.
  ///
  /// In en, this message translates to:
  /// **'Switches'**
  String get typeSwitches;

  /// No description provided for @typeCurtains.
  ///
  /// In en, this message translates to:
  /// **'Curtains'**
  String get typeCurtains;

  /// No description provided for @typeClimate.
  ///
  /// In en, this message translates to:
  /// **'Climate'**
  String get typeClimate;

  /// No description provided for @typeOutlets.
  ///
  /// In en, this message translates to:
  /// **'Outlets'**
  String get typeOutlets;

  /// No description provided for @typeLocks.
  ///
  /// In en, this message translates to:
  /// **'Locks'**
  String get typeLocks;

  /// No description provided for @typeSensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get typeSensors;

  /// No description provided for @typeCameras.
  ///
  /// In en, this message translates to:
  /// **'Cameras'**
  String get typeCameras;

  /// No description provided for @typeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get typeOther;

  /// No description provided for @stateOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get stateOn;

  /// No description provided for @stateOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get stateOff;

  /// No description provided for @stateOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get stateOffline;

  /// No description provided for @stateOnLevel.
  ///
  /// In en, this message translates to:
  /// **'On · {percent}%'**
  String stateOnLevel(int percent);

  /// No description provided for @stateLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get stateLocked;

  /// No description provided for @stateUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get stateUnlocked;

  /// No description provided for @stateJammed.
  ///
  /// In en, this message translates to:
  /// **'Jammed'**
  String get stateJammed;

  /// No description provided for @stateOpenPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% open'**
  String stateOpenPercent(int percent);

  /// No description provided for @stateClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get stateClosed;

  /// No description provided for @stateOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get stateOpen;

  /// No description provided for @stateOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening…'**
  String get stateOpening;

  /// No description provided for @stateClosing.
  ///
  /// In en, this message translates to:
  /// **'Closing…'**
  String get stateClosing;

  /// No description provided for @stateHeating.
  ///
  /// In en, this message translates to:
  /// **'Heating'**
  String get stateHeating;

  /// No description provided for @stateCooling.
  ///
  /// In en, this message translates to:
  /// **'Cooling'**
  String get stateCooling;

  /// No description provided for @stateIdle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get stateIdle;

  /// No description provided for @stateMotion.
  ///
  /// In en, this message translates to:
  /// **'Motion detected'**
  String get stateMotion;

  /// No description provided for @stateNoMotion.
  ///
  /// In en, this message translates to:
  /// **'No motion'**
  String get stateNoMotion;

  /// No description provided for @stateChannelsOn.
  ///
  /// In en, this message translates to:
  /// **'{on} of {total} on'**
  String stateChannelsOn(int on, int total);

  /// No description provided for @stateLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get stateLive;

  /// No description provided for @stateUnknown.
  ///
  /// In en, this message translates to:
  /// **'Waiting for device…'**
  String get stateUnknown;

  /// A temperature with its unit. Right-to-left languages wrap it in U+200E marks so the degree sign stays right of the digits wherever it appears.
  ///
  /// In en, this message translates to:
  /// **'{value}°'**
  String temperatureValue(String value);

  /// No description provided for @wattsValue.
  ///
  /// In en, this message translates to:
  /// **'{value} W'**
  String wattsValue(String value);

  /// No description provided for @kwhValue.
  ///
  /// In en, this message translates to:
  /// **'{value} kWh'**
  String kwhValue(String value);

  /// No description provided for @detailPower.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get detailPower;

  /// No description provided for @detailBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get detailBrightness;

  /// No description provided for @detailColor.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get detailColor;

  /// No description provided for @detailColorTemperature.
  ///
  /// In en, this message translates to:
  /// **'White tone'**
  String get detailColorTemperature;

  /// No description provided for @tempWarm.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get tempWarm;

  /// No description provided for @tempNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get tempNeutral;

  /// No description provided for @tempCool.
  ///
  /// In en, this message translates to:
  /// **'Cool'**
  String get tempCool;

  /// No description provided for @tempDaylight.
  ///
  /// In en, this message translates to:
  /// **'Daylight'**
  String get tempDaylight;

  /// No description provided for @detailPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get detailPosition;

  /// No description provided for @actionOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get actionOpen;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get actionStop;

  /// No description provided for @detailSetpoint.
  ///
  /// In en, this message translates to:
  /// **'Target temperature'**
  String get detailSetpoint;

  /// No description provided for @thermostatHeatingTo.
  ///
  /// In en, this message translates to:
  /// **'Heating to'**
  String get thermostatHeatingTo;

  /// No description provided for @thermostatCoolingTo.
  ///
  /// In en, this message translates to:
  /// **'Cooling to'**
  String get thermostatCoolingTo;

  /// No description provided for @thermostatAutoTo.
  ///
  /// In en, this message translates to:
  /// **'Keeping at'**
  String get thermostatAutoTo;

  /// No description provided for @thermostatOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get thermostatOff;

  /// No description provided for @modeHeating.
  ///
  /// In en, this message translates to:
  /// **'Heating'**
  String get modeHeating;

  /// No description provided for @modeCooling.
  ///
  /// In en, this message translates to:
  /// **'Cooling'**
  String get modeCooling;

  /// No description provided for @currentTemperature.
  ///
  /// In en, this message translates to:
  /// **'Now {value}'**
  String currentTemperature(String value);

  /// No description provided for @detailFan.
  ///
  /// In en, this message translates to:
  /// **'Fan'**
  String get detailFan;

  /// No description provided for @fanAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get fanAuto;

  /// No description provided for @fanLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get fanLow;

  /// No description provided for @fanMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get fanMedium;

  /// No description provided for @fanHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get fanHigh;

  /// No description provided for @detailLivePower.
  ///
  /// In en, this message translates to:
  /// **'Power use'**
  String get detailLivePower;

  /// No description provided for @detailEnergy.
  ///
  /// In en, this message translates to:
  /// **'Total energy'**
  String get detailEnergy;

  /// No description provided for @detailLock.
  ///
  /// In en, this message translates to:
  /// **'Door lock'**
  String get detailLock;

  /// No description provided for @detailTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get detailTemperature;

  /// No description provided for @detailHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get detailHumidity;

  /// No description provided for @detailMotion.
  ///
  /// In en, this message translates to:
  /// **'Motion'**
  String get detailMotion;

  /// No description provided for @detailContact.
  ///
  /// In en, this message translates to:
  /// **'Door'**
  String get detailContact;

  /// No description provided for @detailCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get detailCamera;

  /// No description provided for @cameraSoon.
  ///
  /// In en, this message translates to:
  /// **'Live view arrives in a later release'**
  String get cameraSoon;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline. Showing the last known state.'**
  String get offlineBanner;

  /// No description provided for @pendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get pendingLabel;

  /// No description provided for @deviceInfo.
  ///
  /// In en, this message translates to:
  /// **'{model} · firmware {firmware}'**
  String deviceInfo(String model, String firmware);

  /// No description provided for @feedbackTimedOut.
  ///
  /// In en, this message translates to:
  /// **'{device} didn\'t respond. Your change was undone.'**
  String feedbackTimedOut(String device);

  /// No description provided for @feedbackBusy.
  ///
  /// In en, this message translates to:
  /// **'{device} is busy and rejected the change. It was undone.'**
  String feedbackBusy(String device);

  /// No description provided for @feedbackRejected.
  ///
  /// In en, this message translates to:
  /// **'{device} couldn\'t apply the change. It was undone.'**
  String feedbackRejected(String device);

  /// No description provided for @demoRoomLivingRoom.
  ///
  /// In en, this message translates to:
  /// **'Living Room'**
  String get demoRoomLivingRoom;

  /// No description provided for @demoRoomBedroom.
  ///
  /// In en, this message translates to:
  /// **'Bedroom'**
  String get demoRoomBedroom;

  /// No description provided for @demoRoomKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get demoRoomKitchen;

  /// No description provided for @demoRoomEntrance.
  ///
  /// In en, this message translates to:
  /// **'Entrance'**
  String get demoRoomEntrance;

  /// No description provided for @demoCeilingLight.
  ///
  /// In en, this message translates to:
  /// **'Ceiling light'**
  String get demoCeilingLight;

  /// No description provided for @demoFloorLamp.
  ///
  /// In en, this message translates to:
  /// **'Floor lamp'**
  String get demoFloorLamp;

  /// No description provided for @demoCurtain.
  ///
  /// In en, this message translates to:
  /// **'Curtain'**
  String get demoCurtain;

  /// No description provided for @demoThermostat.
  ///
  /// In en, this message translates to:
  /// **'Thermostat'**
  String get demoThermostat;

  /// No description provided for @demoReadingLight.
  ///
  /// In en, this message translates to:
  /// **'Reading light'**
  String get demoReadingLight;

  /// No description provided for @demoClimateSensor.
  ///
  /// In en, this message translates to:
  /// **'Climate sensor'**
  String get demoClimateSensor;

  /// No description provided for @demoWallSwitch.
  ///
  /// In en, this message translates to:
  /// **'Wall switch'**
  String get demoWallSwitch;

  /// No description provided for @demoCoffeeMachine.
  ///
  /// In en, this message translates to:
  /// **'Coffee machine'**
  String get demoCoffeeMachine;

  /// No description provided for @demoMotionSensor.
  ///
  /// In en, this message translates to:
  /// **'Motion sensor'**
  String get demoMotionSensor;

  /// No description provided for @demoFrontDoorLock.
  ///
  /// In en, this message translates to:
  /// **'Front door lock'**
  String get demoFrontDoorLock;

  /// No description provided for @demoDoorSensor.
  ///
  /// In en, this message translates to:
  /// **'Door sensor'**
  String get demoDoorSensor;

  /// No description provided for @demoDoorbellCamera.
  ///
  /// In en, this message translates to:
  /// **'Doorbell camera'**
  String get demoDoorbellCamera;

  /// No description provided for @demoChannelCeiling.
  ///
  /// In en, this message translates to:
  /// **'Ceiling'**
  String get demoChannelCeiling;

  /// No description provided for @demoChannelCounter.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get demoChannelCounter;

  /// No description provided for @demoChannelHood.
  ///
  /// In en, this message translates to:
  /// **'Hood'**
  String get demoChannelHood;

  /// No description provided for @demoSceneMovieNight.
  ///
  /// In en, this message translates to:
  /// **'Movie night'**
  String get demoSceneMovieNight;

  /// No description provided for @demoSceneGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get demoSceneGoodMorning;

  /// No description provided for @demoSceneAway.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get demoSceneAway;

  /// No description provided for @modeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto mode'**
  String get modeAuto;

  /// Joins short status parts, e.g. "4 devices · 2 on". Persian uses a comma because a middle dot reads like the Persian digit zero.
  ///
  /// In en, this message translates to:
  /// **' · '**
  String get listSeparator;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

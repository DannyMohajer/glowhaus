import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/features/connection/data/broker_transports.dart';
import 'package:glowhaus/features/connection/data/connection_settings.dart';
import 'package:glowhaus/features/connection/data/connection_store.dart';
import 'package:glowhaus/features/settings/data/app_platform.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:meta/meta.dart';

/// What the settings screen shows about the connection.
@immutable
class ConnectionSettingsState {
  const new({
    required this.settings,
    required this.active,
    this.selected,
    this.status = TransportStatus.disconnected,
    this.problem,
    this.needsPassword = false,
    this.invalid = const {},
  });

  /// What is saved: the mode to start in and the broker to use.
  final ConnectionSettings settings;

  /// Where the devices on screen come from right now.
  final ConnectionMode active;

  /// The mode chip the user picked; differs from [active] while the broker
  /// form is open but not yet connected.
  final ConnectionMode? selected;

  /// Status of the transport in use.
  final TransportStatus status;

  /// Why the last connect attempt to the broker failed, while it retries.
  final MqttConnectFailure? problem;

  /// Broker mode after a launch: the password is not kept, so the user has
  /// to enter it again. Last-known devices are shown meanwhile.
  final bool needsPassword;

  /// Fields that stopped the last connect.
  final Set<BrokerField> invalid;

  ConnectionMode get shown => selected ?? active;

  ConnectionSettingsState copyWith({
    ConnectionSettings? settings,
    ConnectionMode? active,
    ConnectionMode? selected,
    TransportStatus? status,
    MqttConnectFailure? Function()? problem,
    bool? needsPassword,
    Set<BrokerField>? invalid,
  }) => ConnectionSettingsState(
    settings: settings ?? this.settings,
    active: active ?? this.active,
    selected: selected ?? this.selected,
    status: status ?? this.status,
    problem: problem == null ? this.problem : problem(),
    needsPassword: needsPassword ?? this.needsPassword,
    invalid: invalid ?? this.invalid,
  );

  @override
  bool operator ==(Object other) =>
      other is ConnectionSettingsState &&
      other.settings == settings &&
      other.active == active &&
      other.selected == selected &&
      other.status == status &&
      other.problem == problem &&
      other.needsPassword == needsPassword &&
      other.invalid.length == invalid.length &&
      other.invalid.containsAll(invalid);

  @override
  int get hashCode => Object.hash(
    settings,
    active,
    selected,
    status,
    problem,
    needsPassword,
    Object.hashAllUnordered(invalid),
  );
}

/// Demo or a real broker: switches the [DeviceRepository] between the
/// simulated home and an [MqttTransport], owns that transport, and keeps the
/// broker's last-known devices for the next launch.
///
/// The password lives in this object only. It is never saved, so a launch
/// in broker mode starts with the last-known devices and asks for it again.
class ConnectionSettingsCubit extends Cubit<ConnectionSettingsState> {
  new({
    required DeviceRepository devices,
    required this._demo,
    required this._brokers,
    required ConnectionStore store,
    required this._platform,
    this._developmentCa,
    this.saveDelay = const Duration(seconds: 2),
  }) : _devices = devices,
       _store = store,
       super(
         ConnectionSettingsState(
           settings: store.load(),
           active: ConnectionMode.demo,
           status: devices.transport.currentStatus,
         ),
       ) {
    _status = _devices.status.listen(
      (status) => emit(
        state.copyWith(
          status: status,
          problem: status == TransportStatus.connected ? () => null : null,
        ),
      ),
    );
  }

  final DeviceRepository _devices;
  final Transport _demo;
  final BrokerTransports _brokers;
  final ConnectionStore _store;
  final AppPlatform _platform;
  final String? _developmentCa;

  /// How long device changes settle before the last-known list is saved.
  final Duration saveDelay;

  late final StreamSubscription<TransportStatus> _status;
  Transport? _owned;
  StreamSubscription<MqttConnectFailure>? _failures;
  StreamSubscription<List<DeviceView>>? _views;
  Timer? _saveTimer;

  bool get isWeb => _platform.isWeb;

  /// The broker settings to show in the form, with the development CA from
  /// `--dart-define=GLOWHAUS_DEV_CA` filled in when none was saved.
  BrokerSettings get brokerDraft {
    final broker = state.settings.broker;
    final ca = _developmentCa;
    if (ca == null || isWeb || broker.trustedCertificatePem != null) {
      return broker;
    }
    return broker.copyWith(trustedCertificatePem: ca);
  }

  /// Called once at launch, after the demo has started. In broker mode the
  /// devices last seen there are shown until the password is entered.
  Future<void> init() async {
    if (state.settings.mode != ConnectionMode.broker) return;
    final idle = IdleTransport();
    await _adopt(idle, lastKnown: _store.lastKnown(brokerKey));
    emit(state.copyWith(active: ConnectionMode.broker, needsPassword: true));
  }

  /// Picks a mode chip. The demo is switched to at once; the broker only
  /// when [connect] is called with a password.
  Future<void> select(ConnectionMode mode) async {
    if (mode == ConnectionMode.demo) {
      await useDemo();
      return;
    }
    emit(state.copyWith(selected: mode));
  }

  Future<void> useDemo() async {
    await _adopt(_demo);
    final settings = state.settings.copyWith(mode: ConnectionMode.demo);
    emit(
      ConnectionSettingsState(
        settings: settings,
        active: ConnectionMode.demo,
        status: _devices.transport.currentStatus,
      ),
    );
    unawaited(_store.save(settings));
  }

  /// Connects to the broker in [broker] with [password]. The transport keeps
  /// retrying in the background; [ConnectionSettingsState.problem] says why
  /// while it does.
  Future<void> connect(
    BrokerSettings broker, {
    required String password,
  }) async {
    final invalid = broker.problems(web: isWeb);
    if (invalid.isNotEmpty) {
      emit(state.copyWith(invalid: invalid));
      return;
    }
    final settings = ConnectionSettings(
      mode: ConnectionMode.broker,
      broker: broker,
    );
    unawaited(_store.save(settings));
    final transport = await _brokers.create(broker, password: password);
    if (isClosed) {
      await transport.dispose();
      return;
    }
    emit(
      state.copyWith(
        settings: settings,
        active: ConnectionMode.broker,
        selected: ConnectionMode.broker,
        problem: () => null,
        needsPassword: false,
        invalid: const {},
      ),
    );
    await _failures?.cancel();
    _failures = transport.connectFailures
        .map((failure) => failure.reason)
        .listen((reason) => emit(state.copyWith(problem: () => reason)));
    await _adopt(transport, lastKnown: _store.lastKnown(brokerKey));
  }

  /// Identifies a broker and home for the last-known cache: devices seen on
  /// one broker are never shown for another.
  String get brokerKey {
    final b = state.settings.broker;
    return '${b.host.trim()}:${b.port ?? b.defaultPort(web: isWeb)}/${b.homeId}';
  }

  Future<void> _adopt(
    Transport next, {
    Iterable<Device> lastKnown = const [],
  }) async {
    final previous = _owned;
    _owned = identical(next, _demo) ? null : next;
    if (next is! MqttTransport) {
      await _failures?.cancel();
      _failures = null;
    }
    await _views?.cancel();
    _views = null;
    _saveTimer?.cancel();
    await _devices.use(next, lastKnown: lastKnown);
    if (previous != null && !identical(previous, next)) {
      await previous.dispose();
    }
    if (next is MqttTransport) _watchForCache();
  }

  /// Saves what the broker reports, a moment after it stops changing.
  void _watchForCache() {
    final key = brokerKey;
    // Not skipping the current list: retained info usually arrives while
    // the transport connects, before this listener exists.
    _views = _devices.watchAll().listen((views) {
      _saveTimer?.cancel();
      _saveTimer = Timer(saveDelay, () {
        unawaited(_store.saveLastKnown(key, [for (final v in views) v.device]));
      });
    });
  }

  @override
  Future<void> close() async {
    _saveTimer?.cancel();
    await _views?.cancel();
    await _failures?.cancel();
    await _status.cancel();
    await _owned?.dispose();
    await super.close();
  }
}

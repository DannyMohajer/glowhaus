import 'dart:async';

import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:meta/meta.dart';

/// A device as the UI should show it: reported state with the patches of
/// commands that are still in flight applied on top.
@immutable
class DeviceView {
  const new({required this.device, this.pendingCapabilities = const {}});

  /// The device with optimistic values applied.
  final Device device;

  /// Capability ids with a command in flight.
  final Set<String> pendingCapabilities;

  bool get pending => pendingCapabilities.isNotEmpty;

  bool isPending(String capabilityId) =>
      pendingCapabilities.contains(capabilityId);

  @override
  bool operator ==(Object other) =>
      other is DeviceView &&
      other.device == device &&
      other.pendingCapabilities.length == pendingCapabilities.length &&
      other.pendingCapabilities.containsAll(pendingCapabilities);

  @override
  int get hashCode =>
      Object.hash(device, Object.hashAllUnordered(pendingCapabilities));
}

/// A command that did not go through. The optimistic value has already been
/// rolled back when this is emitted.
@immutable
class CommandFailure {
  const new({required this.device, required this.result});

  /// The device as it is after the rollback.
  final Device device;

  /// A [CommandFailed], a [CommandTimedOut] or a [CommandUnreachable].
  final CommandResult result;

  bool get timedOut => result is CommandTimedOut;

  /// The app had no connection; the device never saw the command.
  bool get unreachable => result is CommandUnreachable;

  ProtocolErrorCode? get code => switch (result) {
    CommandFailed(:final code) => code,
    _ => null,
  };
}

/// A command that timed out, after which the device reported the requested
/// values anyway: the ack was late or lost, the change was not.
@immutable
class LateApply {
  const new({required this.device});

  /// The device as it reports itself now.
  final Device device;
}

class _PendingCommand {
  new(this.command);

  final DeviceCommand command;
  bool acked = false;
  Timer? settleTimer;
}

/// A timed-out command we still watch for, in case the device applies it.
class _LateCandidate {
  new(this.command);

  final DeviceCommand command;
  Timer? timer;
}

/// The single source of truth for devices.
///
/// Folds transport events into a device map and owns the optimistic overlay:
/// a command's values show immediately, stay until the device **reports a
/// matching state** (not merely acks), and are rolled back if the command is
/// rejected or times out.
class DeviceRepository {
  new(
    Transport transport, {
    DateTime Function()? clock,
    String Function()? commandIds,
    this.commandTimeout = Protocol.commandTimeout,
    this.settleTimeout = Protocol.stateSettleTimeout,
    this.lateApplyWindow = const Duration(seconds: 30),
  }) : _transport = transport,
       _clock = clock ?? DateTime.now,
       _commandIds = commandIds ?? _sequentialIds();

  Transport _transport;
  final DateTime Function() _clock;
  final String Function() _commandIds;
  final Duration commandTimeout;

  /// How long an acked command may wait for its matching state.
  final Duration settleTimeout;

  /// How long after a timeout a matching state still counts as that command
  /// being applied late.
  final Duration lateApplyWindow;

  final Map<String, Device> _reported = {};
  final List<_PendingCommand> _pending = [];
  final List<_LateCandidate> _late = [];
  final _views = StreamController<List<DeviceView>>.broadcast();
  final _failures = StreamController<CommandFailure>.broadcast();
  final _lateApplies = StreamController<LateApply>.broadcast();
  final _statusOut = StreamController<TransportStatus>.broadcast();
  StreamSubscription<DeviceEvent>? _events;
  StreamSubscription<TransportStatus>? _status;

  static String Function() _sequentialIds() {
    var counter = 0;
    final session = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    return () => 'c-$session-${counter++}';
  }

  /// The transport in use.
  Transport get transport => _transport;

  /// Connection state of the transport in use, starting with the current
  /// one. Follows [use] to a new transport.
  Stream<TransportStatus> get status async* {
    yield _transport.currentStatus;
    yield* _statusOut.stream;
  }

  /// All devices in announce order, starting with the current list.
  Stream<List<DeviceView>> watchAll() async* {
    yield current;
    yield* _views.stream;
  }

  /// One device; null while it is unknown.
  Stream<DeviceView?> watch(String deviceId) =>
      watchAll().map((views) => _find(views, deviceId)).distinct();

  /// Commands that were rejected or timed out, after their rollback.
  Stream<CommandFailure> get failures => _failures.stream;

  /// Timed-out commands that the device turned out to apply after all. The
  /// state already shows it; this is only so the earlier "didn't respond" is
  /// not the last word.
  Stream<LateApply> get lateApplies => _lateApplies.stream;

  List<DeviceView> get current => [
    for (final device in _reported.values) _viewOf(device),
  ];

  DeviceView? device(String deviceId) => _find(current, deviceId);

  /// Starts listening and connects. Safe to call more than once.
  Future<void> start() async {
    _events ??= _transport.events.listen(_onEvent);
    _status ??= _transport.status.listen(_onStatus);
    await _transport.connect();
  }

  /// Switches to [next]: the demo, a broker, or nothing at all. The previous
  /// transport is disconnected (its owner disposes it), every device and
  /// every command in flight is forgotten, and [lastKnown] stands in until
  /// [next] reports, with availability `unknown`.
  Future<void> use(
    Transport next, {
    Iterable<Device> lastKnown = const [],
  }) async {
    final previous = _transport;
    await _events?.cancel();
    await _status?.cancel();
    _clearCommands();
    _reported
      ..clear()
      ..addEntries([
        for (final device in lastKnown)
          MapEntry(
            device.id,
            device.copyWith(availability: DeviceAvailability.unknown),
          ),
      ]);
    _transport = next;
    _events = next.events.listen(_onEvent);
    _status = next.status.listen(_onStatus);
    _publish();
    if (!_statusOut.isClosed) _statusOut.add(next.currentStatus);
    if (!identical(previous, next)) await previous.disconnect();
    await next.connect();
  }

  Future<void> dispose() async {
    await _events?.cancel();
    await _status?.cancel();
    _clearCommands();
    await _statusOut.close();
    await _views.close();
    await _failures.close();
    await _lateApplies.close();
  }

  /// Applies [patches] optimistically and sends them as one command.
  ///
  /// Completes with the command's outcome. Callers rarely need it: state
  /// arrives through [watchAll] and problems through [failures].
  Future<CommandResult> send(
    String deviceId,
    Map<String, CapabilityPatch> patches,
  ) async {
    final device = _reported[deviceId];
    final command = DeviceCommand(
      id: _commandIds(),
      homeId: device?.homeId ?? '',
      deviceId: deviceId,
      issuedAt: _clock(),
      patches: patches,
    );
    final pending = _PendingCommand(command);
    _pending.add(pending);
    // A new command for the device makes any earlier timed-out one moot.
    _late
        .where((c) => c.command.deviceId == deviceId)
        .toList()
        .forEach(_forget);
    _publish();

    final result = await _transport.send(command, timeout: commandTimeout);
    if (!_pending.contains(pending)) return result;

    if (result.isSuccess) {
      pending.acked = true;
      if (_isSatisfied(pending)) {
        _remove(pending);
      } else {
        // Keep showing the requested value until the device reports it,
        // but not forever.
        pending.settleTimer = Timer(settleTimeout, () => _remove(pending));
      }
    } else {
      _remove(pending);
      final reported = _reported[deviceId];
      if (reported != null && !_failures.isClosed) {
        _failures.add(CommandFailure(device: reported, result: result));
      }
      if (result is CommandTimedOut && !_isSatisfied(pending)) {
        _watchLate(pending);
      }
    }
    return result;
  }

  /// Keeps a timed-out command around for [lateApplyWindow]: a `state` that
  /// matches it within that time means the device applied it after all.
  void _watchLate(_PendingCommand pending) {
    final candidate = _LateCandidate(pending.command);
    candidate.timer = Timer(lateApplyWindow, () => _forget(candidate));
    _late.add(candidate);
  }

  void _forget(_LateCandidate candidate) {
    candidate.timer?.cancel();
    _late.remove(candidate);
  }

  void _clearCommands() {
    for (final pending in _pending) {
      pending.settleTimer?.cancel();
    }
    _pending.clear();
    for (final candidate in _late) {
      candidate.timer?.cancel();
    }
    _late.clear();
  }

  /// Losing the broker drops every optimistic value: commands still waiting
  /// for an ack fail (the transport answers them with `unreachable`), and
  /// acked ones stop waiting for their state. What the devices report after
  /// the reconnect, retained on the broker, is the truth.
  void _onStatus(TransportStatus status) {
    if (!_statusOut.isClosed) _statusOut.add(status);
    if (status == TransportStatus.connected || _pending.isEmpty) return;
    _pending.where((p) => p.acked).toList().forEach(_drop);
    _publish();
  }

  void _onEvent(DeviceEvent event) {
    switch (event) {
      case DeviceAnnounced(:final descriptor):
        final known = _reported[descriptor.id];
        final fresh = Device.fromDescriptor(descriptor, homeId: event.homeId);
        _reported[descriptor.id] = known == null
            ? fresh
            : fresh.copyWith(
                state: known.state,
                availability: known.availability,
                roomId: known.roomId,
              );
      case DeviceStateChanged(:final deviceId, :final state):
        final known = _reported[deviceId];
        if (known == null) return;
        _reported[deviceId] = known.copyWith(state: state);
        // A reported state that matches an acked command ends its overlay.
        _pending
            .where((p) => p.acked && p.command.deviceId == deviceId)
            .where(_isSatisfied)
            .toList()
            .forEach(_drop);
        // One that matches a timed-out command means it was applied late.
        final applied = _late
            .where((c) => c.command.deviceId == deviceId)
            .where((c) => _reported[deviceId]!.satisfies(c.command.patches))
            .toList();
        if (applied.isNotEmpty) {
          applied.forEach(_forget);
          if (!_lateApplies.isClosed) {
            _lateApplies.add(LateApply(device: _reported[deviceId]!));
          }
        }
      case DeviceAvailabilityChanged(:final deviceId, :final availability):
        final known = _reported[deviceId];
        if (known == null) return;
        _reported[deviceId] = known.copyWith(availability: availability);
      case DeviceRemoved(:final deviceId):
        _reported.remove(deviceId);
        _pending
            .where((p) => p.command.deviceId == deviceId)
            .toList()
            .forEach(_drop);
        _late
            .where((c) => c.command.deviceId == deviceId)
            .toList()
            .forEach(_forget);
    }
    _publish();
  }

  bool _isSatisfied(_PendingCommand pending) =>
      _reported[pending.command.deviceId]?.satisfies(pending.command.patches) ??
      false;

  void _drop(_PendingCommand pending) {
    pending.settleTimer?.cancel();
    _pending.remove(pending);
  }

  void _remove(_PendingCommand pending) {
    if (!_pending.contains(pending)) return;
    _drop(pending);
    _publish();
  }

  DeviceView _viewOf(Device reported) {
    var device = reported;
    final pendingCapabilities = <String>{};
    for (final pending in _pending) {
      if (pending.command.deviceId != reported.id) continue;
      device = device.applyPatches(pending.command.patches);
      pendingCapabilities.addAll(pending.command.patches.keys);
    }
    return DeviceView(device: device, pendingCapabilities: pendingCapabilities);
  }

  void _publish() {
    if (!_views.isClosed) _views.add(current);
  }

  static DeviceView? _find(List<DeviceView> views, String deviceId) {
    for (final view in views) {
      if (view.device.id == deviceId) return view;
    }
    return null;
  }
}

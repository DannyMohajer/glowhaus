import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glowhaus_domain/src/capability/capability.dart';
import 'package:glowhaus_domain/src/capability/capability_kind.dart';
import 'package:glowhaus_domain/src/capability/capability_patch.dart';
import 'package:glowhaus_domain/src/capability/capability_state.dart';
import 'package:glowhaus_domain/src/protocol/payloads.dart';

part 'device.freezed.dart';

/// Presentation hint for a device: which icon, which filter chip.
///
/// Behaviour is never derived from the type, only from capabilities.
enum DeviceType {
  light,
  @JsonValue('switch')
  wallSwitch,
  curtain,
  thermostat,
  outlet,
  lock,
  sensor,
  camera,
  unknown,
}

enum DeviceAvailability { online, offline, unknown }

/// The one device model: a type hint, a list of capabilities, their state.
@freezed
abstract class Device with _$Device {
  const factory({
    required String id,
    required String homeId,
    required DeviceType type,
    required String name,
    required List<Capability> capabilities,
    String? roomId,
    String? manufacturer,
    String? model,
    String? firmware,
    @Default(<String, CapabilityState>{}) Map<String, CapabilityState> state,
    @Default(DeviceAvailability.unknown) DeviceAvailability availability,

    /// Translation key of the factory default [name]; null once renamed.
    String? nameKey,
  }) = _Device;

  /// Builds a device from a discovery announce. Room assignment is owned by
  /// the app; the descriptor's `roomHint` is used when [roomId] is not given.
  factory fromDescriptor(
    DeviceDescriptor descriptor, {
    required String homeId,
    String? roomId,
  }) => Device(
    id: descriptor.id,
    homeId: homeId,
    type: descriptor.type,
    name: descriptor.name,
    capabilities: descriptor.capabilities,
    roomId: roomId ?? descriptor.roomHint,
    manufacturer: descriptor.manufacturer,
    model: descriptor.model,
    firmware: descriptor.firmware,
    nameKey: descriptor.nameKey,
  );

  const new _();

  /// A user-chosen name is shown as typed, so renaming drops [nameKey].
  Device renamed(String name) => copyWith(name: name, nameKey: null);

  bool get isOnline => availability == DeviceAvailability.online;

  bool get isOffline => availability == DeviceAvailability.offline;

  Capability? capability(String id) {
    for (final capability in capabilities) {
      if (capability.id == id) return capability;
    }
    return null;
  }

  Iterable<Capability> capabilitiesOf(CapabilityKind kind) =>
      capabilities.where((capability) => capability.kind == kind);

  bool has(CapabilityKind kind) => capabilitiesOf(kind).isNotEmpty;

  /// State of the capability with the given [id], if it is a [T].
  T? stateOf<T extends CapabilityState>(String id) {
    final value = state[id];
    return value is T ? value : null;
  }

  /// State of the first capability (in descriptor order) whose state is a [T].
  T? firstState<T extends CapabilityState>() {
    for (final capability in capabilities) {
      final value = state[capability.id];
      if (value is T) return value;
    }
    return null;
  }

  /// True if any on/off channel is on.
  bool get isOn => state.values.whereType<OnOffState>().any((s) => s.on);

  /// Counts towards "active devices": reachable and doing something.
  bool get isActive {
    if (isOffline) return false;
    final thermostat = firstState<ThermostatState>();
    return isOn ||
        (thermostat != null && thermostat.mode != ThermostatMode.off);
  }

  /// This device with [patches] applied on top of its state (optimistic view).
  Device applyPatches(Map<String, CapabilityPatch> patches) {
    if (patches.isEmpty) return this;
    final next = Map<String, CapabilityState>.of(state);
    for (final MapEntry(key: id, value: patch) in patches.entries) {
      final patched = patch.applyTo(next[id]);
      if (patched != null) next[id] = patched;
    }
    return copyWith(state: next);
  }

  /// Whether the reported state already reflects all of [patches].
  bool satisfies(Map<String, CapabilityPatch> patches) => patches.entries.every(
    (entry) => entry.value.isSatisfiedBy(state[entry.key]),
  );
}

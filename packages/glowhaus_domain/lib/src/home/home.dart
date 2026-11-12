import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glowhaus_domain/src/capability/capability_patch.dart';

part 'home.freezed.dart';
part 'home.g.dart';

/// Presentation hint for a room (icon, illustration).
enum RoomKind {
  livingRoom,
  bedroom,
  kitchen,
  entrance,
  bathroom,
  office,
  other,
}

@freezed
abstract class Room with _$Room {
  const factory({
    required String id,
    required String name,
    @JsonKey(unknownEnumValue: RoomKind.other)
    @Default(RoomKind.other)
    RoomKind kind,

    /// Translation key of a seeded default [name]; null once renamed.
    /// The name itself is always shown as typed when there is no key.
    String? nameKey,
  }) = _Room;

  factory fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  const new _();

  /// A user-chosen name is shown as typed, so renaming drops [nameKey].
  Room renamed(String name) => copyWith(name: name, nameKey: null);
}

enum Role { owner, admin, member, guest }

@freezed
abstract class User with _$User {
  const factory({required String id, required String name}) = _User;

  factory fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// A user's membership of a home.
@freezed
abstract class HomeMember with _$HomeMember {
  const factory({required User user, required Role role}) = _HomeMember;

  factory fromJson(Map<String, dynamic> json) => _$HomeMemberFromJson(json);
}

/// One step of a scene: patches for one device.
@freezed
abstract class SceneAction with _$SceneAction {
  const factory({
    required String deviceId,
    required Map<String, CapabilityPatch> patches,
  }) = _SceneAction;

  factory fromJson(Map<String, dynamic> json) => _$SceneActionFromJson(json);
}

/// A named set of device changes applied together.
@freezed
abstract class Scene with _$Scene {
  const factory({
    required String id,
    required String name,
    @Default(<SceneAction>[]) List<SceneAction> actions,

    /// Translation key of a seeded default [name]; null once renamed.
    /// The name itself is always shown as typed when there is no key.
    String? nameKey,
  }) = _Scene;

  factory fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);

  const new _();

  /// A user-chosen name is shown as typed, so renaming drops [nameKey].
  Scene renamed(String name) => copyWith(name: name, nameKey: null);
}

@freezed
abstract class Home with _$Home {
  const factory({
    required String id,
    required String name,
    @Default(<Room>[]) List<Room> rooms,
    @Default(<Scene>[]) List<Scene> scenes,
    @Default(<HomeMember>[]) List<HomeMember> members,
  }) = _Home;

  factory fromJson(Map<String, dynamic> json) => _$HomeFromJson(json);

  const new _();

  Room? room(String id) {
    for (final room in rooms) {
      if (room.id == id) return room;
    }
    return null;
  }
}

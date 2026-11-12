// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Room _$RoomFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Room', json, ($checkedConvert) {
      final val = _Room(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) =>
              $enumDecodeNullable(
                _$RoomKindEnumMap,
                v,
                unknownValue: RoomKind.other,
              ) ??
              RoomKind.other,
        ),
      );
      return val;
    });

Map<String, dynamic> _$RoomToJson(_Room instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'kind': _$RoomKindEnumMap[instance.kind]!,
};

const _$RoomKindEnumMap = {
  RoomKind.livingRoom: 'livingRoom',
  RoomKind.bedroom: 'bedroom',
  RoomKind.kitchen: 'kitchen',
  RoomKind.entrance: 'entrance',
  RoomKind.bathroom: 'bathroom',
  RoomKind.office: 'office',
  RoomKind.other: 'other',
};

_User _$UserFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_User', json, ($checkedConvert) {
      final val = _User(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

_HomeMember _$HomeMemberFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_HomeMember', json, ($checkedConvert) {
      final val = _HomeMember(
        user: $checkedConvert(
          'user',
          (v) => User.fromJson(v as Map<String, dynamic>),
        ),
        role: $checkedConvert('role', (v) => $enumDecode(_$RoleEnumMap, v)),
      );
      return val;
    });

Map<String, dynamic> _$HomeMemberToJson(_HomeMember instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'role': _$RoleEnumMap[instance.role]!,
    };

const _$RoleEnumMap = {
  Role.owner: 'owner',
  Role.admin: 'admin',
  Role.member: 'member',
  Role.guest: 'guest',
};

_SceneAction _$SceneActionFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_SceneAction',
  json,
  ($checkedConvert) {
    final val = _SceneAction(
      deviceId: $checkedConvert('deviceId', (v) => v as String),
      patches: $checkedConvert(
        'patches',
        (v) => (v as Map<String, dynamic>).map(
          (k, e) =>
              MapEntry(k, CapabilityPatch.fromJson(e as Map<String, dynamic>)),
        ),
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$SceneActionToJson(_SceneAction instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'patches': instance.patches.map((k, e) => MapEntry(k, e.toJson())),
    };

_Scene _$SceneFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Scene', json, ($checkedConvert) {
      final val = _Scene(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        actions: $checkedConvert(
          'actions',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => SceneAction.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const <SceneAction>[],
        ),
      );
      return val;
    });

Map<String, dynamic> _$SceneToJson(_Scene instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'actions': instance.actions.map((e) => e.toJson()).toList(),
};

_Home _$HomeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Home', json, ($checkedConvert) {
      final val = _Home(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        rooms: $checkedConvert(
          'rooms',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => Room.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const <Room>[],
        ),
        scenes: $checkedConvert(
          'scenes',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => Scene.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const <Scene>[],
        ),
        members: $checkedConvert(
          'members',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => HomeMember.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const <HomeMember>[],
        ),
      );
      return val;
    });

Map<String, dynamic> _$HomeToJson(_Home instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'rooms': instance.rooms.map((e) => e.toJson()).toList(),
  'scenes': instance.scenes.map((e) => e.toJson()).toList(),
  'members': instance.members.map((e) => e.toJson()).toList(),
};

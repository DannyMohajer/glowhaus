// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BrokerSettings _$BrokerSettingsFromJson(Map<String, dynamic> json) =>
    _BrokerSettings(
      host: json['host'] as String? ?? 'localhost',
      port: (json['port'] as num?)?.toInt(),
      tls: json['tls'] as bool? ?? true,
      webSocket: json['webSocket'] as bool? ?? false,
      path: json['path'] as String? ?? '/mqtt',
      homeId: json['homeId'] as String? ?? DemoHome.homeId,
      username: json['username'] as String? ?? '${DemoHome.homeId}.app',
      trustedCertificatePem: json['trustedCertificatePem'] as String?,
    );

Map<String, dynamic> _$BrokerSettingsToJson(_BrokerSettings instance) =>
    <String, dynamic>{
      'host': instance.host,
      'port': instance.port,
      'tls': instance.tls,
      'webSocket': instance.webSocket,
      'path': instance.path,
      'homeId': instance.homeId,
      'username': instance.username,
      'trustedCertificatePem': instance.trustedCertificatePem,
    };

_ConnectionSettings _$ConnectionSettingsFromJson(Map<String, dynamic> json) =>
    _ConnectionSettings(
      mode:
          $enumDecodeNullable(_$ConnectionModeEnumMap, json['mode']) ??
          ConnectionMode.demo,
      broker: json['broker'] == null
          ? const BrokerSettings()
          : BrokerSettings.fromJson(json['broker'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConnectionSettingsToJson(_ConnectionSettings instance) =>
    <String, dynamic>{
      'mode': _$ConnectionModeEnumMap[instance.mode]!,
      'broker': instance.broker,
    };

const _$ConnectionModeEnumMap = {
  ConnectionMode.demo: 'demo',
  ConnectionMode.broker: 'broker',
};

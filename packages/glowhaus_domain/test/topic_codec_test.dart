import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:test/test.dart';

void main() {
  const codec = TopicCodec();

  group('build', () {
    test('discovery topic', () {
      expect(codec.discovery('demo-home'), 'glowhaus/demo-home/discovery');
    });

    test('every device channel', () {
      expect(
        {
          for (final channel in DeviceChannel.values)
            channel: codec.device('demo-home', 'lr-lamp', channel),
        },
        {
          DeviceChannel.set: 'glowhaus/demo-home/lr-lamp/set',
          DeviceChannel.state: 'glowhaus/demo-home/lr-lamp/state',
          DeviceChannel.ack: 'glowhaus/demo-home/lr-lamp/ack',
          DeviceChannel.availability: 'glowhaus/demo-home/lr-lamp/availability',
          DeviceChannel.info: 'glowhaus/demo-home/lr-lamp/info',
        },
      );
    });

    test('subscription filter for all devices', () {
      expect(
        codec.allDevicesFilter('demo-home', DeviceChannel.state),
        'glowhaus/demo-home/+/state',
      );
    });

    for (final bad in ['', 'Home', 'a/b', 'a+b', '#', '-home', 'a' * 33]) {
      test('rejects home id "$bad"', () {
        expect(() => codec.discovery(bad), throwsArgumentError);
        expect(
          () => codec.allDevicesFilter(bad, DeviceChannel.ack),
          throwsArgumentError,
        );
      });
    }

    for (final bad in ['', 'discovery', 'Lamp', 'a b', 'x/y', '+']) {
      test('rejects device id "$bad"', () {
        expect(
          () => codec.device('demo-home', bad, DeviceChannel.set),
          throwsArgumentError,
        );
      });
    }
  });

  group('parse', () {
    test('discovery topic', () {
      expect(
        codec.parse('glowhaus/demo-home/discovery'),
        const DiscoveryTopic('demo-home'),
      );
    });

    test('device topics round trip', () {
      for (final channel in DeviceChannel.values) {
        final topic = DeviceTopic('home_1', 'kt-switch', channel);
        expect(codec.parse(codec.build(topic)), topic);
      }
    });

    for (final foreign in [
      '',
      'glowhaus',
      'glowhaus/demo-home',
      'other/demo-home/discovery',
      'glowhaus/demo-home/lr-lamp',
      'glowhaus/demo-home/lr-lamp/unknown',
      'glowhaus/demo-home/lr-lamp/state/extra',
      'glowhaus/demo-home/+/state',
      'glowhaus/demo-home/discovery/set',
      'glowhaus/Demo/lr-lamp/state',
      'glowhaus//lr-lamp/state',
      '/glowhaus/demo-home/lr-lamp/state',
    ]) {
      test('returns null for "$foreign"', () {
        expect(codec.parse(foreign), isNull);
      });
    }
  });

  group('Ids', () {
    test('capability ids', () {
      expect(Ids.isValidCapabilityId('onOff'), isTrue);
      expect(Ids.isValidCapabilityId('ch2'), isTrue);
      expect(Ids.isValidCapabilityId('2ch'), isFalse);
      expect(Ids.isValidCapabilityId('on-off'), isFalse);
    });

    test('command ids', () {
      expect(Ids.isValidCommandId('01JCK3V9M2Q8'), isTrue);
      expect(Ids.isValidCommandId('c-1001_a'), isTrue);
      expect(Ids.isValidCommandId(''), isFalse);
      expect(Ids.isValidCommandId('a' * 65), isFalse);
      expect(Ids.isValidCommandId('a b'), isFalse);
    });
  });
}

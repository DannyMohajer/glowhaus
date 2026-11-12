import 'package:glowhaus_mqtt/glowhaus_mqtt.dart';
import 'package:test/test.dart';

void main() {
  group('matches', () {
    const cases = <(String, String, bool)>[
      ('a/b/c', 'a/b/c', true),
      ('a/b/c', 'a/b/d', false),
      ('a/B/c', 'a/b/c', false),
      ('a/+/c', 'a/b/c', true),
      ('a/+/c', 'a/b/x/c', false),
      ('a/+', 'a/', true),
      ('+', 'a', true),
      ('+', 'a/b', false),
      ('a/#', 'a/b/c', true),
      ('a/#', 'a', true),
      ('#', 'a/b', true),
      ('#', r'$SYS/x', false),
      ('+/x', r'$SYS/x', false),
      (r'$SYS/#', r'$SYS/x', true),
      ('glowhaus/demo-home/+/state', 'glowhaus/demo-home/lr-lamp/state', true),
      ('glowhaus/demo-home/+/state', 'glowhaus/demo-home/lr-lamp/ack', false),
      ('glowhaus/demo-home/+/state', 'glowhaus/other/lr-lamp/state', false),
    ];
    for (final (filter, topic, expected) in cases) {
      test('"$filter" vs "$topic" is $expected', () {
        expect(MqttTopics.matches(filter, topic), expected);
      });
    }
  });

  test('topic names: no wildcards, not empty', () {
    expect(MqttTopics.isValidName('a/b'), isTrue);
    expect(MqttTopics.isValidName('a/'), isTrue);
    expect(MqttTopics.isValidName(''), isFalse);
    expect(MqttTopics.isValidName('a/+'), isFalse);
    expect(MqttTopics.isValidName('a/#'), isFalse);
    expect(MqttTopics.isValidName('a\u0000b'), isFalse);
  });

  test('filters: wildcards only as whole levels, # only last', () {
    expect(MqttTopics.isValidFilter('a/+/c'), isTrue);
    expect(MqttTopics.isValidFilter('a/#'), isTrue);
    expect(MqttTopics.isValidFilter('#'), isTrue);
    expect(MqttTopics.isValidFilter('a+/c'), isFalse);
    expect(MqttTopics.isValidFilter('a/#/c'), isFalse);
    expect(MqttTopics.isValidFilter('a/b#'), isFalse);
    expect(MqttTopics.isValidFilter(''), isFalse);
  });
}

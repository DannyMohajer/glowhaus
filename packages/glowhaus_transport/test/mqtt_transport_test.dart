import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_mqtt/glowhaus_mqtt.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:test/test.dart';

const _home = 'demo-home';
const _topics = TopicCodec();
final _epoch = DateTime.utc(2026, 11, 13, 12);

/// The smallest protocol-compliant device: a lamp on the broker that
/// announces on query, acks every command and reports its state. It is the
/// other side of the conversation, written only from docs/protocol.md.
class _BrokerLamp {
  new(this.broker, {this.clock, this.id = 'lr-lamp'});

  final InMemoryBroker broker;
  final String id;
  DateTime Function()? clock;
  late final MqttConnection connection = broker.client();
  final seenCommandIds = <String>[];
  final handledCommandIds = <String>[];
  bool on = false;
  bool silent = false;

  /// Error to ack with, or null to accept.
  ProtocolErrorCode? rejectWith;

  DeviceDescriptor get descriptor => DeviceDescriptor(
    id: id,
    type: DeviceType.light,
    name: 'Lamp',
    capabilities: [Capability.of(CapabilityKind.onOff)],
  );

  int get _ts => (clock?.call() ?? DateTime.now()).millisecondsSinceEpoch;

  Future<void> start() async {
    connection.messages.listen(_onMessage);
    await connection.connect(
      clientId: 'device-$id',
      will: MqttWill.text(
        _topics.device(_home, id, DeviceChannel.availability),
        jsonEncode(
          const AvailabilityPayload(status: AvailabilityStatus.offline)
              .toJson(),
        ),
        retain: true,
      ),
    );
    await connection.subscribe(_topics.device(_home, id, DeviceChannel.set));
    await connection.subscribe(
      _topics.discovery(_home),
      qos: MqttQos.atMostOnce,
    );
    await _publishAvailability();
    await _publishState();
    await _announce();
  }

  Future<void> _announce() => connection.publishText(
    _topics.discovery(_home),
    jsonEncode(DiscoveryMessage.announce(ts: _ts, device: descriptor).toJson()),
    qos: MqttQos.atMostOnce,
  );

  Future<void> _publishAvailability() => connection.publishText(
    _topics.device(_home, id, DeviceChannel.availability),
    jsonEncode(
      AvailabilityPayload(status: AvailabilityStatus.online, ts: _ts).toJson(),
    ),
    retain: true,
  );

  Future<void> _publishState() => connection.publishText(
    _topics.device(_home, id, DeviceChannel.state),
    jsonEncode(
      StatePayload.encode({
        'onOff': CapabilityState.onOff(on: on),
      }, ts: _ts).toJson(),
    ),
    retain: true,
  );

  /// Discovery queries this device has answered.
  int queries = 0;

  Future<void> _onMessage(MqttMessage message) async {
    final topic = _topics.parse(message.topic);
    if (topic is DiscoveryTopic) {
      // Section 4: ignore what cannot be parsed.
      final json = jsonDecode(message.text);
      if (json is Map<String, dynamic> && json['type'] == 'query') {
        queries++;
        await _announce();
      }
      return;
    }
    if (topic is! DeviceTopic || topic.channel != DeviceChannel.set) return;
    if (message.retained) return;
    final payload = SetPayload.fromJson(
      jsonDecode(message.text) as Map<String, dynamic>,
    );
    seenCommandIds.add(payload.commandId);
    if (silent) return;
    // Section 8.1: a redelivered command is acked again, not applied again.
    final fresh = !handledCommandIds.contains(payload.commandId);
    if (fresh) handledCommandIds.add(payload.commandId);
    final error = rejectWith;
    await connection.publishText(
      _topics.device(_home, id, DeviceChannel.ack),
      jsonEncode(
        AckPayload(
          commandId: payload.commandId,
          ok: error == null,
          ts: _ts,
          error: error == null ? null : AckError(code: error),
        ).toJson(),
      ),
    );
    if (error == null && fresh) {
      final patch = payload.decode(descriptor.capabilities).patches['onOff'];
      if (patch is OnOffPatch) on = patch.on;
      await _publishState();
    }
  }
}

class _Harness {
  new(this.async, {InMemoryBroker? broker})
    : broker = broker ?? InMemoryBroker() {
    transport = MqttTransport(
      homeId: _home,
      connection: this.broker.client(),
      clientId: 'app-test',
      clock: now,
      random: Random(3),
      reconnectPolicy: const ReconnectPolicy(jitter: 0),
    );
    transport.events.listen(events.add);
    transport.status.listen(statuses.add);
    lamp = _BrokerLamp(this.broker, clock: now);
  }

  final FakeAsync async;
  final InMemoryBroker broker;
  late final MqttTransport transport;
  late final _BrokerLamp lamp;
  final events = <DeviceEvent>[];
  final statuses = <TransportStatus>[];
  var _count = 0;

  DateTime now() => _epoch.add(async.elapsed);

  void startLamp() {
    unawaited(lamp.start());
    async.flushMicrotasks();
  }

  void connect() {
    unawaited(transport.connect());
    async.flushMicrotasks();
  }

  DeviceCommand command({bool on = true}) => DeviceCommand(
    id: 'cmd-${_count++}',
    homeId: _home,
    deviceId: lamp.id,
    issuedAt: now(),
    patches: {'onOff': CapabilityPatch.onOff(on: on)},
  );

  /// Sends and returns whatever the result was once [wait] has passed.
  CommandResult? send(DeviceCommand command, {Duration wait = Duration.zero}) {
    CommandResult? result;
    unawaited(transport.send(command).then((r) => result = r));
    async.flushMicrotasks();
    if (wait > Duration.zero) async.elapse(wait);
    return result;
  }

  List<Type> get eventTypes => [for (final e in events) e.runtimeType];
}

void main() {
  test('connects, subscribes, queries and learns the devices', () {
    fakeAsync((async) {
      final h = _Harness(async)
        ..startLamp()
        ..connect();
      expect(h.statuses, [
        TransportStatus.connecting,
        TransportStatus.connected,
      ]);
      expect(h.broker.connectedClientIds, contains('app-test'));

      // Retained availability and state arrived before the announce (the
      // announce answers the query); the transport held them back.
      expect(h.eventTypes, [
        DeviceAnnounced,
        DeviceAvailabilityChanged,
        DeviceStateChanged,
      ]);
      final state = h.events[2] as DeviceStateChanged;
      expect(state.state['onOff'], const CapabilityState.onOff(on: false));
      expect(state.at, _epoch);
      expect(
        (h.events[1] as DeviceAvailabilityChanged).availability,
        DeviceAvailability.online,
      );
    });
  });

  test('a command is acked and the new state follows', () {
    fakeAsync((async) {
      final h = _Harness(async)
        ..startLamp()
        ..connect();
      final before = h.events.length;
      final result = h.send(h.command());
      expect(result, isA<CommandAcked>());
      expect(h.lamp.handledCommandIds, ['cmd-0']);
      final state = h.events.sublist(before).whereType<DeviceStateChanged>();
      expect(
        state.single.state['onOff'],
        const CapabilityState.onOff(on: true),
      );
      expect(
        h.broker.retained(_topics.device(_home, 'lr-lamp', DeviceChannel.set)),
        isNull,
        reason: 'set is never retained',
      );
    });
  });

  test('a rejected command fails with the device error code', () {
    fakeAsync((async) {
      final h = _Harness(async)
        ..startLamp()
        ..connect();
      h.lamp.rejectWith = ProtocolErrorCode.busy;
      final result = h.send(h.command());
      expect(result, isA<CommandFailed>());
      expect((result! as CommandFailed).code, ProtocolErrorCode.busy);
    });
  });

  test('no ack within the timeout: timedOut; a late ack is ignored', () {
    fakeAsync((async) {
      final h = _Harness(async)
        ..startLamp()
        ..connect();
      h.lamp.silent = true;
      expect(h.send(h.command()), isNull);
      expect(
        h.send(h.command(), wait: const Duration(seconds: 5)),
        isA<CommandTimedOut>(),
      );
      // A late ack for a forgotten command changes nothing.
      h.lamp.silent = false;
      unawaited(
        h.lamp.connection.publishText(
          _topics.device(_home, 'lr-lamp', DeviceChannel.ack),
          jsonEncode(const AckPayload(commandId: 'cmd-0', ok: true).toJson()),
        ),
      );
      async.flushMicrotasks();
      expect(h.lamp.seenCommandIds, ['cmd-0', 'cmd-1']);
    });
  });

  test('duplicate set and duplicate ack are handled once', () {
    fakeAsync((async) {
      final h =
          _Harness(
              async,
              broker: InMemoryBroker(qos1DuplicateRate: 1, random: Random(1)),
            )
            ..startLamp()
            ..connect();
      final results = <CommandResult>[];
      unawaited(h.transport.send(h.command()).then(results.add));
      async
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 6));

      expect(h.lamp.seenCommandIds, ['cmd-0', 'cmd-0'], reason: 'redelivered');
      expect(h.lamp.handledCommandIds, ['cmd-0'], reason: 'applied once');
      expect(results, [const CommandResult.acked(commandId: 'cmd-0')]);
      expect(
        h.events.whereType<DeviceStateChanged>().length,
        greaterThanOrEqualTo(1),
      );
    });
  });

  test('acks for commands this app did not send are ignored', () {
    fakeAsync((async) {
      final h = _Harness(async)
        ..startLamp()
        ..connect();
      final other = h.broker.client();
      unawaited(
        other
            .connect(clientId: 'other-app')
            .then(
              (_) => other.publishText(
                _topics.device(_home, 'lr-lamp', DeviceChannel.ack),
                jsonEncode(
                  const AckPayload(commandId: 'theirs', ok: true).toJson(),
                ),
              ),
            ),
      );
      async.flushMicrotasks();
      expect(h.transport.currentStatus, TransportStatus.connected);
    });
  });

  test('malformed and future-version payloads are dropped', () {
    fakeAsync((async) {
      final h = _Harness(async)
        ..startLamp()
        ..connect();
      final before = h.events.length;
      final rogue = h.broker.client();
      unawaited(
        rogue.connect(clientId: 'rogue').then((_) async {
          final state = _topics.device(_home, 'lr-lamp', DeviceChannel.state);
          await rogue.publishText(state, 'not json');
          await rogue.publishText(state, '[1,2]');
          await rogue.publishText(state, '{"v": 2, "ts": 1, "state": {}}');
          await rogue.publishText(state, '{"v": 1}');
          await rogue.publishText(
            _topics.discovery(_home),
            '{"v": 1, "type": "announce"}',
          );
          await rogue.publishText('glowhaus/other-home/lr-lamp/state', '{}');
        }),
      );
      async.flushMicrotasks();
      expect(h.events.length, before);
    });
  });

  test('sending while disconnected is unreachable at once', () {
    fakeAsync((async) {
      final h = _Harness(async);
      expect(h.send(h.command()), isA<CommandUnreachable>());
      expect(
        h.send(
          DeviceCommand(
            id: 'x',
            homeId: 'other-home',
            deviceId: 'lr-lamp',
            issuedAt: h.now(),
            patches: const {},
          ),
        ),
        isA<CommandUnreachable>(),
        reason: 'wrong home',
      );
    });
  });

  group('losing the broker', () {
    test('pending commands fail as unreachable; devices are not offline', () {
      fakeAsync((async) {
        final h = _Harness(async)
          ..startLamp()
          ..connect();
        h.lamp.silent = true;
        final results = <CommandResult>[];
        unawaited(h.transport.send(h.command()).then(results.add));
        async.flushMicrotasks();
        final before = h.events.length;

        h.broker.drop('app-test');
        async.flushMicrotasks();
        expect(results, [const CommandResult.unreachable(commandId: 'cmd-0')]);
        expect(h.transport.currentStatus, TransportStatus.reconnecting);
        expect(h.events.length, before, reason: 'no availability change');
        expect(h.send(h.command()), isA<CommandUnreachable>());
      });
    });

    test('reconnects with backoff, re-subscribes and re-queries', () {
      fakeAsync((async) {
        final h = _Harness(async)
          ..startLamp()
          ..connect();
        // The lamp flips while the app is away; the retained state wins
        // after the reconnect.
        h.broker.drop('app-test');
        async.flushMicrotasks();
        h.lamp.on = true;
        unawaited(h.lamp._publishState());
        async.flushMicrotasks();
        final before = h.events.length;

        async.elapse(const Duration(milliseconds: 999));
        expect(h.transport.currentStatus, TransportStatus.reconnecting);
        async.elapse(const Duration(milliseconds: 1));
        expect(h.transport.currentStatus, TransportStatus.connected);
        expect(h.transport.reconnectAttempts, 0);
        // The device is still known, so the retained state and availability
        // pass straight through. Its announce answers the new query, but an
        // unchanged descriptor is not reported twice.
        expect(h.eventTypes.sublist(before), [
          DeviceStateChanged,
          DeviceAvailabilityChanged,
        ]);
        expect(h.lamp.queries, greaterThan(1), reason: 're-queried');
        expect(
          (h.events[before] as DeviceStateChanged).state['onOff'],
          const CapabilityState.onOff(on: true),
        );
        expect(h.send(h.command(on: false)), isA<CommandAcked>());
      });
    });

    test('backoff doubles up to the maximum while the broker is down', () {
      fakeAsync((async) {
        final h = _Harness(async)
          ..startLamp()
          ..connect();
        unawaited(h.broker.close());
        async.flushMicrotasks();
        expect(h.transport.currentStatus, TransportStatus.reconnecting);
        // The first retry is scheduled at once; each failed attempt
        // schedules the next: 1 s, 2 s, 4 s, 8 s, 16 s, 30 s, 30 s ...
        expect(h.transport.reconnectAttempts, 1);
        for (final seconds in [1, 2, 4, 8, 16, 30, 30]) {
          async.elapse(Duration(seconds: seconds));
        }
        expect(h.transport.reconnectAttempts, 8);
        expect(h.transport.currentStatus, TransportStatus.reconnecting);
      });
    });

    test('a first connection that fails keeps trying', () {
      fakeAsync((async) {
        final broker = InMemoryBroker();
        final h = _Harness(async, broker: broker);
        unawaited(broker.close());
        h.connect();
        expect(h.transport.currentStatus, TransportStatus.connecting);
        async.elapse(const Duration(seconds: 5));
        expect(h.transport.currentStatus, TransportStatus.connecting);
        expect(h.transport.reconnectAttempts, greaterThan(1));
      });
    });
  });

  test('disconnect is clean: no reconnect, pending commands unreachable', () {
    fakeAsync((async) {
      final h = _Harness(async)
        ..startLamp()
        ..connect();
      h.lamp.silent = true;
      final results = <CommandResult>[];
      unawaited(h.transport.send(h.command()).then(results.add));
      async.flushMicrotasks();
      unawaited(h.transport.disconnect());
      async.flushMicrotasks();
      expect(results, [const CommandResult.unreachable(commandId: 'cmd-0')]);
      expect(h.transport.currentStatus, TransportStatus.disconnected);
      async.elapse(const Duration(minutes: 1));
      expect(h.transport.currentStatus, TransportStatus.disconnected);
      expect(h.broker.connectedClientIds, isNot(contains('app-test')));

      // And it can connect again.
      h.connect();
      expect(h.transport.currentStatus, TransportStatus.connected);
    });
  });

  test('a device that says goodbye is removed', () {
    fakeAsync((async) {
      final h = _Harness(async)
        ..startLamp()
        ..connect();
      unawaited(
        h.lamp.connection.publishText(
          _topics.discovery(_home),
          jsonEncode(
            const DiscoveryMessage.bye(ts: 1, deviceId: 'lr-lamp').toJson(),
          ),
          qos: MqttQos.atMostOnce,
        ),
      );
      async.flushMicrotasks();
      expect(h.events.last, isA<DeviceRemoved>());
    });
  });

  test("a device's will marks it offline, the broker link does not", () {
    fakeAsync((async) {
      final h = _Harness(async)
        ..startLamp()
        ..connect();
      h.broker.drop('device-lr-lamp');
      async.flushMicrotasks();
      final change = h.events.last as DeviceAvailabilityChanged;
      expect(change.availability, DeviceAvailability.offline);
    });
  });

  test('lost discovery (QoS 0): the query is repeated until every device '
      'with retained state has announced', () {
    fakeAsync((async) {
      // Three in ten QoS 0 messages vanish: queries and announces alike.
      final broker = InMemoryBroker(qos0LossRate: 0.3, random: Random(11));
      final h = _Harness(async, broker: broker);
      final lamps = [
        for (final id in ['lr-a', 'lr-b', 'lr-c', 'lr-d', 'lr-e'])
          _BrokerLamp(broker, clock: h.now, id: id),
      ];
      for (final lamp in lamps) {
        unawaited(lamp.start());
      }
      async.flushMicrotasks();
      h.connect();

      Set<String> announced() => {
        for (final e in h.events.whereType<DeviceAnnounced>()) e.deviceId,
      };
      expect(announced().length, lessThan(5), reason: 'some announce was lost');

      // Retries at 3 s, 6 s, 12 s, 24 s, 30 s ... until nothing is missing.
      async.elapse(const Duration(minutes: 3));
      expect(announced(), {'lr-a', 'lr-b', 'lr-c', 'lr-d', 'lr-e'});
      expect(h.transport.discoveryRetries, greaterThan(0));
      expect(h.transport.discoveryRetries, lessThanOrEqualTo(8));
      // Every device got its retained state and availability too.
      for (final id in ['lr-a', 'lr-b', 'lr-c', 'lr-d', 'lr-e']) {
        expect(
          h.events.whereType<DeviceStateChanged>().map((e) => e.deviceId),
          contains(id),
        );
      }
      // Once everything is known, the retries stop.
      final retries = h.transport.discoveryRetries;
      async.elapse(const Duration(minutes: 3));
      expect(h.transport.discoveryRetries, retries);
    });
  });

  test('no retained messages, no retry', () {
    fakeAsync((async) {
      final h = _Harness(async)..connect();
      async.elapse(const Duration(minutes: 2));
      expect(h.transport.discoveryRetries, 0);
    });
  });

  test('reconnect delays are jittered', () {
    const policy = ReconnectPolicy();
    final random = Random(42);
    final delays = [for (var i = 0; i < 20; i++) policy.delay(0, random)];
    expect(delays.toSet().length, greaterThan(1));
    for (final delay in delays) {
      expect(delay.inMilliseconds, inInclusiveRange(500, 1500));
    }
    expect(policy.delay(10, random).inSeconds, inInclusiveRange(15, 45));
  });

  group('revision 1.1: retained info', () {
    const motion = DeviceDescriptor(
      id: 'kt-motion',
      type: DeviceType.sensor,
      name: 'Motion sensor',
      capabilities: [
        Capability(id: 'motionSensor', kind: CapabilityKind.motionSensor),
      ],
    );

    /// What a 1.1 device leaves behind when it has been online once and is
    /// now unplugged: info and an offline availability, both retained, and
    /// nobody left to answer a query.
    Future<void> leaveOfflineDevice(InMemoryBroker broker) async {
      final device = broker.client();
      await device.connect(clientId: 'device-kt-motion');
      await device.publishText(
        _topics.device(_home, motion.id, DeviceChannel.info),
        jsonEncode(const InfoPayload(ts: 1, device: motion).toJson()),
        retain: true,
      );
      await device.publishText(
        _topics.device(_home, motion.id, DeviceChannel.availability),
        jsonEncode(
          const AvailabilityPayload(status: AvailabilityStatus.offline)
              .toJson(),
        ),
        retain: true,
      );
      await device.disconnect();
    }

    test('an app that connects later still learns an offline device', () {
      fakeAsync((async) {
        final broker = InMemoryBroker();
        unawaited(leaveOfflineDevice(broker));
        async.flushMicrotasks();

        final h = _Harness(async, broker: broker)..connect();
        expect(h.eventTypes, [DeviceAnnounced, DeviceAvailabilityChanged]);
        expect((h.events.first as DeviceAnnounced).descriptor, motion);
        expect(
          (h.events.last as DeviceAvailabilityChanged).availability,
          DeviceAvailability.offline,
        );

        // Known from its info, so there is nothing to keep querying for.
        async.elapse(const Duration(minutes: 2));
        expect(h.transport.discoveryRetries, 0);
        unawaited(h.transport.dispose());
        async.flushMicrotasks();
      });
    });

    test('an emptied info removes the device', () {
      fakeAsync((async) {
        final broker = InMemoryBroker();
        unawaited(leaveOfflineDevice(broker));
        async.flushMicrotasks();
        final h = _Harness(async, broker: broker)..connect();
        h.events.clear();

        final remover = broker.client();
        unawaited(
          remover
              .connect(clientId: 'remover')
              .then(
                (_) => remover.publish(
                  _topics.device(_home, motion.id, DeviceChannel.info),
                  Uint8List(0),
                  retain: true,
                ),
              ),
        );
        async.flushMicrotasks();
        expect(h.events.single, isA<DeviceRemoved>());
        expect(
          broker.retained(_topics.device(_home, motion.id, DeviceChannel.info)),
          isNull,
          reason: 'and the broker no longer keeps it',
        );
        unawaited(h.transport.dispose());
        async.flushMicrotasks();
      });
    });

    test("an info on one device's topic about another is ignored", () {
      fakeAsync((async) {
        final broker = InMemoryBroker();
        final h = _Harness(async, broker: broker)..connect();
        final other = broker.client();
        unawaited(
          other
              .connect(clientId: 'other')
              .then(
                (_) => other.publishText(
                  _topics.device(_home, 'lr-lamp', DeviceChannel.info),
                  jsonEncode(const InfoPayload(ts: 1, device: motion).toJson()),
                  retain: true,
                ),
              ),
        );
        async.flushMicrotasks();
        expect(h.events, isEmpty);
        unawaited(h.transport.dispose());
        async.flushMicrotasks();
      });
    });
  });
}

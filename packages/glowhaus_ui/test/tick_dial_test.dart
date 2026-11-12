import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import 'support.dart';

/// A 280 px dial for 16..30 in 0.5 steps that keeps its own value.
class _Dial extends StatefulWidget {
  const new({this.enabled = true});

  final bool enabled;

  @override
  State<_Dial> createState() => _DialState();
}

class _DialState extends State<_Dial> {
  double value = 20;
  final changes = <double>[];
  final ends = <double>[];

  @override
  Widget build(BuildContext context) {
    return TickDial(
      value: value,
      min: 16,
      max: 30,
      valueLabel: '${value.toStringAsFixed(1)}°',
      caption: 'Heating to',
      minLabel: '16°',
      maxLabel: '30°',
      semanticLabel: 'Temperature',
      onChanged: widget.enabled
          ? (v) => setState(() {
              value = v;
              changes.add(v);
            })
          : null,
      onChangeEnd: ends.add,
    );
  }
}

void main() {
  _DialState stateOf(WidgetTester tester) =>
      tester.state<_DialState>(find.byType(_Dial));

  /// A point on the dial, as a fraction of its size from the top left.
  Offset at(WidgetTester tester, double fx, double fy) {
    final rect = tester.getRect(find.byType(TickDial));
    return rect.topLeft + Offset(rect.width * fx, rect.height * fy);
  }

  testWidgets('shows value, caption and range labels', (tester) async {
    await tester.pumpWidget(host(const _Dial()));
    expect(find.text('20.0°'), findsOneWidget);
    expect(find.text('Heating to'), findsOneWidget);
    expect(find.text('16°'), findsOneWidget);
    expect(find.text('30°'), findsOneWidget);
    expect(tester.getSize(find.byType(TickDial)), const Size(280, 280));
  });

  testWidgets('tap at the top sets the middle of the range', (tester) async {
    await tester.pumpWidget(host(const _Dial()));
    await tester.tapAt(at(tester, 0.5, 0.05));
    await tester.pump();
    expect(stateOf(tester).value, 23);
    expect(stateOf(tester).ends, [23]);
    expect(find.text('23.0°'), findsOneWidget);
  });

  testWidgets('values snap to the step', (tester) async {
    await tester.pumpWidget(host(const _Dial()));
    // Straight left of centre: one sixth of the sweep = 18.33 -> 18.5.
    await tester.tapAt(at(tester, 0.05, 0.5));
    await tester.pump();
    expect(stateOf(tester).value, 18.5);
  });

  testWidgets('dragging along the arc raises the value, ends once', (
    tester,
  ) async {
    await tester.pumpWidget(host(const _Dial()));
    final gesture = await tester.startGesture(at(tester, 0.05, 0.5));
    for (final (fx, fy) in [(0.1, 0.3), (0.3, 0.1), (0.5, 0.05), (0.7, 0.1)]) {
      await gesture.moveTo(at(tester, fx, fy));
      await tester.pump();
    }
    await gesture.moveTo(at(tester, 0.95, 0.5));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    final state = stateOf(tester);
    expect(state.changes.length, greaterThanOrEqualTo(4));
    expect(state.changes, orderedEquals([...state.changes]..sort()));
    expect(state.value, 27.5);
    expect(state.ends, [27.5]);
  });

  testWidgets('the gap at the bottom sticks to the nearer end', (tester) async {
    await tester.pumpWidget(host(const _Dial()));
    await tester.tapAt(at(tester, 0.4, 0.95));
    await tester.pump();
    expect(stateOf(tester).value, 16);
    await tester.tapAt(at(tester, 0.6, 0.95));
    await tester.pump();
    expect(stateOf(tester).value, 30);
  });

  testWidgets('mirrors in RTL: low values on the right', (tester) async {
    await tester.pumpWidget(host(const _Dial(), direction: TextDirection.rtl));
    await tester.tapAt(at(tester, 0.05, 0.5));
    await tester.pump();
    expect(stateOf(tester).value, 27.5);
    await tester.tapAt(at(tester, 0.95, 0.5));
    await tester.pump();
    expect(stateOf(tester).value, 18.5);
    // The minimum label sits at the start side, which is now the right.
    expect(
      tester.getCenter(find.text('16°')).dx,
      greaterThan(tester.getCenter(find.text('30°')).dx),
    );
  });

  testWidgets('wins the gesture inside a vertical scroll view', (tester) async {
    await tester.pumpWidget(
      host(
        center: false,
        ListView(
          children: const [
            Center(child: _Dial()),
            SizedBox(height: 2000),
          ],
        ),
      ),
    );
    await tester.dragFrom(at(tester, 0.5, 0.1), const Offset(0, 120));
    await tester.pump();
    expect(stateOf(tester).changes, isNotEmpty);
    expect(tester.getTopLeft(find.byType(TickDial)).dy, 0);
  });

  testWidgets('disabled: ignores input', (tester) async {
    await tester.pumpWidget(host(const _Dial(enabled: false)));
    await tester.tapAt(at(tester, 0.5, 0.05));
    await tester.pump();
    expect(stateOf(tester).value, 20);
    expect(stateOf(tester).ends, isEmpty);
  });

  testWidgets('is a slider for assistive tech, adjustable by step', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(const _Dial()));
    final node = tester.getSemantics(find.bySemanticsLabel('Temperature'));
    expect(node.value, '20.0°');
    expect(node.flagsCollection.isSlider, isTrue);

    tester.binding.performSemanticsAction(
      SemanticsActionEvent(
        type: SemanticsAction.increase,
        nodeId: node.id,
        viewId: tester.view.viewId,
      ),
    );
    await tester.pump();
    expect(stateOf(tester).value, 20.5);
    expect(stateOf(tester).ends, [20.5]);
    handle.dispose();
  });
}

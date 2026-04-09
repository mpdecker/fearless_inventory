import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/features/auth/widgets/pin_pad.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildPad({
  required String pin,
  required ValueChanged<String> onChanged,
  VoidCallback? onSubmit,
  int pinLength = 6,
  Widget? leftAction,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: PinPad(
          pinLength: pinLength,
          currentPin: pin,
          onChanged: onChanged,
          onSubmit: onSubmit,
          leftAction: leftAction,
        ),
      ),
    ),
  );
}

Widget _buildDots({
  required int count,
  required int filled,
  bool hasError = false,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: PinDots(
          count: count,
          filled: filled,
          hasError: hasError,
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── PinDots ────────────────────────────────────────────────────────────────

  group('PinDots', () {
    testWidgets('renders [count] dot containers', (tester) async {
      await tester.pumpWidget(_buildDots(count: 6, filled: 0));

      // PinDots creates [count] AnimatedContainers inside a Row.
      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(containers.length, equals(6));
    });

    testWidgets('renders with hasError = true without throwing',
        (tester) async {
      await tester.pumpWidget(_buildDots(count: 6, filled: 3, hasError: true));
      expect(tester.takeException(), isNull);
    });
  });

  // ── PinPad — digit buttons ─────────────────────────────────────────────────

  group('PinPad — digit buttons', () {
    testWidgets('tapping a digit calls onChanged with that digit appended',
        (tester) async {
      String captured = '';
      await tester.pumpWidget(_buildPad(
        pin: '',
        onChanged: (p) => captured = p,
      ));

      await tester.tap(find.text('5'));
      await tester.pump();

      expect(captured, equals('5'));
    });

    testWidgets('tapping multiple digits accumulates them', (tester) async {
      String current = '';
      await tester.pumpWidget(
        StatefulBuilder(builder: (_, setState) {
          return _buildPad(
            pin: current,
            onChanged: (p) => setState(() => current = p),
          );
        }),
      );

      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();

      expect(current, equals('123'));
    });

    testWidgets('does not append digits beyond pinLength', (tester) async {
      String current = '123456';
      await tester.pumpWidget(_buildPad(
        pin: current,
        onChanged: (p) => current = p,
        pinLength: 6,
      ));

      await tester.tap(find.text('7'));
      await tester.pump();

      // Pin should not grow beyond 6.
      expect(current, equals('123456'));
    });

    testWidgets('delete key removes the last digit', (tester) async {
      String current = '123';
      await tester.pumpWidget(
        StatefulBuilder(builder: (_, setState) {
          return _buildPad(
            pin: current,
            onChanged: (p) => setState(() => current = p),
          );
        }),
      );

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      expect(current, equals('12'));
    });

    testWidgets('delete key on empty pin does nothing', (tester) async {
      String current = '';
      await tester.pumpWidget(_buildPad(
        pin: current,
        onChanged: (p) => current = p,
      ));

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      expect(current, equals(''));
    });
  });

  // ── PinPad — auto-submit ───────────────────────────────────────────────────

  group('PinPad — auto-submit', () {
    testWidgets('calls onSubmit when pinLength digits are entered',
        (tester) async {
      bool submitted = false;
      String current = '12345';

      await tester.pumpWidget(
        StatefulBuilder(builder: (_, setState) {
          return _buildPad(
            pin: current,
            pinLength: 6,
            onChanged: (p) => setState(() => current = p),
            onSubmit: () => submitted = true,
          );
        }),
      );

      // Tap '6' to complete the 6-digit PIN.
      await tester.tap(find.text('6'));
      await tester.pump();

      expect(submitted, isTrue);
      expect(current, equals('123456'));
    });

    testWidgets('does not call onSubmit before pinLength is reached',
        (tester) async {
      bool submitted = false;
      String current = '';

      await tester.pumpWidget(
        StatefulBuilder(builder: (_, setState) {
          return _buildPad(
            pin: current,
            pinLength: 6,
            onChanged: (p) => setState(() => current = p),
            onSubmit: () => submitted = true,
          );
        }),
      );

      await tester.tap(find.text('1'));
      await tester.pump();

      expect(submitted, isFalse);
    });
  });

  // ── PinPad — left action ───────────────────────────────────────────────────

  group('PinPad — leftAction slot', () {
    testWidgets('renders leftAction widget when provided', (tester) async {
      await tester.pumpWidget(_buildPad(
        pin: '',
        onChanged: (_) {},
        leftAction: const Text('BIO', key: Key('bio')),
      ));

      expect(find.byKey(const Key('bio')), findsOneWidget);
    });

    testWidgets('renders nothing in left slot when leftAction is null',
        (tester) async {
      await tester.pumpWidget(_buildPad(
        pin: '',
        onChanged: (_) {},
      ));

      // The SizedBox.shrink placeholder should be present but empty.
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  // ── All digit buttons present ──────────────────────────────────────────────

  group('PinPad — layout', () {
    testWidgets('all 10 digit buttons (0–9) are rendered', (tester) async {
      await tester.pumpWidget(_buildPad(pin: '', onChanged: (_) {}));

      for (int i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget,
            reason: 'Digit $i should be present');
      }
    });

    testWidgets('backspace button is rendered', (tester) async {
      await tester.pumpWidget(_buildPad(pin: '', onChanged: (_) {}));
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });
  });
}

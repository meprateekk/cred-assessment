import 'package:cred_assesment/models/bill_model.dart';
import 'package:cred_assesment/widgets/flipper_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlipperWidget', () {
    testWidgets('shows final stage when items are empty', (tester) async {
      const config = FlipperConfig(
        items: [],
        delayMs: 500,
        finalStageText: 'DUE TODAY',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FlipperWidget(config: config)),
        ),
      );

      expect(find.text('DUE TODAY'), findsOneWidget);
    });

    testWidgets('flips through items and settles on final stage', (
      tester,
    ) async {
      const config = FlipperConfig(
        items: ['GET 1% BACK', 'DUE TODAY'],
        delayMs: 200,
        flipCount: 1,
        finalStageText: 'DUE TODAY',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FlipperWidget(config: config)),
        ),
      );

      expect(find.text('GET 1% BACK'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.text('DUE TODAY'), findsOneWidget);
    });
  });
}

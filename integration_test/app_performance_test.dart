import 'dart:ui';

import 'package:cred_assesment/main.dart';
import 'package:cred_assesment/models/bill_model.dart';
import 'package:cred_assesment/models/bill_scenario.dart';
import 'package:cred_assesment/models/bills_section.dart';
import 'package:cred_assesment/services/bill_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('vertical carousel swipe stays within the frame budget', (
    tester,
  ) async {
    final timings = <FrameTiming>[];

    void timingsCallback(List<FrameTiming> values) {
      timings.addAll(values);
    }

    SchedulerBinding.instance.addTimingsCallback(timingsCallback);

    await tester.pumpWidget(MyApp(repository: FakeBillRepository()));
    await tester.pumpAndSettle();

    final carousel = find.byKey(const Key('bills-carousel'));
    expect(carousel, findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.fling(carousel, const Offset(0, -500), 1800);
      await tester.pumpAndSettle();
    }

    await tester.pump(const Duration(milliseconds: 250));
    SchedulerBinding.instance.removeTimingsCallback(timingsCallback);

    expect(timings, isNotEmpty);

    final droppedFrames = timings.where((timing) {
      return timing.buildDuration > const Duration(milliseconds: 16) ||
          timing.rasterDuration > const Duration(milliseconds: 16);
    }).length;

    expect(droppedFrames, lessThanOrEqualTo(3));
  });
}

class FakeBillRepository extends BillRepository {
  @override
  Future<BillsSection> fetchSection(BillScenario scenario) async {
    return BillsSection(
      title: 'UPCOMING BILLS',
      scenario: BillScenario.manyItems,
      billCountLabel: '9',
      bills: List.generate(
        9,
        (index) => Bill(
          title: 'Bill ${index + 1}',
          subTitle: 'Subtitle ${index + 1}',
          logoUrl: 'https://example.com/logo${index + 1}.png',
          amount: '₹${(index + 1) * 100}',
          paymentTitle: 'Pay ₹${(index + 1) * 100}',
          footerText: 'due today',
        ),
      ),
    );
  }
}

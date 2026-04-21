import 'package:cred_assesment/main.dart';
import 'package:cred_assesment/models/bill_model.dart';
import 'package:cred_assesment/models/bill_scenario.dart';
import 'package:cred_assesment/models/bills_section.dart';
import 'package:cred_assesment/services/bill_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  testWidgets('app toggles between many-items and two-items states', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 2560);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MyApp(repository: FakeBillRepository()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bills-carousel')), findsOneWidget);
      expect(find.text('UPCOMING BILLS (9)'), findsOneWidget);

      await tester.tap(find.byKey(const Key('scenario-twoItems')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('compact-bills-list')), findsOneWidget);
      expect(find.text('UPCOMING BILLS (2)'), findsOneWidget);
    });
  });
}

class FakeBillRepository extends BillRepository {
  @override
  Future<BillsSection> fetchSection(BillScenario scenario) async {
    switch (scenario) {
      case BillScenario.twoItems:
        return BillsSection(
          title: 'UPCOMING BILLS',
          scenario: scenario,
          billCountLabel: '2',
          bills: const [
            Bill(
              title: 'VIL',
              subTitle: 'Miss Blake Murazik',
              logoUrl: 'https://example.com/vil.png',
              amount: '₹200',
              paymentTitle: 'Pay ₹200',
              footerText: 'due today',
            ),
            Bill(
              title: 'HDFC Bank',
              subTitle: 'XXXX XXXX 6582',
              logoUrl: 'https://example.com/hdfc.png',
              amount: '₹45,000',
              paymentTitle: 'Pay ₹45,000',
              flipperConfig: FlipperConfig(
                items: ['GET 1% BACK AS GOLD UPTO ₹200', 'DUE TODAY'],
                delayMs: 1000,
                finalStageText: 'DUE TODAY',
              ),
            ),
          ],
        );
      case BillScenario.manyItems:
        return BillsSection(
          title: 'UPCOMING BILLS',
          scenario: scenario,
          billCountLabel: '9',
          bills: List.generate(
            4,
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
}

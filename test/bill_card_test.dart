import 'package:cred_assesment/models/bill_model.dart';
import 'package:cred_assesment/widgets/bill_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  group('BillCard', () {
    testWidgets('renders payment title and footer state', (tester) async {
      await mockNetworkImagesFor(() async {
        const bill = Bill(
          title: 'VIL',
          subTitle: 'Miss Blake Murazik',
          logoUrl: 'https://example.com/logo.png',
          amount: '₹200',
          paymentTitle: 'Pay ₹200',
          footerText: 'due today',
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: BillCard(bill: bill)),
          ),
        );

        expect(find.text('VIL'), findsOneWidget);
        expect(find.text('Miss Blake Murazik'), findsOneWidget);
        expect(find.text('Pay ₹200'), findsOneWidget);
        expect(find.byKey(const Key('footer-text')), findsOneWidget);
        expect(find.text('due today'), findsOneWidget);
      });
    });

    testWidgets('renders flipper when flipper config is present', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        const bill = Bill(
          title: 'HDFC Bank',
          subTitle: 'XXXX XXXX 6582',
          logoUrl: 'https://example.com/logo.png',
          amount: '₹45,000',
          paymentTitle: 'Pay ₹45,000',
          paymentTag: 'OUTSTANDING',
          flipperConfig: FlipperConfig(
            items: ['GET 1% BACK AS GOLD UPTO ₹200', 'DUE TODAY'],
            delayMs: 1000,
            finalStageText: 'DUE TODAY',
          ),
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: BillCard(bill: bill)),
          ),
        );

        expect(find.text('OUTSTANDING'), findsOneWidget);
        expect(find.text('GET 1% BACK AS GOLD UPTO ₹200'), findsOneWidget);
        expect(find.byKey(const Key('footer-text')), findsNothing);
      });
    });
  });
}

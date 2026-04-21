import 'package:cred_assesment/models/bill_model.dart';
import 'package:cred_assesment/widgets/stacked_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  group('StackedCarousel', () {
    final bills = List<Bill>.generate(
      4,
      (index) => Bill(
        title: 'Bill ${index + 1}',
        subTitle: 'Subtitle ${index + 1}',
        logoUrl: 'https://example.com/logo${index + 1}.png',
        amount: '₹${(index + 1) * 100}',
        paymentTitle: 'Pay ₹${(index + 1) * 100}',
        footerText: 'due today',
      ),
    );

    testWidgets('renders vertical carousel and responds to swipe gestures', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: StackedCarousel(bills: bills)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('bills-carousel')), findsOneWidget);
        expect(
          find.byKey(const Key('carousel-page-indicator')),
          findsOneWidget,
        );
        expect(find.text('1/4'), findsOneWidget);
        final before = tester
            .state<ScrollableState>(find.byType(Scrollable))
            .position
            .pixels;

        await tester.fling(
          find.byKey(const Key('bills-carousel')),
          const Offset(0, -500),
          1600,
        );
        await tester.pumpAndSettle();

        final after = tester
            .state<ScrollableState>(find.byType(Scrollable))
            .position
            .pixels;
        expect(after, greaterThan(before));
      });
    });
  });
}

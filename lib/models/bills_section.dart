import 'bill_model.dart';
import 'bill_scenario.dart';

class BillsSection {
  const BillsSection({
    required this.title,
    required this.bills,
    required this.scenario,
    required this.billCountLabel,
  });

  final String title;
  final List<Bill> bills;
  final BillScenario scenario;
  final String billCountLabel;

  factory BillsSection.fromJson(
    Map<String, dynamic> json,
    BillScenario scenario,
  ) {
    final templateProperties =
        (json['template_properties'] as Map<String, dynamic>?) ?? const {};
    final body =
        (templateProperties['body'] as Map<String, dynamic>?) ?? const {};
    final childList =
        templateProperties['child_list'] as List<dynamic>? ?? const [];

    return BillsSection(
      title: body['title'] as String? ?? 'Upcoming bills',
      bills: childList
          .whereType<Map<String, dynamic>>()
          .map(Bill.fromJson)
          .toList(growable: false),
      scenario: scenario,
      billCountLabel:
          body['bills_count'] as String? ?? childList.length.toString(),
    );
  }
}

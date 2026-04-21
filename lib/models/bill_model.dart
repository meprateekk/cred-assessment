class Bill {
  const Bill({
    required this.title,
    required this.subTitle,
    required this.logoUrl,
    required this.amount,
    required this.paymentTitle,
    this.paymentTag,
    this.footerText,
    this.backgroundImageUrl,
    this.flipperConfig,
  });

  final String title;
  final String subTitle;
  final String logoUrl;
  final String amount;
  final String paymentTitle;
  final String? paymentTag;
  final String? footerText;
  final String? backgroundImageUrl;
  final FlipperConfig? flipperConfig;

  factory Bill.fromJson(Map<String, dynamic> json) {
    final templateProperties =
        (json['template_properties'] as Map<String, dynamic>?) ?? const {};
    final body =
        (templateProperties['body'] as Map<String, dynamic>?) ?? const {};
    final logo = (body['logo'] as Map<String, dynamic>?) ?? const {};
    final background =
        (templateProperties['background'] as Map<String, dynamic>?) ?? const {};
    final asset = (background['asset'] as Map<String, dynamic>?) ?? const {};
    final ctas =
        (templateProperties['ctas'] as Map<String, dynamic>?) ?? const {};
    final primary = (ctas['primary'] as Map<String, dynamic>?) ?? const {};

    return Bill(
      title: body['title'] as String? ?? '',
      subTitle: body['sub_title'] as String? ?? '',
      logoUrl: logo['url'] as String? ?? '',
      amount: body['payment_amount'] as String? ?? '',
      paymentTitle: primary['title'] as String? ?? 'Pay now',
      paymentTag: body['payment_tag'] as String?,
      footerText: body['footer_text'] as String?,
      backgroundImageUrl: asset['url'] as String?,
      flipperConfig: FlipperConfig.fromNullableJson(body['flipper_config']),
    );
  }
}

class FlipperConfig {
  const FlipperConfig({
    required this.items,
    required this.delayMs,
    this.flipCount = 1,
    this.finalStageText,
  });

  final List<String> items;
  final int delayMs;
  final int flipCount;
  final String? finalStageText;

  bool get hasContent =>
      items.isNotEmpty ||
      (finalStageText != null && finalStageText!.isNotEmpty);

  static FlipperConfig? fromNullableJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return null;
    }

    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    final items = itemsJson
        .whereType<Map<String, dynamic>>()
        .map((item) => item['text'] as String? ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    final finalStage =
        (json['final_stage'] as Map<String, dynamic>?)?['text'] as String?;

    return FlipperConfig(
      items: items,
      delayMs: json['flip_delay'] as int? ?? 2000,
      flipCount: json['flip_count'] as int? ?? 1,
      finalStageText: finalStage,
    );
  }
}

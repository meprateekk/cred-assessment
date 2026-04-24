import 'package:flutter/material.dart';

import '../models/bill_model.dart';
import 'flipper_widget.dart';

class BillCard extends StatelessWidget {
  const BillCard({super.key, required this.bill, this.elevation = 14});

  final Bill bill;
  final double elevation;

  Color _accentForTitle() {
    switch (bill.title.toUpperCase()) {
      case 'SBI':
        return const Color(0xFF4D74FF);
      case 'HDFC BANK':
        return const Color(0xFFE15656);
      case 'VIL':
        return const Color(0xFFFF5A5F);
      case 'BESCOM':
        return const Color(0xFFFFA24D);
      default:
        return const Color(0xFFB5A6FF);
    }
  }

  Color _footerColor(String text) {
    final upper = text.toUpperCase();
    if (upper.contains('OVERDUE')) return const Color(0xFFE05959);
    if (upper.contains('DUE')) return const Color(0xFFD58D3D);
    return const Color(0xFF8A857D);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentForTitle();
    final footerText = bill.footerText ?? '';
    final flipperConfig = bill.flipperConfig;
    final hasBottom = (flipperConfig != null && flipperConfig.hasContent) ||
        footerText.isNotEmpty;

    return Container(
      key: Key('bill-card-${bill.title}-${bill.subTitle}'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E2DA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14000000),
            blurRadius: 22,
            offset: Offset(0, elevation == 0 ? 4 : 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top row: logo | title+subtitle | pay button ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE7E1D9)),
                ),
                clipBehavior: Clip.antiAlias,
                child: bill.logoUrl.isEmpty
                    ? _FallbackLogo(title: bill.title, accent: accent)
                    : Image.network(
                        bill.logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _FallbackLogo(title: bill.title, accent: accent),
                      ),
              ),
              const SizedBox(width: 12),
              // Title + subtitle
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((bill.paymentTag ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          bill.paymentTag!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF9A9388),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    Text(
                      bill.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1F1D1B),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      bill.subTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8D867B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Pay button — natural width, no fixed ctaWidth
              FilledButton(
                key: const Key('pay-cta'),
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(100, 44),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  bill.paymentTitle,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom row: full-width flipper / footer text ──
          if (hasBottom) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: flipperConfig != null && flipperConfig.hasContent
                  ? FlipperWidget(config: flipperConfig)
                  : Text(
                      footerText,
                      key: const Key('footer-text'),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _footerColor(footerText),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.4,
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({required this.title, required this.accent});

  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final initial = title.isEmpty ? '?' : title[0];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, Color.lerp(accent, Colors.white, 0.2) ?? accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

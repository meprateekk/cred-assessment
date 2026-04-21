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
    final upperText = text.toUpperCase();
    if (upperText.contains('OVERDUE')) {
      return const Color(0xFFE05959);
    }
    if (upperText.contains('DUE')) {
      return const Color(0xFFD58D3D);
    }
    return const Color(0xFF8A857D);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentForTitle();
    final footerText = bill.footerText ?? '';
    final flipperConfig = bill.flipperConfig;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight.isFinite && constraints.maxHeight < 220;
        final padding = compact ? 14.0 : 16.0;
        final logoSize = compact ? 42.0 : 48.0;
        final ctaWidth = compact ? 168.0 : 196.0;

        return Container(
          key: Key('bill-card-${bill.title}-${bill.subTitle}'),
          constraints: BoxConstraints(minHeight: compact ? 124 : 136),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(compact ? 16 : 18),
            border: Border.all(color: const Color(0xFFE7E1D9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0x14000000),
                blurRadius: compact ? 16 : 22,
                offset: Offset(0, compact ? 8 : 10),
                spreadRadius: elevation == 0 ? 0 : 0.2,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: logoSize,
                height: logoSize,
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
              SizedBox(width: compact ? 12 : 16),
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
                          style: TextStyle(
                            color: const Color(0xFF9A9388),
                            fontSize: compact ? 9 : 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    Text(
                      bill.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF1F1D1B),
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 14 : 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bill.subTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8D867B),
                        fontSize: compact ? 11 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: compact ? 10 : 14),
              SizedBox(
                width: ctaWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FilledButton(
                      key: const Key('pay-cta'),
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF111111),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: Size(ctaWidth, compact ? 42 : 46),
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 12 : 14,
                          vertical: compact ? 10 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          bill.paymentTitle,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: compact ? 12 : 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 8 : 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: ctaWidth,
                        minHeight: compact ? 18 : 20,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: flipperConfig != null && flipperConfig.hasContent
                            ? FlipperWidget(config: flipperConfig)
                            : Text(
                                footerText,
                                key: const Key('footer-text'),
                                textAlign: TextAlign.right,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _footerColor(footerText),
                                  fontWeight: FontWeight.w700,
                                  fontSize: compact ? 10 : 11,
                                  letterSpacing: 0.4,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({required this.title, required this.accent});

  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final initial = title.isEmpty ? '?' : title.substring(0, 1);

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

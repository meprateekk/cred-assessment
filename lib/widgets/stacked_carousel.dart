import 'dart:async';
import 'package:flutter/material.dart';

import '../models/bill_model.dart';
import 'bill_card.dart';

class StackedCarousel extends StatefulWidget {
  const StackedCarousel({super.key, required this.bills});

  final List<Bill> bills;

  @override
  State<StackedCarousel> createState() => _StackedCarouselState();
}

class _StackedCarouselState extends State<StackedCarousel> {
  late final PageController _controller;
  double _page = 0;
  int _currentPageIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.78)
      ..addListener(_syncPage);
    _startAutoScroll();
  }

  void _syncPage() {
    if (!_controller.hasClients) {
      return;
    }
    setState(() {
      _page = _controller.page ?? _controller.initialPage.toDouble();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_controller.hasClients && mounted) {
        final nextPage = (_currentPageIndex + 1) % widget.bills.length;
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFCFAF7), Color(0xFFF7F2EC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: PageView.builder(
              key: const Key('bills-carousel'),
              controller: _controller,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.bills.length,
              padEnds: false,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final distance = index - _page;
                final normalized = distance.clamp(-1.2, 2.0);
                final scale = (1 - (normalized.abs() * 0.04)).clamp(0.92, 1.0);
                final opacity = (1 - (normalized.abs() * 0.18)).clamp(
                  0.72,
                  1.0,
                );
                final translateY = distance >= 0
                    ? distance * 20
                    : distance * 10;
                final horizontalInset =
                    8 + (normalized.abs() * 14).clamp(0, 24).toDouble();

                return Transform.translate(
                  offset: Offset(0, translateY),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child: Opacity(
                      opacity: opacity,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalInset,
                          14,
                          horizontalInset,
                          26,
                        ),
                        child: BillCard(
                          bill: widget.bills[index],
                          elevation: index == _currentPageIndex ? 20 : 8,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            right: 14,
            top: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(99),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  'Swipe',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF6F6D6A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 14,
            bottom: 18,
            child: Text(
              '${_currentPageIndex + 1}/${widget.bills.length}',
              key: const Key('carousel-page-indicator'),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFF6F6D6A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller
      ..removeListener(_syncPage)
      ..dispose();
    super.dispose();
  }
}

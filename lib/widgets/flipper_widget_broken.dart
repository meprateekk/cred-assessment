import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/bill_model.dart';

class FlipperWidget extends StatefulWidget {
  const FlipperWidget({super.key, required this.config});

  final FlipperConfig config;

  @override
  State<FlipperWidget> createState() => _FlipperWidgetState();
}

class _FlipperWidgetState extends State<FlipperWidget> {
  int _currentIndex = 0;
  int _completedLoops = 0;
  String? _currentOverrideText;
  Timer? _timer;

  List<String> get _items => widget.config.items;

  @override
  void initState() {
    super.initState();
    _startIfNeeded();
  }

  @override
  void didUpdateWidget(covariant FlipperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _timer?.cancel();
      _currentIndex = 0;
      _completedLoops = 0;
      _currentOverrideText = null;
      _startIfNeeded();
    }
  }

  void _startIfNeeded() {
    print('FLIPPER DEBUG: Starting flipper with ${_items.length} items: $_items');
    if (_items.length <= 1) {
      print('FLIPPER DEBUG: Not starting - only ${_items.length} items');
      return;
    }
    print('FLIPPER DEBUG: Starting timer with ${widget.config.delayMs}ms delay');
    _timer = Timer.periodic(
      Duration(milliseconds: widget.config.delayMs),
      (_) => _advance(),
    );
  }

  void _advance() {
    if (!mounted) {
      return;
    }

    setState(() {
      if (_currentIndex < _items.length - 1) {
        _currentIndex += 1;
        return;
      }

      _completedLoops += 1;
      
      // For continuous looping, don't stop at final stage if it's already in items
      final finalStageText = widget.config.finalStageText ?? '';
      final finalStageIsInItems = _items.contains(finalStageText);
      
      // Only stop if we have a final stage that's NOT in the items list
      if (_completedLoops >= widget.config.flipCount && 
          finalStageText.isNotEmpty && 
          !finalStageIsInItems) {
        _currentOverrideText = finalStageText;
        _timer?.cancel();
        return;
      }

      // Reset to start for continuous loop
      _currentIndex = 0;
    });
  }

  String get _currentText {
    final overrideText = _currentOverrideText;
    if (overrideText != null && overrideText.isNotEmpty) {
      return overrideText;
    }
    if (_items.isNotEmpty) {
      return _items[_currentIndex];
    }
    return widget.config.finalStageText ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final currentText = _currentText;
    if (currentText.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final rotation = Tween<double>(
          begin: math.pi / 2,
          end: 0,
        ).animate(animation);

        return AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, builtChild) {
            return Opacity(
              opacity: animation.value,
              child: Transform(
                alignment: Alignment.centerRight,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(rotation.value),
                child: builtChild,
              ),
            );
          },
        );
      },
      child: Text(
        currentText,
        key: ValueKey(currentText),
        textAlign: TextAlign.right,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFFFFCF70),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

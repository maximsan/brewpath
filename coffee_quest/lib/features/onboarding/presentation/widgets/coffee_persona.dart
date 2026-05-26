import 'package:flutter/material.dart';

/// Cycles through `tree-1.png … tree-10.png` to fake a seed→tree growth.
/// Used by Welcome hero Variant C.
class CoffeePersona extends StatefulWidget {
  const CoffeePersona({this.size = 220, super.key});

  final double size;

  static const _frames = <String>[
    'assets/images/trees/tree-1.png',
    'assets/images/trees/tree-2.png',
    'assets/images/trees/tree-3.png',
    'assets/images/trees/tree-4.png',
    'assets/images/trees/tree-5.png',
    'assets/images/trees/tree-6.png',
    'assets/images/trees/tree-7.png',
    'assets/images/trees/tree-8.png',
    'assets/images/trees/tree-9.png',
    'assets/images/trees/tree-10.png',
  ];

  @override
  State<CoffeePersona> createState() => _CoffeePersonaState();
}

class _CoffeePersonaState extends State<CoffeePersona>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final idx = (t * CoffeePersona._frames.length).floor().clamp(
          0,
          CoffeePersona._frames.length - 1,
        );
        return Image.asset(
          CoffeePersona._frames[idx],
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          gaplessPlayback: true,
        );
      },
    );
  }
}

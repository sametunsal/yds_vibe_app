import 'package:flutter/material.dart';

/// Widget that shows swipe instruction hint with pulsing animation
class SwipeInstructionHint extends StatefulWidget {
  const SwipeInstructionHint({super.key});

  @override
  State<SwipeInstructionHint> createState() => _SwipeInstructionHintState();
}

class _SwipeInstructionHintState extends State<SwipeInstructionHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_animation.value * 0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, size: 16, color: Colors.red[300]),
              const SizedBox(width: 8),
              Text(
                'Kaydır: Tekrar',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(width: 24),
              Text(
                'Kolay',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 16, color: Colors.green[300]),
            ],
          ),
        );
      },
    );
  }
}

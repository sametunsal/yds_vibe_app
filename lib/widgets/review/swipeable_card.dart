import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A swipeable card widget with physics-based gestures and haptic feedback
/// Swiping left/right triggers different actions (Again/Easy ratings)
class SwipeableCard extends StatefulWidget {
  final Widget frontChild;
  final Widget backChild;
  final VoidCallback? onSwipeLeft;   // Usually "Again" rating
  final VoidCallback? onSwipeRight;  // Usually "Easy" rating
  final VoidCallback? onFlip;        // Tap to flip
  final bool isFlipped;

  const SwipeableCard({
    super.key,
    required this.frontChild,
    required this.backChild,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onFlip,
    this.isFlipped = false,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragOffset = 0;
  bool _isDragging = false;

  // Thresholds for swipe actions
  static const double _swipeThreshold = 100.0;
  static const double _rotationFactor = 0.002;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() => _isDragging = true);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() => _dragOffset += details.delta.dx);
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() => _isDragging = false);

    // Determine swipe action based on offset
    if (_dragOffset > _swipeThreshold) {
      // Swiped right - trigger callback
      _triggerSwipeAction(true);
    } else if (_dragOffset < -_swipeThreshold) {
      // Swiped left - trigger callback
      _triggerSwipeAction(false);
    } else {
      // Not enough swipe - spring back
      _animateBack();
    }
  }

  void _triggerSwipeAction(bool swipedRight) {
    HapticFeedback.mediumImpact();

    // Animate card away
    final endOffset = swipedRight ? 500.0 : -500.0;
    _controller.forward(from: 0).then((_) {
      if (swipedRight) {
        widget.onSwipeRight?.call();
      } else {
        widget.onSwipeLeft?.call();
      }
      // Reset for next card
      _controller.reset();
      setState(() => _dragOffset = 0);
    });

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _dragOffset = _dragOffset + (endOffset - _dragOffset) * _controller.value;
        });
      }
    });
  }

  void _animateBack() {
    final startOffset = _dragOffset;
    _controller.forward(from: 0).then((_) {
      setState(() => _dragOffset = 0);
      _controller.reset();
    });

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _dragOffset = startOffset * (1 - _controller.value);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onTap: widget.onFlip,
      child: Transform.translate(
        offset: Offset(_dragOffset, 0),
        child: Transform.rotate(
          angle: _dragOffset * _rotationFactor,
          child: _buildCardWithIndicators(),
        ),
      ),
    );
  }

  Widget _buildCardWithIndicators() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main card content
        AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: _isDragging ? 0.9 : 1.0,
          child: widget.isFlipped ? widget.backChild : widget.frontChild,
        ),

        // Left swipe indicator (AGAIN)
        if (_dragOffset < -20)
          Positioned(
            left: 20,
            top: 20,
            child: _SwipeIndicator(
              icon: Icons.refresh,
              label: 'Tekrar',
              color: Colors.red,
              progress: (_dragOffset.abs() / _swipeThreshold).clamp(0.0, 1.0),
            ),
          ),

        // Right swipe indicator (EASY)
        if (_dragOffset > 20)
          Positioned(
            right: 20,
            top: 20,
            child: _SwipeIndicator(
              icon: Icons.check_circle,
              label: 'Kolay',
              color: Colors.green,
              progress: (_dragOffset / _swipeThreshold).clamp(0.0, 1.0),
            ),
          ),
      ],
    );
  }
}

/// Visual indicator shown during swipe gesture
class _SwipeIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double progress;

  const _SwipeIndicator({
    required this.icon,
    required this.label,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: progress,
      child: Transform.scale(
        scale: 0.8 + (progress * 0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

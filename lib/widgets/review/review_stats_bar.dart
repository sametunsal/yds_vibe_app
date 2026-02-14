import 'package:flutter/material.dart';
import '../../core/responsive.dart';

class ReviewStatsBar extends StatelessWidget {
  final int remainingCount;
  final int newCardsToday;
  final int maxNewCardsPerDay;

  const ReviewStatsBar({
    super.key,
    required this.remainingCount,
    required this.newCardsToday,
    required this.maxNewCardsPerDay,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = context.responsive(
      compact: 11.0,
      medium: 13.0,
      expanded: 15.0,
    );
    final iconSize = context.responsive(
      compact: 14.0,
      medium: 16.0,
      expanded: 18.0,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildChip(
          icon: Icons.layers,
          label: 'Kalan: $remainingCount',
          fontSize: fontSize,
          iconSize: iconSize,
        ),
        _buildChip(
          icon: Icons.star_outline,
          label: 'Yeni: $newCardsToday/$maxNewCardsPerDay',
          fontSize: fontSize,
          iconSize: iconSize,
        ),
      ],
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required double fontSize,
    required double iconSize,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: fontSize, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

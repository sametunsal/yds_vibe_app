import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/responsive.dart';
import '../../services/srs_service.dart';
import '../../models/card.dart' as model;

class EmptyReviewState extends StatelessWidget {
  final List<model.VocabularyCard> allCards;
  final bool reviewOnlyMode;
  final VoidCallback onToggleReviewMode;
  final VoidCallback onRefresh;

  const EmptyReviewState({
    super.key,
    required this.allCards,
    required this.reviewOnlyMode,
    required this.onToggleReviewMode,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final hasCards = allCards.isNotEmpty;
    final newCardsCount = SRSService.getNewCards(allCards).length;

    final celebrationIconSize = context.responsive(
      compact: 56.0,
      medium: 72.0,
      expanded: 88.0,
    );
    final titleFont = context.responsive(
      compact: 22.0,
      medium: 28.0,
      expanded: 34.0,
    );
    final subtitleFont = context.responsive(
      compact: 14.0,
      medium: 16.0,
      expanded: 18.0,
    );
    final buttonFont = context.responsive(
      compact: 14.0,
      medium: 16.0,
      expanded: 18.0,
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.horizontalPadding * 2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  padding: EdgeInsets.all(celebrationIconSize * 0.4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.celebration,
                    size: celebrationIconSize,
                    color: Colors.green.shade400,
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 800.ms,
                ),
            const SizedBox(height: 28),
            Text(
              'Bugünlük bitti! 🎉',
              style: TextStyle(
                fontSize: titleFont,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 12),
            if (reviewOnlyMode && newCardsCount > 0)
              Text(
                '$newCardsCount yeni kart mevcut',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: subtitleFont,
                ),
              ).animate().fadeIn(delay: 200.ms)
            else if (!hasCards)
              Text(
                'Henüz kart yok',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: subtitleFont,
                ),
              ).animate().fadeIn(delay: 200.ms)
            else
              Text(
                'Harika iş çıkardın!',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: subtitleFont,
                ),
              ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 36),
            if (reviewOnlyMode && newCardsCount > 0)
              ElevatedButton.icon(
                onPressed: onToggleReviewMode,
                icon: const Icon(Icons.add),
                label: Text(
                  'Yeni kartlara geç',
                  style: TextStyle(fontSize: buttonFont),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).scale()
            else
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: Text('Yenile', style: TextStyle(fontSize: buttonFont)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).scale(),
          ],
        ),
      ),
    );
  }
}

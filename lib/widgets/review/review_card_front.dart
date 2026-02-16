import 'package:flutter/material.dart';
import '../../core/responsive.dart';
import '../../models/card.dart' as model;
import '../../services/tts_service.dart';
import '../speaking_text.dart';

class ReviewCardFront extends StatelessWidget {
  final model.VocabularyCard card;
  final TtsService ttsService;

  const ReviewCardFront({
    super.key,
    required this.card,
    required this.ttsService,
  });

  @override
  Widget build(BuildContext context) {
    final lemmaFont = context.responsive(
      compact: 32.0,
      medium: 40.0,
      expanded: 48.0,
    );
    final volumeIconSize = context.responsive(
      compact: 28.0,
      medium: 32.0,
      expanded: 36.0,
    );
    final tapIconSize = context.responsive(
      compact: 24.0,
      medium: 28.0,
      expanded: 32.0,
    );

    return Card(
      elevation: 12,
      shadowColor: Colors.deepPurple.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.deepPurple.shade50],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
              ),
              child: SpeakingText(
                text: card.lemma,
                baseStyle: TextStyle(
                  fontSize: lemmaFont,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                ttsService: ttsService,
              ),
            ),
            const SizedBox(height: 16),
            IconButton(
              onPressed: () => ttsService.speak(card.lemma),
              icon: Icon(
                Icons.volume_up_rounded,
                size: volumeIconSize,
                color: Colors.deepPurple.shade300,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.touch_app,
                size: tapIconSize,
                color: Colors.deepPurple[300],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Çevirmek için dokun',
              style: TextStyle(
                fontSize: context.responsive(
                  compact: 11.0,
                  medium: 12.0,
                  expanded: 14.0,
                ),
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

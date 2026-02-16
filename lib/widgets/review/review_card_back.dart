import 'package:flutter/material.dart';
import '../../core/responsive.dart';
import '../../models/card.dart' as model;
import '../../services/tts_service.dart';
import '../speaking_text.dart';

class ReviewCardBack extends StatelessWidget {
  final model.VocabularyCard card;
  final TtsService ttsService;

  const ReviewCardBack({
    super.key,
    required this.card,
    required this.ttsService,
  });

  @override
  Widget build(BuildContext context) {
    final meaningFont = context.responsive(
      compact: 26.0,
      medium: 32.0,
      expanded: 38.0,
    );
    final lemmaFont = context.responsive(
      compact: 16.0,
      medium: 20.0,
      expanded: 24.0,
    );
    final synonymFont = context.responsive(
      compact: 11.0,
      medium: 13.0,
      expanded: 15.0,
    );
    final exampleFont = context.responsive(
      compact: 13.0,
      medium: 15.0,
      expanded: 17.0,
    );
    final translationFont = context.responsive(
      compact: 11.0,
      medium: 13.0,
      expanded: 15.0,
    );
    final cardPadding = context.responsive(
      compact: 16.0,
      medium: 24.0,
      expanded: 32.0,
    );

    return Card(
      elevation: 12,
      shadowColor: Colors.deepPurple.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpeakingText(
                text: card.lemma,
                baseStyle: TextStyle(
                  fontSize: lemmaFont,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
                highlightStyle: TextStyle(
                  fontSize: lemmaFont,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  backgroundColor: Colors.deepPurple.withValues(alpha: 0.15),
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.deepPurple,
                  decorationThickness: 2,
                ),
                ttsService: ttsService,
              ),
              const SizedBox(height: 4),
              IconButton(
                onPressed: () => ttsService.speak(card.lemma),
                icon: Icon(
                  Icons.volume_up_rounded,
                  size: 20,
                  color: Colors.grey[400],
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 12),
              Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Meaning
              Text(
                card.meaningTr,
                style: TextStyle(
                  fontSize: meaningFont,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Synonyms
              if (card.synonyms.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: card.synonyms
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: synonymFont,
                              color: Colors.deepPurple[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Example sentence with improved readability
              Container(
                padding: EdgeInsets.all(cardPadding * 0.67),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.deepPurple.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    SpeakingText(
                      text: card.example.text,
                      baseStyle: TextStyle(
                        fontSize: exampleFont + 1, // Slightly larger for better readability
                        fontStyle: FontStyle.normal, // Removed italic for clarity
                        height: 1.4,
                        color: const Color(0xFF2D2D2D), // Dark grey for better contrast
                        fontWeight: FontWeight.w500, // Medium weight for readability
                      ),
                      highlightStyle: TextStyle(
                        fontSize: exampleFont + 1,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        backgroundColor: Colors.amber.withValues(alpha: 0.25),
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.amber,
                        decorationThickness: 2,
                      ),
                      ttsService: ttsService,
                      textAlign: TextAlign.center,
                    ),
                    if (card.example.translation != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          card.example.translation!,
                          style: TextStyle(
                            fontSize: translationFont + 1,
                            color: const Color(0xFF424242), // Darker grey for translation
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    IconButton(
                      onPressed: () => ttsService.speak(card.example.text),
                      icon: Icon(
                        Icons.volume_up_rounded,
                        size: 24,
                        color: Colors.deepPurple,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/responsive.dart';
import '../../models/card.dart' as model;

class RatingButtons extends StatelessWidget {
  final void Function(model.Rating rating) onRating;

  const RatingButtons({super.key, required this.onRating});

  @override
  Widget build(BuildContext context) {
    final buttonHeight = context.responsive(
      compact: 44.0,
      medium: 52.0,
      expanded: 56.0,
    );
    final fontSize = context.responsive(
      compact: 13.0,
      medium: 15.0,
      expanded: 17.0,
    );
    final iconSize = context.responsive(
      compact: 18.0,
      medium: 20.0,
      expanded: 22.0,
    );

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: () => onRating(model.Rating.again),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: Colors.red.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: iconSize),
                const SizedBox(width: 8),
                Text(
                  'Tekrar',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () => onRating(model.Rating.struggled),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB8C00),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.orange.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Zor',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () => onRating(model.Rating.good),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7CB342),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.lightGreen.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'İyi',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () => onRating(model.Rating.easy),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: Colors.green.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Kolay',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('🎉', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

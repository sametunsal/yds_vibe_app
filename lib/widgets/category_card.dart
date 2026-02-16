import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/responsive.dart';
import '../theme/app_styles.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardPadding = context.responsive(
      compact: 14.0,
      medium: 20.0,
      expanded: 24.0,
    );
    final iconSize = context.responsive(
      compact: 24.0,
      medium: 28.0,
      expanded: 36.0,
    );
    final iconContainerPadding = context.responsive(
      compact: 10.0,
      medium: 12.0,
      expanded: 14.0,
    );
    final bgIconSize = context.responsive(
      compact: 80.0,
      medium: 100.0,
      expanded: 120.0,
    );
    final countFont = context.responsive(
      compact: 16.0,
      medium: 20.0,
      expanded: 24.0,
    );
    final titleFont = context.responsive(
      compact: 14.0,
      medium: 16.0,
      expanded: 18.0,
    );

    return InkWell(
          onTap: onTap,
          borderRadius: BorderRadiusPresets.xxlargeBorder,
          splashColor: color.withValues(alpha: 0.3),
          highlightColor: color.withValues(alpha: 0.2),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.85), color],
                stops: const [0.0, 1.0],
              ),
              borderRadius: BorderRadiusPresets.xxlargeBorder,
              boxShadow: ShadowStyles.deepPurpleCard(color),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -16,
                  bottom: -16,
                  child: Icon(
                    icon,
                    size: bgIconSize,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: EdgeInsets.all(iconContainerPadding),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            boxShadow: ShadowStyles.subtle,
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: iconSize,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadiusPresets.mediumBorder,
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: countFont,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFont,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutCubic);
  }
}

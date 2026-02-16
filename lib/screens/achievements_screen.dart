import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../theme/app_styles.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Achievement definition
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final double progress;
  final String? rewardText;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.progress = 0.0,
    this.rewardText,
  });
}

/// Screen displaying user achievements and progress
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  // Mock achievement data - will be replaced with real data later
  final List<Achievement> _achievements = [
    Achievement(
      id: 'first_card',
      title: 'İlk Adım',
      description: 'İlk kelime kartını çalış',
      icon: Icons.play_arrow_rounded,
      color: ColorPalette.success,
      isUnlocked: true,
      rewardText: 'Başlangıç başarısı!',
    ),
    Achievement(
      id: 'streak_3',
      title: 'SerBest 3',
      description: '3 gün üst üste çalış',
      icon: Icons.local_fire_department,
      color: ColorPalette.streakActive,
      isUnlocked: true,
      progress: 1.0,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Haftalık SerBest',
      description: '7 gün üst üste çalış',
      icon: Icons.whatshot,
      color: Colors.orangeAccent,
      isUnlocked: false,
      progress: 0.57, // 4/7 days
    ),
    Achievement(
      id: 'master_50',
      title: 'Yarı Yol',
      description: '50 kelimeyi öğren',
      icon: Icons.school,
      color: ColorPalette.deepPurple,
      isUnlocked: false,
      progress: 0.32, // 16/50 words
    ),
    Achievement(
      id: 'perfect_quiz',
      title: 'Mükemmel Quiz',
      description: 'Quiz\'te %100 başarı',
      icon: Icons.stars_rounded,
      color: Colors.amber,
      isUnlocked: false,
      progress: 0.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final headerFont = context.responsive(
      compact: 24.0,
      medium: 28.0,
      expanded: 32.0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: context.responsive(
              compact: 180.0,
              medium: 200.0,
              expanded: 220.0,
            ),
            floating: false,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Başarılar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: headerFont * 0.5,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepPurple.shade400,
                          Colors.deepPurple.shade700,
                        ],
                      ),
                    ),
                  ),
                  // Decorative pattern
                  ...List.generate(
                    20,
                    (index) => Positioned(
                      left: (index * 47) % 300,
                      top: (index * 31) % 200,
                      child: Icon(
                        Icons.emoji_events_outlined,
                        size: 20 + (index % 3) * 10,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: context.responsive(
                        compact: 64.0,
                        medium: 80.0,
                        expanded: 96.0,
                      ),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(context.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  _buildStatsRow(context),
                  const SizedBox(height: 24),

                  // Achievements Header
                  _buildSectionHeader('Başarı Rozetleri', Icons.military_tech),
                  const SizedBox(height: 16),

                  // Achievements List
                  ...List.generate(
                    _achievements.length,
                    (index) => _buildAchievementCard(_achievements[index], index),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final unlockedCount = _achievements.where((a) => a.isUnlocked).length;
    final totalCount = _achievements.length;
    final progress = unlockedCount / totalCount;

    return Container(
      padding: Spacing.allLG,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withValues(alpha: 0.1),
            Colors.deepPurple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadiusPresets.largeBorder,
        border: Border.all(
          color: Colors.deepPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: Colors.deepPurple,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unlockedCount / $totalCount',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const Text(
                  'Başarı açıldı',
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorPalette.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildAchievementCard(Achievement achievement, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: Spacing.allMD,
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadiusPresets.largeBorder,
        border: Border.all(
          color: achievement.isUnlocked
              ? achievement.color.withValues(alpha: 0.3)
              : Colors.grey[300]!,
          width: achievement.isUnlocked ? 2 : 1,
        ),
        boxShadow: achievement.isUnlocked
            ? [
                BoxShadow(
                  color: achievement.color.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? achievement.color.withValues(alpha: 0.15)
                  : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: achievement.isUnlocked
                  ? achievement.color
                  : Colors.grey[500],
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: achievement.isUnlocked
                            ? Colors.black87
                            : Colors.grey[600],
                      ),
                    ),
                    if (achievement.isUnlocked) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        color: achievement.color,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                if (!achievement.isUnlocked && achievement.progress > 0) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: achievement.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        achievement.color,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
                if (achievement.rewardText != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: achievement.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      achievement.rewardText!,
                      style: TextStyle(
                        fontSize: 11,
                        color: achievement.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Arrow icon
          if (achievement.isUnlocked)
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            )
          else
            Icon(
              Icons.lock_outline,
              color: Colors.grey[400],
              size: 20,
            ),
        ],
      ),
    )
        .animate(delay: (index * 80).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1);
  }
}

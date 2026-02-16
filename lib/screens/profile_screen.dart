import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../core/responsive.dart';
import '../core/result.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';
import '../services/streak_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final CardRepository _repository = CardRepositoryImpl();
  late Future<Result<List<VocabularyCard>>> _cardsFuture;

  int _streakCount = 0;
  List<bool> _weeklyActivity = List.filled(7, false);

  final List<String> _weekDays = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _cardsFuture = _repository.getAllCards();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    final streak = await StreakService.getStreakCount();
    final activity = await StreakService.getLast7DaysActivity();
    if (mounted) {
      setState(() {
        _streakCount = streak;
        _weeklyActivity = activity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _loadData()),
            style: IconButton.styleFrom(
              minimumSize: const Size(AppTheme.minInteractiveDimension, AppTheme.minInteractiveDimension),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Result<List<VocabularyCard>>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Hata: ${snapshot.error}'),
                ],
              ),
            );
          }

          final result = snapshot.data;
          if (result == null) {
            return const Center(child: CircularProgressIndicator());
          }

          switch (result) {
            case Success(value: final cards):
              return _buildContent(cards);
            case Failure(message: final msg):
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text('Hata: $msg'),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  Widget _buildContent(List<VocabularyCard> cards) {
    final newCount = cards.where((c) => c.intervalDays == 0).length;
    final learningCount = cards
        .where(
          (c) =>
              c.intervalDays > 0 &&
              c.intervalDays < AppConstants.learningThresholdDays,
        )
        .length;
    final masteredCount = cards
        .where((c) => c.intervalDays >= AppConstants.masteredThresholdDays)
        .length;
    final totalCards = cards.length;
    final level = (masteredCount / 10).floor() + 1;
    final padding = context.horizontalPadding;

    return SingleChildScrollView(
      child: ResponsiveCenter(
        maxWidth: 600,
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(level),
            const SizedBox(height: 28),

            // Stats Section Title
            Row(
              children: [
                Icon(Icons.bar_chart, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'İlerleme Durumu',
                  style: TextStyle(
                    fontSize: context.responsive(
                      compact: 14.0,
                      medium: 16.0,
                      expanded: 18.0,
                    ),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildStatsGrid(newCount, learningCount, masteredCount, totalCards),
            const SizedBox(height: 28),

            // Weekly Activity Section
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 20,
                  color: Colors.orange[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Haftalık Aktivite',
                  style: TextStyle(
                    fontSize: context.responsive(
                      compact: 14.0,
                      medium: 16.0,
                      expanded: 18.0,
                    ),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildWeeklyStreak(),
            const SizedBox(height: 28),

            _buildQuickStats(cards),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(int level) {
    final avatarSize = context.responsive(
      compact: 56.0,
      medium: 72.0,
      expanded: 88.0,
    );
    final titleFont = context.responsive(
      compact: 18.0,
      medium: 22.0,
      expanded: 26.0,
    );
    final trophySize = context.responsive(
      compact: 24.0,
      medium: 28.0,
      expanded: 32.0,
    );
    final headerPadding = context.responsive(
      compact: 16.0,
      medium: 20.0,
      expanded: 24.0,
    );

    return Container(
      padding: EdgeInsets.all(headerPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Icon(
              Icons.person,
              size: avatarSize * 0.55,
              color: Colors.white,
            ),
          ),
          SizedBox(width: headerPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YDS Adayı',
                  style: TextStyle(
                    fontSize: titleFont,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Level $level',
                    style: TextStyle(
                      fontSize: context.responsive(
                        compact: 12.0,
                        medium: 14.0,
                        expanded: 16.0,
                      ),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events,
              size: trophySize,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    int newCount,
    int learningCount,
    int masteredCount,
    int total,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Yeni',
            count: newCount,
            icon: Icons.add_circle_outline,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Öğreniliyor',
            count: learningCount,
            icon: Icons.trending_up,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Ezberlendi',
            count: masteredCount,
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    final iconSize = context.responsive(
      compact: 24.0,
      medium: 28.0,
      expanded: 32.0,
    );
    final countFont = context.responsive(
      compact: 22.0,
      medium: 26.0,
      expanded: 30.0,
    );
    final labelFont = context.responsive(
      compact: 12.0, // Fixed: was 11.0, now minimum readable
      medium: 12.0,
      expanded: 14.0,
    );

    return Container(
      constraints: const BoxConstraints(
        minHeight: AppTheme.minInteractiveDimension,
      ),
      padding: EdgeInsets.symmetric(
        vertical: context.responsive(
          compact: 12.0,
          medium: 16.0,
          expanded: 20.0,
        ),
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: iconSize),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: countFont,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: labelFont,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStreak() {
    final currentStreak = _streakCount;
    final dotSize = context.responsive(
      compact: 28.0,
      medium: 36.0,
      expanded: 44.0,
    );
    final dotIconSize = context.responsive(
      compact: 16.0,
      medium: 20.0,
      expanded: 24.0,
    );
    final streakFont = context.responsive(
      compact: 16.0,
      medium: 18.0,
      expanded: 20.0,
    );
    final dayLabelFont = context.responsive(
      compact: 12.0, // Fixed: was 10.0, now minimum readable
      medium: 12.0, // Fixed: was 11.0, now minimum readable
      expanded: 13.0,
    );

    return Container(
      padding: EdgeInsets.all(
        context.responsive(compact: 16.0, medium: 20.0, expanded: 24.0),
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department,
                color: currentStreak >= 5 ? Colors.orange : Colors.grey[400],
                size: context.responsive(
                  compact: 28.0,
                  medium: 32.0,
                  expanded: 36.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$currentStreak gün aktif',
                style: TextStyle(
                  fontSize: streakFont,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final isActive = _weeklyActivity[index];
              return Column(
                children: [
                  Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.grey[300],
                      shape: BoxShape.circle,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isActive ? Icons.check : Icons.remove,
                      color: Colors.white,
                      size: dotIconSize,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _weekDays[index],
                    style: TextStyle(
                      fontSize: dayLabelFont,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.grey[800] : Colors.grey[500],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(List<VocabularyCard> cards) {
    final avgReps = cards.isEmpty
        ? 0.0
        : cards.map((c) => c.repetitions).reduce((a, b) => a + b) /
              cards.length;
    final reviewedCards = cards.where((c) => c.repetitions > 0).length;

    return Container(
      padding: EdgeInsets.all(
        context.responsive(compact: 16.0, medium: 20.0, expanded: 24.0),
      ),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detaylı İstatistikler',
            style: TextStyle(
              fontSize: context.responsive(
                compact: 13.0,
                medium: 14.0,
                expanded: 16.0,
              ),
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple[700],
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickStatRow(
            icon: Icons.style,
            label: 'Toplam Kart',
            value: '${cards.length}',
          ),
          const SizedBox(height: 12),
          _buildQuickStatRow(
            icon: Icons.visibility,
            label: 'En Az 1 Kez Görülen',
            value: '$reviewedCards',
          ),
          const SizedBox(height: 12),
          _buildQuickStatRow(
            icon: Icons.repeat,
            label: 'Ort. Tekrar Sayısı',
            value: avgReps.toStringAsFixed(1),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final iconSize = context.responsive(
      compact: 18.0,
      medium: 20.0,
      expanded: 22.0,
    );
    final labelFont = context.responsive(
      compact: 13.0,
      medium: 14.0,
      expanded: 16.0,
    );
    final valueFont = context.responsive(
      compact: 14.0,
      medium: 16.0,
      expanded: 18.0,
    );

    return Row(
      children: [
        Icon(icon, size: iconSize, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: labelFont, color: Colors.grey[700]),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFont,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }
}

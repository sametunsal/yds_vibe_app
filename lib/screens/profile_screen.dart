import 'package:flutter/material.dart';
import '../models/card.dart';
import '../data/card_loader.dart';
import '../services/streak_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<VocabularyCard>> _cardsFuture;

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
    _cardsFuture = CardLoader.loadCards();
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
          ),
        ],
      ),
      body: FutureBuilder<List<VocabularyCard>>(
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

          final cards = snapshot.data ?? [];
          return _buildContent(cards);
        },
      ),
    );
  }

  Widget _buildContent(List<VocabularyCard> cards) {
    // Calculate stats
    final newCount = cards.where((c) => c.intervalDays == 0).length;
    final learningCount = cards
        .where((c) => c.intervalDays > 0 && c.intervalDays < 21)
        .length;
    final masteredCount = cards.where((c) => c.intervalDays >= 21).length;
    final totalCards = cards.length;

    // Calculate level based on mastered cards
    final level = (masteredCount / 10).floor() + 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats Cards
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekly Streak
          _buildWeeklyStreak(),
          const SizedBox(height: 28),

          // Quick Stats
          _buildQuickStats(cards),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(int level) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YDS Adayı',
                  style: TextStyle(
                    fontSize: 22,
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Trophy icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              size: 28,
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Streak count
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department,
                color: currentStreak >= 5 ? Colors.orange : Colors.grey[400],
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                '$currentStreak gün aktif',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Week days
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final isActive = _weeklyActivity[index];
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
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
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _weekDays[index],
                    style: TextStyle(
                      fontSize: 11,
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
    // Calculate average repetitions
    final avgReps = cards.isEmpty
        ? 0.0
        : cards.map((c) => c.repetitions).reduce((a, b) => a + b) /
              cards.length;

    // Cards reviewed at least once
    final reviewedCards = cards.where((c) => c.repetitions > 0).length;

    return Container(
      padding: const EdgeInsets.all(20),
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
              fontSize: 14,
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
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }
}

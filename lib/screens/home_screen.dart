import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../core/result.dart';
import '../data/card_loader.dart';
import '../models/category.dart';
import '../repositories/card_repository.dart';
import '../services/srs_service.dart';
import '../services/streak_service.dart';
import '../widgets/category_card.dart';
import 'review_screen.dart';
import 'profile_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CardRepository _repository = CardRepositoryImpl();
  Map<String, int> _counts = {};
  int _dueCount = 0;
  int _newCount = 0;
  int _streakCount = 0;
  bool _isLoading = true;
  int _totalCards = 0;

  static const List<CategoryData> _categories = [
    CategoryData(
      key: 'verb',
      title: 'Fiiller',
      icon: Icons.directions_run,
      color: Color(0xFFE53935),
    ),
    CategoryData(
      key: 'noun',
      title: 'İsimler',
      icon: Icons.category_rounded,
      color: Color(0xFF1E88E5),
    ),
    CategoryData(
      key: 'adj',
      title: 'Sıfatlar',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF8E24AA),
    ),
    CategoryData(
      key: 'adv',
      title: 'Zarflar',
      icon: Icons.speed_rounded,
      color: Color(0xFF00ACC1),
    ),
    CategoryData(
      key: 'phrasal_verb',
      title: 'Phrasal Verbs',
      icon: Icons.call_merge_rounded,
      color: Color(0xFFFF6F00),
    ),
    CategoryData(
      key: 'conjunction',
      title: 'Bağlaçlar',
      icon: Icons.link_rounded,
      color: Color(0xFF6D4C41),
    ),
    CategoryData(
      key: 'all',
      title: 'Tümü',
      icon: Icons.library_books_rounded,
      color: Color(0xFF3949AB),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Debug: force reload from assets (bypass cache)
    if (kDebugMode) CardLoader.clearCache();

    final result = await _repository.getAllCards();

    switch (result) {
      case Success(value: final cards):
        final counts = <String, int>{};
        for (final category in _categories) {
          counts[category.key] = SRSService.getCardsByCategory(
            cards,
            category.key,
          ).length;
        }
        final streak = await StreakService.getStreakCount();
        if (mounted) {
          setState(() {
            _counts = counts;
            _totalCards = cards.length;
            _dueCount = SRSService.getDueCards(cards).length;
            _newCount = cards.where((c) => c.intervalDays == 0).length;
            _streakCount = streak;
            _isLoading = false;
          });
          debugPrint(
            '[HomeScreen] Total: ${cards.length} | Due: $_dueCount | New(total): $_newCount',
          );
        }
      case Failure(message: final msg):
        debugPrint('[HomeScreen] Error: $msg');
        if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToCategory(CategoryData category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewScreen(
          category: category.key == 'all' ? '' : category.key,
          title: category.title,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _startStudy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReviewScreen()),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final expandedHeight = context.responsive(
      compact: 120.0,
      medium: 140.0,
      expanded: 170.0,
    );
    final titleFontSize = context.responsive(
      compact: 20.0,
      medium: 24.0,
      expanded: 28.0,
    );
    final bgIconSize = context.responsive(
      compact: 48.0,
      medium: 64.0,
      expanded: 80.0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: expandedHeight,
            floating: false,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'YDS Vibe',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: titleFontSize,
                ),
              ),
              background: Container(
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
                child: Center(
                  child: Icon(
                    Icons.school_rounded,
                    size: bgIconSize,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                tooltip: 'Profil',
                style: IconButton.styleFrom(
                  minimumSize: const Size(AppTheme.minInteractiveDimension, AppTheme.minInteractiveDimension),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _isLoading ? _buildLoadingState() : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 400,
      child: Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
    );
  }

  Widget _buildContent() {
    final padding = context.horizontalPadding;

    return ResponsiveCenter(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Bar
          _buildStatsBar()
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.1),

          // Debug: total card count
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Total cards: $_totalCards',
                style: TextStyle(
                  fontSize: 12, // Fixed: was 11, now minimum readable
                  color: Colors.amber.shade300,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Start Study CTA
          _buildStartStudyCta()
              .animate(delay: 100.ms)
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 20),

          // Categories header + grid
          _buildCategoriesGrid(),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Row(
      children: [
        _buildStatChip(
          icon: Icons.schedule,
          label: 'Bekleyen',
          value: '$_dueCount',
          color: _dueCount > 0 ? Colors.orange : Colors.grey,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          icon: Icons.auto_awesome,
          label: 'Yeni',
          value: '$_newCount',
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          icon: Icons.local_fire_department,
          label: 'Seri',
          value: '$_streakCount gün',
          color: _streakCount > 0 ? Colors.deepOrange : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: InkWell(
        onTap: null, // Stat chips are display-only but need proper touch target
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppTheme.minInteractiveDimension,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12, // Fixed: was 10, now minimum readable
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartStudyCta() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _dueCount > 0 || _newCount > 0 ? _startStudy : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 24),
            const SizedBox(width: 8),
            Text(
              _dueCount > 0
                  ? 'Çalışmaya Başla ($_dueCount bekliyor)'
                  : 'Çalışmaya Başla',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final headerFont = context.responsive(
      compact: 18.0,
      medium: 22.0,
      expanded: 26.0,
    );
    final subFont = context.responsive(
      compact: 12.0,
      medium: 14.0,
      expanded: 16.0,
    );
    final crossAxisCount = context.responsive(
      compact: 2,
      medium: 2,
      expanded: 3,
    );
    final gridSpacing = context.responsive(
      compact: 12.0,
      medium: 16.0,
      expanded: 20.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategoriler',
          style: TextStyle(
            fontSize: headerFont,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
        const SizedBox(height: 4),
        Text(
          'Toplam ${_counts['all'] ?? 0} kart',
          style: TextStyle(
            fontSize: subFont,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
        SizedBox(height: gridSpacing),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: gridSpacing,
            mainAxisSpacing: gridSpacing,
            childAspectRatio: context.responsive(
              compact: 0.95,
              medium: 1.0,
              expanded: 1.05,
            ),
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final count = _counts[category.key] ?? 0;

            return CategoryCard(
                  title: category.title,
                  icon: category.icon,
                  count: count,
                  color: category.color,
                  onTap: () => _navigateToCategory(category),
                )
                .animate(delay: (index * 50).ms)
                .fadeIn()
                .scale(
                  begin: const Offset(0.9, 0.9),
                  curve: Curves.easeOutCubic,
                );
          },
        ),
      ],
    );
  }
}

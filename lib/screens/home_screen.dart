import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../core/result.dart';
import '../models/category.dart';
import '../repositories/card_repository.dart';
import '../services/srs_service.dart';
import '../widgets/category_card.dart';
import 'review_screen.dart';
import 'profile_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CardRepository _repository = CardRepositoryImpl();
  Map<String, int> _counts = {};
  bool _isLoading = true;

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
        if (mounted) {
          setState(() {
            _counts = counts;
            _isLoading = false;
          });
        }
      case Failure(message: final msg):
        debugPrint('[HomeScreen] Error loading data: $msg');
        if (mounted) {
          setState(() => _isLoading = false);
        }
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
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _isLoading ? _buildLoadingState() : _buildCategoriesGrid(),
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

  Widget _buildCategoriesGrid() {
    final padding = context.horizontalPadding;
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

    return ResponsiveCenter(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bugün ne çalışmak istersin?',
            style: TextStyle(
              fontSize: headerFont,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(
            'Toplam ${_counts['all'] ?? 0} kart',
            style: TextStyle(
              fontSize: subFont,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          SizedBox(height: gridSpacing + 4),
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
      ),
    );
  }
}

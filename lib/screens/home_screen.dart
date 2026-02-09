import 'package:flutter/material.dart';
import '../data/card_loader.dart';
import '../models/card.dart';
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
  Map<String, int> _counts = {};
  bool _isLoading = true;

  // Category data structure
  static const List<CategoryData> _categories = [
    CategoryData(
      key: 'verb',
      title: 'Fiiller',
      icon: Icons.directions_run,
      color: Color(0xFFE53935), // Red
    ),
    CategoryData(
      key: 'noun',
      title: 'İsimler',
      icon: Icons.category_rounded,
      color: Color(0xFF1E88E5), // Blue
    ),
    CategoryData(
      key: 'adj',
      title: 'Sıfatlar',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF8E24AA), // Purple
    ),
    CategoryData(
      key: 'adv',
      title: 'Zarflar',
      icon: Icons.speed_rounded,
      color: Color(0xFF00ACC1), // Teal
    ),
    CategoryData(
      key: 'phrasal_verb',
      title: 'Phrasal Verbs',
      icon: Icons.call_merge_rounded,
      color: Color(0xFFFF6F00), // Amber
    ),
    CategoryData(
      key: 'conjunction',
      title: 'Bağlaçlar',
      icon: Icons.link_rounded,
      color: Color(0xFF6D4C41), // Brown
    ),
    CategoryData(
      key: 'all',
      title: 'Tümü',
      icon: Icons.library_books_rounded,
      color: Color(0xFF3949AB), // Indigo
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final cards = await CardLoader.loadCards();

      // Calculate counts for each category
      final counts = <String, int>{};
      for (final category in _categories) {
        counts[category.key] =
            SRSService.getCardsByCategory(cards, category.key).length;
      }

      if (mounted) {
        setState(() {
          _counts = counts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[HomeScreen] Error loading data: $e');
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'YDS Vibe',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
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
                    size: 64,
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

          // Main Content
          SliverToBoxAdapter(
            child: _isLoading
                ? _buildLoadingState()
                : _buildCategoriesGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 400,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Bugün ne çalışmak istersin?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(
            'Toplam ${_counts['all'] ?? 0} kart',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 24),

          // Categories Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
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
              ).animate(delay: (index * 50).ms).fadeIn().scale(
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

// Category data model
class CategoryData {
  final String key;
  final String title;
  final IconData icon;
  final Color color;

  const CategoryData({
    required this.key,
    required this.title,
    required this.icon,
    required this.color,
  });
}

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'review_screen.dart';
import 'quiz_screen.dart';
import 'profile_screen.dart';
import '../widgets/animated_bottom_nav.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _previousIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(key: PageStorageKey('home')),
    ReviewScreen(key: PageStorageKey('review')),
    QuizScreen(key: PageStorageKey('quiz')),
    ProfileScreen(key: PageStorageKey('profile')),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _previousIndex = _selectedIndex;
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offset = _selectedIndex > _previousIndex ? -1.0 : 1.0;
          return SlideTransitionX(
            position: Tween<Offset>(
              begin: Offset(offset, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// Slide transition for horizontal page switching
class SlideTransitionX extends StatelessWidget {
  final Animation<Offset> position;
  final Widget child;

  const SlideTransitionX({
    super.key,
    required this.position,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: position,
      builder: (context, child) {
        return FractionalTranslation(
          translation: position.value,
          child: child,
        );
      },
      child: child,
    );
  }
}

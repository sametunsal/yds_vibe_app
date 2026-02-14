import 'package:flutter/material.dart';

enum ScreenType { compact, medium, expanded }

extension ResponsiveHelper on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  ScreenType get screenType {
    final width = screenWidth;
    if (width < 360) return ScreenType.compact;
    if (width < 600) return ScreenType.medium;
    return ScreenType.expanded;
  }

  bool get isCompact => screenType == ScreenType.compact;
  bool get isMedium => screenType == ScreenType.medium;
  bool get isExpanded => screenType == ScreenType.expanded;

  /// Pick a value based on current breakpoint
  T responsive<T>({required T compact, T? medium, required T expanded}) {
    switch (screenType) {
      case ScreenType.compact:
        return compact;
      case ScreenType.medium:
        return medium ?? compact;
      case ScreenType.expanded:
        return expanded;
    }
  }

  /// Horizontal content padding
  double get horizontalPadding =>
      responsive(compact: 12.0, medium: 16.0, expanded: 24.0);

  /// Max content width for tablets (centered layout)
  double? get maxContentWidth => isExpanded ? 600.0 : null;
}

/// Wrap content with max-width constraint for tablet layouts
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 600.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}

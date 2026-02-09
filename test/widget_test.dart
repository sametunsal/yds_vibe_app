import 'package:flutter_test/flutter_test.dart';

import 'package:yds_vibe_app/main.dart';

void main() {
  testWidgets('App launches with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const YDSVibeApp());

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Quiz'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}

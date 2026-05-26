import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eco_habit_tracker/main.dart';

void main() {
  testWidgets('shows rewards and leaderboard navigation', (tester) async {
    await tester.pumpWidget(const EcoHabitTrackerApp());

    expect(find.text('Eco Rewards'), findsOneWidget);
    expect(find.text('Available rewards'), findsOneWidget);
    expect(find.text('Rewards'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);

    await tester.tap(find.text('Leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Leaderboard CRUD'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });
}

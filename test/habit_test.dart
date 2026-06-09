import 'package:flutter_test/flutter_test.dart';
import 'package:act_for_earth/domain/model/habit.dart';

void main() {
  group('Habit Model Tests', () {
    test('should initialize with default empty completionDates', () {
      final now = DateTime.now();
      final habit = Habit(
        userId: 'user-1',
        title: 'Recycle paper',
        category: 'Waste',
        targetFrequency: 5,
        createdAt: now,
      );

      expect(habit.completionDates, isEmpty);
    });

    test('copyWith updates completionDates successfully', () {
      final now = DateTime.now();
      final habit = Habit(
        userId: 'user-1',
        title: 'Recycle paper',
        category: 'Waste',
        targetFrequency: 5,
        createdAt: now,
      );

      final date = DateTime(2026, 6, 9);
      final updatedHabit = habit.copyWith(completionDates: [date]);

      expect(updatedHabit.completionDates, contains(date));
      expect(updatedHabit.title, 'Recycle paper');
      expect(updatedHabit.category, 'Waste');
      expect(updatedHabit.targetFrequency, 5);
    });
  });
}

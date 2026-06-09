import 'package:act_for_earth/domain/model/habit.dart';

abstract class HabitRepository {
  Stream<List<Habit>> watchHabits(String userId);

  Future<void> createHabit(Habit habit);

  Future<void> updateHabit(Habit habit);

  Future<void> deleteHabit(String habitId);
}

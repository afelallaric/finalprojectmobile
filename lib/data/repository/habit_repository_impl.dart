import 'package:act_for_earth/data/remote/habit_remote_datasource.dart';
import 'package:act_for_earth/domain/model/habit.dart';
import 'package:act_for_earth/domain/repository/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl({required HabitRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final HabitRemoteDataSource _remoteDataSource;

  @override
  Stream<List<Habit>> watchHabits(String userId) {
    return _remoteDataSource.watchHabits(userId);
  }

  @override
  Future<void> seedDefaultHabits({required String userId}) {
    return _remoteDataSource.seedDefaultHabits(userId: userId);
  }

  @override
  Future<void> createHabit(Habit habit) {
    return _remoteDataSource.createHabit(habit);
  }

  @override
  Future<void> updateHabit(Habit habit) {
    return _remoteDataSource.updateHabit(habit);
  }

  @override
  Future<void> deleteHabit(String habitId) {
    return _remoteDataSource.deleteHabit(habitId);
  }
}

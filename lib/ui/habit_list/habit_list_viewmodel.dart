import 'dart:async';

import 'package:act_for_earth/domain/model/habit.dart';
import 'package:act_for_earth/domain/repository/habit_repository.dart';
import 'package:flutter/foundation.dart';

class HabitListViewModel extends ChangeNotifier {
  HabitListViewModel({
    required HabitRepository repository,
    required this.userId,
  }) : _repository = repository;

  final HabitRepository _repository;
  final String userId;

  List<Habit> _habits = const [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<List<Habit>>? _subscription;
  bool _initialized = false;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _subscription = _repository
          .watchHabits(userId)
          .listen(
            (habits) {
              _habits = habits;
              _isLoading = false;
              _errorMessage = null;
              notifyListeners();
            },
            onError: (Object error) {
              _isLoading = false;
              _errorMessage = error.toString();
              notifyListeners();
            },
          );
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> addHabit({
    required String title,
    required String category,
    required int targetFrequency,
  }) async {
    await _repository.createHabit(
      Habit(
        userId: userId,
        title: title,
        category: category,
        targetFrequency: targetFrequency,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> editHabit(
    Habit habit, {
    required String title,
    required String category,
    required int targetFrequency,
  }) async {
    await _repository.updateHabit(
      habit.copyWith(
        title: title,
        category: category,
        targetFrequency: targetFrequency,
      ),
    );
  }

  Future<void> toggleHabitCompletion(Habit habit, DateTime date) async {
    final updatedDates = List<DateTime>.from(habit.completionDates);
    final isDone = updatedDates.any((d) =>
        d.year == date.year &&
        d.month == date.month &&
        d.day == date.day);

    if (isDone) {
      updatedDates.removeWhere((d) =>
          d.year == date.year &&
          d.month == date.month &&
          d.day == date.day);
    } else {
      // Keep it consistent by storing the date at mid-day
      updatedDates.add(DateTime(date.year, date.month, date.day, 12, 0));
    }

    await _repository.updateHabit(
      habit.copyWith(completionDates: updatedDates),
    );
  }

  Future<void> deleteHabit(String habitId) async {
    await _repository.deleteHabit(habitId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

import 'dart:async';

import 'package:act_for_earth/data/remote/reward_firestore_service.dart';
import 'package:act_for_earth/data/remote/notification_service.dart';
import 'package:act_for_earth/domain/model/habit.dart';
import 'package:act_for_earth/domain/repository/habit_repository.dart';
import 'package:flutter/foundation.dart';

import 'package:act_for_earth/data/remote/habit_log_firestore_service.dart';
import 'package:act_for_earth/domain/model/habit_log.dart';

class HabitListViewModel extends ChangeNotifier {
  HabitListViewModel({
    required HabitRepository repository,
    required this.userId,
  }) : _repository = repository;

  final HabitRepository _repository;
  final String userId;
  final _logService = HabitLogFirestoreService();
  final _rewardService = RewardFirestoreService();

  List<Habit> _habits = const [];
  List<HabitLog> _logs = const [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<List<Habit>>? _subscription;
  StreamSubscription<List<HabitLog>>? _logsSubscription;
  bool _initialized = false;

  List<Habit> get habits => _habits;
  List<HabitLog> get logs => _logs;
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

      _logsSubscription = _logService.watchAllLogs().listen(
            (logs) {
              _logs = logs;
              notifyListeners();
            },
          );
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> toggleHabitToday(String habitId, bool currentStatus) async {
    await _logService.logHabit(habitId, DateTime.now(), !currentStatus);
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
    // Schedule a daily habit reminder!
    final notificationId = (title + userId).hashCode;
    await NotificationService.scheduleDailyHabitReminder(
      id: notificationId,
      title: 'Time for your eco-habit! 🌱',
      body: 'Have you completed your habit "$title" today?',
    );
  }

  Future<void> editHabit(
    Habit habit, {
    required String title,
    required String category,
    required int targetFrequency,
  }) async {
    // If title has changed, cancel old reminder and schedule new one
    if (habit.title != title) {
      final oldNotificationId = (habit.title + userId).hashCode;
      await NotificationService.cancelNotification(oldNotificationId);

      final newNotificationId = (title + userId).hashCode;
      await NotificationService.scheduleDailyHabitReminder(
        id: newNotificationId,
        title: 'Time for your eco-habit! 🌱',
        body: 'Have you completed your habit "$title" today?',
      );
    }

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

    final isDailyHabit = habit.targetFrequency >= 7;
    int pointsEarned = 10; // Base completion reward
    int streak = 0;

    if (isDone) {
      // Deducting points because user is untoggling completion
      if (isDailyHabit) {
        streak = _calculateDailyStreak(habit);
        pointsEarned += streak > 1 ? (streak * 5) : 0;
      } else {
        streak = _calculateWeeklyStreak(habit);
        pointsEarned += streak > 1 ? (streak * 15) : 0;
      }

      // Untoggle: Remove date
      updatedDates.removeWhere((d) =>
          d.year == date.year &&
          d.month == date.month &&
          d.day == date.day);

      await _repository.updateHabit(
        habit.copyWith(completionDates: updatedDates),
      );

      // Deduct points from EcoPoint system
      await _rewardService.subtractPoints(userId, pointsEarned);

      // Trigger a local notification explaining points deduction
      await NotificationService.showNotification(
        id: DateTime.now().millisecond,
        title: 'Habit Log Removed 🛑',
        body: 'Removed $pointsEarned EcoPoints for unchecking "${habit.title}". Keep it up next time!',
      );
    } else {
      // Adding completion: Add date
      updatedDates.add(DateTime(date.year, date.month, date.day, 12, 0));
      final newHabit = habit.copyWith(completionDates: updatedDates);

      if (isDailyHabit) {
        streak = _calculateDailyStreak(newHabit);
        pointsEarned += streak > 1 ? (streak * 5) : 0;
      } else {
        streak = _calculateWeeklyStreak(newHabit);
        pointsEarned += streak > 1 ? (streak * 15) : 0;
      }

      await _repository.updateHabit(newHabit);

      // Add points to EcoPoint system
      await _rewardService.addPoints(userId, pointsEarned);

      // Trigger notification congratulating completion & streak
      String notificationBody;
      if (streak > 1) {
        final streakUnit = isDailyHabit ? 'day' : 'week';
        notificationBody = 'Awesome! You kept your $streak-$streakUnit streak alive. Earned $pointsEarned EcoPoints! 🌎🔥';
      } else {
        notificationBody = 'Great job logging "${habit.title}". Earned $pointsEarned EcoPoints! 🌎';
      }

      await NotificationService.showNotification(
        id: DateTime.now().millisecond,
        title: 'EcoPoint Reward! 🌟',
        body: notificationBody,
      );
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      final habit = _habits.firstWhere((h) => h.habitId == habitId);
      final notificationId = (habit.title + userId).hashCode;
      await NotificationService.cancelNotification(notificationId);
    } catch (_) {
      // Habit not found or already deleted
    }
    await _repository.deleteHabit(habitId);
  }

  int _calculateDailyStreak(Habit habit) {
    if (habit.completionDates.isEmpty) return 0;
    final sortedDates = habit.completionDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    final hasCompletedToday = sortedDates.contains(todayDate);
    final hasCompletedYesterday = sortedDates.contains(yesterdayDate);

    if (!hasCompletedToday && !hasCompletedYesterday) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = hasCompletedToday ? todayDate : yesterdayDate;

    while (true) {
      if (sortedDates.contains(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int _calculateWeeklyStreak(Habit habit) {
    if (habit.completionDates.isEmpty) return 0;
    final target = habit.targetFrequency;
    if (target <= 0) return 0;

    final now = DateTime.now();
    DateTime getMonday(DateTime date) {
      final start = date.subtract(Duration(days: date.weekday - 1));
      return DateTime(start.year, start.month, start.day);
    }

    final currentMonday = getMonday(now);

    final Map<DateTime, int> completionsPerWeek = {};
    for (var date in habit.completionDates) {
      final monday = getMonday(date);
      completionsPerWeek[monday] = (completionsPerWeek[monday] ?? 0) + 1;
    }

    bool isWeekTargetMet(DateTime monday) {
      final count = completionsPerWeek[monday] ?? 0;
      return count >= target;
    }

    int weeklyStreak = 0;
    final metThisWeek = isWeekTargetMet(currentMonday);
    final previousMonday = currentMonday.subtract(const Duration(days: 7));

    DateTime checkMonday = previousMonday;
    int pastWeeksMet = 0;

    while (true) {
      final hasCompletionsInOrBeforeWeek = habit.completionDates.any((d) => getMonday(d).isBefore(checkMonday.add(const Duration(days: 1))));
      if (!hasCompletionsInOrBeforeWeek) break;

      if (isWeekTargetMet(checkMonday)) {
        pastWeeksMet++;
        checkMonday = checkMonday.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }

    if (metThisWeek) {
      weeklyStreak = pastWeeksMet + 1;
    } else {
      final daysRemaining = 7 - now.weekday;
      final completionsThisWeek = completionsPerWeek[currentMonday] ?? 0;
      final canStillMeetTarget = completionsThisWeek + daysRemaining >= target;

      if (canStillMeetTarget) {
        weeklyStreak = pastWeeksMet;
      } else {
        weeklyStreak = 0;
      }
    }
    return weeklyStreak;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _logsSubscription?.cancel();
    super.dispose();
  }
}

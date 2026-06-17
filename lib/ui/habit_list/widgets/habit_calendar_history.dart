import 'package:act_for_earth/domain/model/habit.dart';
import 'package:act_for_earth/ui/habit_list/habit_list_viewmodel.dart';
import 'package:flutter/material.dart';

class HabitHistoryBottomSheet extends StatefulWidget {
  const HabitHistoryBottomSheet({
    super.key,
    required this.habit,
    required this.viewModel,
  });

  final Habit habit;
  final HabitListViewModel viewModel;

  @override
  State<HabitHistoryBottomSheet> createState() => _HabitHistoryBottomSheetState();
}

class _HabitHistoryBottomSheetState extends State<HabitHistoryBottomSheet> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final currentHabit = widget.viewModel.habits.firstWhere(
          (h) => h.habitId == widget.habit.habitId,
          orElse: () => widget.habit,
        );

        final totalCompletions = currentHabit.completionDates.length;
        final streakText = _getStreakText(currentHabit);

        // Calculate completions in focused month
        final completionsInMonth = currentHabit.completionDates.where((d) {
          return d.year == _focusedMonth.year && d.month == _focusedMonth.month;
        }).length;
        final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
        final completionRate = daysInMonth > 0 ? (completionsInMonth / daysInMonth) * 100 : 0.0;

        final calendarDays = _generateCalendarDays(_focusedMonth.year, _focusedMonth.month);
        final monthNames = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium Drag Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title and category block
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentHabit.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildCategoryBadge(context, currentHabit.category),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildPointsIndicator(context, currentHabit),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerLow,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 0.5),

                // Premium Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Streak',
                        value: streakText,
                        icon: Icons.local_fire_department_rounded,
                        iconColor: Colors.orange,
                        backgroundColor: Colors.orange.withOpacity(0.12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Month Rate',
                        value: '${completionRate.toStringAsFixed(0)}%',
                        icon: Icons.analytics_rounded,
                        iconColor: colorScheme.primary,
                        backgroundColor: colorScheme.primary.withOpacity(0.12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Total',
                        value: '$totalCompletions',
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: Colors.green,
                        backgroundColor: Colors.green.withOpacity(0.12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Calendar Month Navigator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _prevMonth,
                      icon: const Icon(Icons.keyboard_arrow_left_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerLow,
                      ),
                    ),
                    Text(
                      '${monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(Icons.keyboard_arrow_right_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerLow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Weekday Headers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                    return Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),

                // Calendar Grid Builder
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: calendarDays.length,
                  itemBuilder: (context, index) {
                    final dayDate = calendarDays[index];
                    final isCurrentMonth = dayDate.month == _focusedMonth.month;

                    final isDone = currentHabit.completionDates.any((d) =>
                        d.year == dayDate.year &&
                        d.month == dayDate.month &&
                        d.day == dayDate.day);

                    final now = DateTime.now();
                    final isToday = dayDate.year == now.year &&
                        dayDate.month == now.month &&
                        dayDate.day == now.day;
                    final isFuture = dayDate.isAfter(DateTime(now.year, now.month, now.day));

                    BoxDecoration? decoration;
                    TextStyle textStyle;

                    if (isDone) {
                      decoration = BoxDecoration(
                        color: isCurrentMonth ? colorScheme.primary : colorScheme.primary.withOpacity(0.25),
                        shape: BoxShape.circle,
                        boxShadow: isCurrentMonth
                            ? [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      );
                      textStyle = TextStyle(
                        color: isCurrentMonth ? colorScheme.onPrimary : colorScheme.onPrimary.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      );
                    } else if (isToday) {
                      decoration = BoxDecoration(
                        border: Border.all(color: colorScheme.primary, width: 2),
                        shape: BoxShape.circle,
                      );
                      textStyle = TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      );
                    } else {
                      textStyle = TextStyle(
                        color: isCurrentMonth
                            ? (isFuture ? colorScheme.onSurface.withOpacity(0.3) : colorScheme.onSurface)
                            : colorScheme.onSurface.withOpacity(0.2),
                        fontSize: 13,
                      );
                    }

                    return InkWell(
                      onTap: () {
                        if (isToday) {
                          widget.viewModel.toggleHabitCompletion(currentHabit, dayDate);
                        } else {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFuture
                                    ? 'Cannot log future days!'
                                    : 'Logs can only be toggled for today. Past days are read-only.',
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      customBorder: const CircleBorder(),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: decoration,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${dayDate.day}',
                              style: textStyle,
                            ),
                            if (isDone) ...[
                              const SizedBox(height: 2),
                              Icon(
                                Icons.check,
                                size: 8,
                                color: isCurrentMonth ? colorScheme.onPrimary : colorScheme.onPrimary.withOpacity(0.8),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context, String category) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Color badgeColor;
    Color textColor;
    IconData icon;
    
    final catLower = category.toLowerCase();
    if (catLower.contains('waste') || catLower.contains('recycle')) {
      badgeColor = Colors.teal.withOpacity(0.12);
      textColor = Colors.teal[850]!;
      icon = Icons.recycling_rounded;
    } else if (catLower.contains('water')) {
      badgeColor = Colors.blue.withOpacity(0.12);
      textColor = Colors.blue[850]!;
      icon = Icons.water_drop_rounded;
    } else if (catLower.contains('energy') || catLower.contains('power') || catLower.contains('electricity')) {
      badgeColor = Colors.orange.withOpacity(0.12);
      textColor = Colors.orange[950]!;
      icon = Icons.bolt_rounded;
    } else if (catLower.contains('food') || catLower.contains('eat') || catLower.contains('diet')) {
      badgeColor = Colors.green.withOpacity(0.12);
      textColor = Colors.green[850]!;
      icon = Icons.spa_rounded;
    } else if (catLower.contains('transport') || catLower.contains('travel') || catLower.contains('bike') || catLower.contains('car')) {
      badgeColor = Colors.purple.withOpacity(0.12);
      textColor = Colors.purple[850]!;
      icon = Icons.directions_bike_rounded;
    } else {
      badgeColor = colorScheme.secondaryContainer.withOpacity(0.7);
      textColor = colorScheme.onSecondaryContainer;
      icon = Icons.eco_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsIndicator(BuildContext context, Habit habit) {
    final today = DateTime.now();
    final isDoneToday = habit.completionDates.any((d) =>
        d.year == today.year &&
        d.month == today.month &&
        d.day == today.day);

    final points = _calculatePotentialReward(habit, isDoneToday);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDoneToday
            ? Colors.green.withOpacity(0.08)
            : colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDoneToday
              ? Colors.green.withOpacity(0.25)
              : colorScheme.primary.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDoneToday ? Icons.check_circle_rounded : Icons.eco_rounded,
            color: isDoneToday ? Colors.green : colorScheme.primary,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            isDoneToday
                ? 'Earned +$points EcoPoints today'
                : 'Complete today to earn +$points EcoPoints',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDoneToday ? Colors.green[850] : colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  int _calculatePotentialReward(Habit habit, bool isAlreadyCompletedToday) {
    final isDaily = habit.targetFrequency >= 7;

    List<DateTime> completionDatesForCalc;
    if (isAlreadyCompletedToday) {
      completionDatesForCalc = habit.completionDates;
    } else {
      completionDatesForCalc = List<DateTime>.from(habit.completionDates);
      final today = DateTime.now();
      completionDatesForCalc.add(DateTime(today.year, today.month, today.day, 12, 0));
    }

    final tempHabit = habit.copyWith(completionDates: completionDatesForCalc);

    int streak = 0;
    if (isDaily) {
      streak = _calculateDailyStreak(tempHabit);
      return 10 + (streak > 1 ? (streak * 5) : 0);
    } else {
      streak = _calculateWeeklyStreak(tempHabit);
      return 10 + (streak > 1 ? (streak * 15) : 0);
    }
  }

  String _getStreakText(Habit habit) {
    if (habit.targetFrequency >= 7) {
      final streak = _calculateDailyStreak(habit);
      return '$streak day${streak == 1 ? "" : "s"}';
    } else {
      final streak = _calculateWeeklyStreak(habit);
      return '$streak week${streak == 1 ? "" : "s"}';
    }
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

  List<DateTime> _generateCalendarDays(int year, int month) {
    final firstDayOfMonth = DateTime(year, month, 1);
    final int prefixDays = firstDayOfMonth.weekday - 1;

    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;
    final prevMonthDays = DateUtils.getDaysInMonth(prevYear, prevMonth);

    final List<DateTime> calendarDays = [];

    for (int i = prefixDays - 1; i >= 0; i--) {
      calendarDays.add(DateTime(prevYear, prevMonth, prevMonthDays - i));
    }

    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    for (int i = 1; i <= daysInMonth; i++) {
      calendarDays.add(DateTime(year, month, i));
    }

    final totalSlots = calendarDays.length <= 35 ? 35 : 42;
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    int nextMonthDay = 1;
    while (calendarDays.length < totalSlots) {
      calendarDays.add(DateTime(nextYear, nextMonth, nextMonthDay++));
    }

    return calendarDays;
  }
}

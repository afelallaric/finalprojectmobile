import 'package:act_for_earth/domain/model/habit.dart';
import 'package:act_for_earth/ui/habit_list/habit_list_viewmodel.dart';
import 'package:act_for_earth/ui/habit_list/widgets/habit_form_dialog.dart';
import 'package:act_for_earth/ui/habit_list/widgets/habit_calendar_history.dart';
import 'package:flutter/material.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key, required this.viewModel});

  final HabitListViewModel viewModel;

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  String _selectedStatus = 'All'; // 'All', 'Unfinished', 'Finished'
  String _selectedCategory = 'All'; // 'All' or specific category

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<HabitFormResult>(
      context: context,
      builder: (context) => const HabitFormDialog(),
    );

    if (result == null) {
      return;
    }

    await widget.viewModel.addHabit(
      title: result.title,
      category: result.category,
      targetFrequency: result.targetFrequency,
    );
  }

  Future<void> _showEditDialog(BuildContext context, Habit habit) async {
    final result = await showDialog<HabitFormResult>(
      context: context,
      builder: (context) => HabitFormDialog(
        initialTitle: habit.title,
        initialCategory: habit.category,
        initialTargetFrequency: habit.targetFrequency,
      ),
    );

    if (result == null) {
      return;
    }

    await widget.viewModel.editHabit(
      habit,
      title: result.title,
      category: result.category,
      targetFrequency: result.targetFrequency,
    );
  }

  Future<void> _confirmDelete(BuildContext context, Habit habit) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete habit?'),
          content: Text('Remove "${habit.title}" from your habits list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await widget.viewModel.deleteHabit(habit.habitId);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.viewModel.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Failed to load Firestore data.\n${widget.viewModel.errorMessage}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final habits = List<Habit>.from(widget.viewModel.habits)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return DefaultTabController(
          length: 2,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Habits',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Track and build sustainable routines.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _showAddDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Tab Navigation
                  TabBar(
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.calendar_view_week, size: 20),
                        text: 'Weekly Tracker',
                      ),
                      Tab(
                        icon: Icon(Icons.edit_note, size: 20),
                        text: 'Manage',
                      ),
                    ],
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Tab Contents
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildWeeklyTracker(context, habits),
                        _buildManageHabits(context, habits),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildManageHabits(BuildContext context, List<Habit> habits) {
    if (habits.isEmpty) {
      return const Center(
        child: Text(
          'No habits yet. Tap "Add" at the top to create one!',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: habits.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final habit = habits[index];

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              child: Text('${index + 1}'),
            ),
            title: Text(
              habit.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${habit.category} • Target ${habit.targetFrequency}/week',
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  onPressed: () => _showEditDialog(context, habit),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit habit',
                ),
                IconButton(
                  onPressed: () => _confirmDelete(context, habit),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete habit',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyTracker(BuildContext context, List<Habit> habits) {
    if (habits.isEmpty) {
      return const Center(
        child: Text(
          'No habits yet. Tap "Add" at the top to create one!',
          textAlign: TextAlign.center,
        ),
      );
    }

    // Get the current week Monday - Sunday
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final monday = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final sunday = monday.add(const Duration(days: 6));
    final weekDays = List.generate(
      7,
      (index) => monday.add(Duration(days: index)),
    );

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateRangeStr =
        '${months[monday.month - 1]} ${monday.day} - ${months[sunday.month - 1]} ${sunday.day}, ${monday.year}';

    // 1. Extract all unique categories dynamically
    final categories = habits.map((h) => h.category).toSet().toList()..sort();

    // 2. Filter habits
    final filteredHabits = habits.where((habit) {
      // Category filter
      if (_selectedCategory != 'All' && habit.category != _selectedCategory) {
        return false;
      }

      // Status filter
      final isDoneToday = habit.completionDates.any(
        (d) => d.year == now.year && d.month == now.month && d.day == now.day,
      );

      if (_selectedStatus == 'Unfinished' && isDoneToday) {
        return false;
      }
      if (_selectedStatus == 'Finished' && !isDoneToday) {
        return false;
      }

      return true;
    }).toList();

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week range header card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month, color: colorScheme.primary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Week',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    dateRangeStr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Filter Row Controls
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                label: 'All',
                isSelected: _selectedStatus == 'All',
                onSelected: (selected) {
                  if (selected) setState(() => _selectedStatus = 'All');
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Todo',
                isSelected: _selectedStatus == 'Unfinished',
                onSelected: (selected) {
                  if (selected) setState(() => _selectedStatus = 'Unfinished');
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Completed',
                isSelected: _selectedStatus == 'Finished',
                onSelected: (selected) {
                  if (selected) setState(() => _selectedStatus = 'Finished');
                },
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'All',
                        child: Text('All Categories'),
                      ),
                      ...categories.map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategory = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Habits List or Empty filtered state
        Expanded(
          child: filteredHabits.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedStatus == 'Unfinished'
                              ? Icons.task_alt
                              : Icons.filter_alt_off,
                          size: 48,
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedStatus == 'Unfinished'
                              ? 'All set! No unfinished habits for today. 🎉'
                              : 'No habits match your active filters.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: filteredHabits.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final habit = filteredHabits[index];

                    // Calculate completions in current week
                    final completedCount = weekDays.where((day) {
                      return habit.completionDates.any(
                        (d) =>
                            d.year == day.year &&
                            d.month == day.month &&
                            d.day == day.day,
                      );
                    }).length;

                    final isGoalMet = completedCount >= habit.targetFrequency;

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isGoalMet
                              ? Colors.amber.withOpacity(0.6)
                              : colorScheme.outlineVariant,
                          width: isGoalMet ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Habit info
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        habit.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.secondaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          habit.category,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: colorScheme
                                                .onSecondaryContainer,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildPointsIndicator(context, habit),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isGoalMet) ...[
                                          const Icon(
                                            Icons.stars,
                                            color: Colors.amber,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(
                                          '$completedCount / ${habit.targetFrequency}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: isGoalMet
                                                ? Colors.amber[900]
                                                : colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      'this week',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: habit.targetFrequency > 0
                                    ? (completedCount / habit.targetFrequency)
                                          .clamp(0.0, 1.0)
                                    : 0.0,
                                minHeight: 6,
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                                color: isGoalMet
                                    ? Colors.amber
                                    : colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Days Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: weekDays.map((day) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    child: _buildDaySelector(
                                      context,
                                      habit,
                                      day,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const Divider(height: 24, thickness: 0.5),
                            // Footer Streak & History Navigation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_getStreakText(habit)} streak',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[800],
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      _showHistoryBottomSheet(context, habit),
                                  icon: const Icon(
                                    Icons.calendar_month,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'History & Insights',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface,
      ),
      showCheckmark: false,
    );
  }

  String _getDayLetter(int weekday) {
    switch (weekday) {
      case 1:
        return 'M';
      case 2:
        return 'T';
      case 3:
        return 'W';
      case 4:
        return 'T';
      case 5:
        return 'F';
      case 6:
        return 'S';
      case 7:
        return 'S';
      default:
        return '';
    }
  }

  Widget _buildDaySelector(BuildContext context, Habit habit, DateTime date) {
    final isDone = habit.completionDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );

    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final isFuture = date.isAfter(DateTime(now.year, now.month, now.day));

    final colorScheme = Theme.of(context).colorScheme;

    // Premium styling colors
    final backgroundColor = isDone
        ? (isToday ? colorScheme.primary : colorScheme.primary.withOpacity(0.5))
        : (isToday
              ? colorScheme.primaryContainer.withOpacity(0.5)
              : Colors.transparent);

    final textColor = isDone
        ? colorScheme.onPrimary
        : (isToday
              ? colorScheme.primary
              : (isFuture
                    ? colorScheme.onSurface.withOpacity(0.3)
                    : colorScheme.onSurface.withOpacity(0.7)));

    final borderColor = isDone
        ? (isToday ? colorScheme.primary : colorScheme.primary.withOpacity(0.5))
        : (isToday
              ? colorScheme.primary
              : colorScheme.outlineVariant.withOpacity(0.5));

    return InkWell(
      onTap: () {
        if (isToday) {
          widget.viewModel.toggleHabitCompletion(habit, date);
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFuture
                    ? 'Cannot log future days!'
                    : 'Weekly tracker only allows updates for today. Use History to view progress.',
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: isToday ? 2 : 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getDayLetter(date.weekday),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isDone
                    ? (isToday
                          ? colorScheme.onPrimary.withOpacity(0.8)
                          : colorScheme.onPrimary.withOpacity(0.6))
                    : colorScheme.onSurfaceVariant.withOpacity(
                        isToday ? 1.0 : (isFuture ? 0.3 : 0.6),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              isDone
                  ? Icons.check
                  : (isToday ? Icons.add : (isFuture ? null : Icons.remove)),
              size: 10,
              color: isDone
                  ? (isToday
                        ? colorScheme.onPrimary
                        : colorScheme.onPrimary.withOpacity(0.7))
                  : colorScheme.outline.withOpacity(isToday ? 1.0 : 0.4),
            ),
          ],
        ),
      ),
    );
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

    final sortedDates =
        habit.completionDates
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
      final hasCompletionsInOrBeforeWeek = habit.completionDates.any(
        (d) => getMonday(d).isBefore(checkMonday.add(const Duration(days: 1))),
      );
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

  void _showHistoryBottomSheet(BuildContext context, Habit habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return HabitHistoryBottomSheet(
          habit: habit,
          viewModel: widget.viewModel,
        );
      },
    );
  }

  Widget _buildPointsIndicator(BuildContext context, Habit habit) {
    final today = DateTime.now();
    final isDoneToday = habit.completionDates.any(
      (d) =>
          d.year == today.year && d.month == today.month && d.day == today.day,
    );

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
            isDoneToday ? Icons.check_circle : Icons.eco,
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
              fontWeight: FontWeight.w600,
              color: isDoneToday ? Colors.green[800] : colorScheme.primary,
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
      completionDatesForCalc.add(
        DateTime(today.year, today.month, today.day, 12, 0),
      );
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
}

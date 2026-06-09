import 'package:act_for_earth/domain/model/habit.dart';
import 'package:act_for_earth/ui/habit_list/habit_list_viewmodel.dart';
import 'package:act_for_earth/ui/habit_list/widgets/habit_form_dialog.dart';
import 'package:flutter/material.dart';

class HabitListScreen extends StatelessWidget {
  const HabitListScreen({super.key, required this.viewModel});

  final HabitListViewModel viewModel;

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<HabitFormResult>(
      context: context,
      builder: (context) => const HabitFormDialog(),
    );

    if (result == null) {
      return;
    }

    await viewModel.addHabit(
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

    await viewModel.editHabit(
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

    await viewModel.deleteHabit(habit.habitId);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Failed to load Firestore data.\n${viewModel.errorMessage}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final habits = List<Habit>.from(viewModel.habits)
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
    final monday = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final sunday = monday.add(const Duration(days: 6));
    final weekDays = List.generate(7, (index) => monday.add(Duration(days: index)));

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateRangeStr =
        '${months[monday.month - 1]} ${monday.day} - ${months[sunday.month - 1]} ${sunday.day}, ${monday.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week range header card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Week',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
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
        Expanded(
          child: ListView.separated(
            itemCount: habits.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final habit = habits[index];
              
              // Calculate completions in current week
              final completedCount = weekDays.where((day) {
                return habit.completionDates.any((d) =>
                    d.year == day.year &&
                    d.month == day.month &&
                    d.day == day.day);
              }).length;

              final isGoalMet = completedCount >= habit.targetFrequency;
              final colorScheme = Theme.of(context).colorScheme;

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
                      // Habit info (Title, Category, Progress count, and Goal met indicator)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    habit.category,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ),
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
                                    const Icon(Icons.stars, color: Colors.amber, size: 18),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    '$completedCount / ${habit.targetFrequency}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isGoalMet ? Colors.amber[900] : colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'this week',
                                style: TextStyle(fontSize: 10, color: Colors.grey),
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
                              ? (completedCount / habit.targetFrequency).clamp(0.0, 1.0)
                              : 0.0,
                          minHeight: 6,
                          backgroundColor: colorScheme.surfaceVariant,
                          color: isGoalMet ? Colors.amber : colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Days Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: weekDays.map((day) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: _buildDaySelector(context, habit, day),
                            ),
                          );
                        }).toList(),
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

  Widget _buildDaySelector(
    BuildContext context,
    Habit habit,
    DateTime date,
  ) {
    final isDone = habit.completionDates.any((d) =>
        d.year == date.year &&
        d.month == date.month &&
        d.day == date.day);

    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    final colorScheme = Theme.of(context).colorScheme;

    // Premium styling colors
    final backgroundColor = isDone
        ? colorScheme.primary
        : (isToday ? colorScheme.primaryContainer.withOpacity(0.5) : Colors.transparent);

    final textColor = isDone
        ? colorScheme.onPrimary
        : (isToday ? colorScheme.primary : colorScheme.onSurface);

    final borderColor = isDone
        ? colorScheme.primary
        : (isToday ? colorScheme.primary : colorScheme.outlineVariant);

    return InkWell(
      onTap: () => viewModel.toggleHabitCompletion(habit, date),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: isToday ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getDayLetter(date.weekday),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isDone ? colorScheme.onPrimary.withOpacity(0.8) : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              isDone ? Icons.check : Icons.add,
              size: 10,
              color: isDone ? colorScheme.onPrimary : colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

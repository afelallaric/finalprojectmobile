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
        final habits = List<Habit>.from(viewModel.habits)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Habit Management',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showAddDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Create, update, and delete your habits from Cloud Firestore.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildContent(context, habits)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, List<Habit> habits) {
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

    if (habits.isEmpty) {
      return const Center(child: Text('No habits yet. Add one.'));
    }

    return ListView.separated(
      itemCount: habits.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final habit = habits[index];

        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(habit.title),
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
}

import 'package:act_for_earth/features/habits/domain/habit.dart';
import 'package:act_for_earth/features/habits/presentation/widgets/habit_form_dialog.dart';
import 'package:flutter/material.dart';

class HabitPage extends StatelessWidget {
  const HabitPage({
    super.key,
    required this.habits,
    required this.isLoading,
    this.errorMessage,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Habit> habits;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onAdd;
  final ValueChanged<Habit> onEdit;
  final ValueChanged<Habit> onDelete;

  @override
  Widget build(BuildContext context) {
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Create, view, update, and delete habits from Cloud Firestore.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Failed to load Firestore data.\n$errorMessage',
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
                  onPressed: () => onEdit(habit),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit habit',
                ),
                IconButton(
                  onPressed: () => onDelete(habit),
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

Future<HabitFormResult?> showHabitFormDialog(
  BuildContext context, {
  String initialTitle = '',
  String initialCategory = '',
  int initialTargetFrequency = 1,
}) {
  return showDialog<HabitFormResult>(
    context: context,
    builder: (context) => HabitFormDialog(
      initialTitle: initialTitle,
      initialCategory: initialCategory,
      initialTargetFrequency: initialTargetFrequency,
    ),
  );
}

import 'package:act_for_earth/data/remote/leaderboard_firestore_service.dart';
import 'package:act_for_earth/domain/model/leaderboard_entry.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({
    super.key,
    required this.entries,
    required this.isLoading,
    this.errorMessage,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<LeaderboardEntry> entries;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onAdd;
  final ValueChanged<LeaderboardEntry> onEdit;
  final ValueChanged<LeaderboardEntry> onDelete;

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
                    'Leaderboard CRUD',
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
              'Manage leaderboard data in Cloud Firestore.',
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

    if (entries.isEmpty) {
      return const Center(child: Text('No entries yet. Add one.'));
    }

    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isCurrentUser =
            entry.id == LeaderboardFirestoreService.currentUserDocId;

        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(entry.name),
            subtitle: Text('${entry.points} points'),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  onPressed: () => onEdit(entry),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit points',
                ),
                IconButton(
                  onPressed: isCurrentUser ? null : () => onDelete(entry),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete entry',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

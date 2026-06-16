import 'package:act_for_earth/domain/model/leaderboard_entry.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({
    super.key,
    required this.entries,
    required this.isLoading,
    required this.currentUserId,
    this.errorMessage,
  });

  final List<LeaderboardEntry> entries;
  final bool isLoading;
  final String currentUserId;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🏆 Leaderboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Rankings are updated automatically based on your eco points.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
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
            'Failed to load leaderboard.\n$errorMessage',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    if (entries.isEmpty) {
      return const Center(child: Text('No entries yet. Start earning points!'));
    }

    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isMe = entry.id == currentUserId;
        final rank = index + 1;

        return _LeaderboardTile(
          rank: rank,
          entry: entry,
          isCurrentUser: isMe,
        );
      },
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.rank,
    required this.entry,
    required this.isCurrentUser,
  });

  final int rank;
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final medalEmoji = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => null,
    };

    final backgroundColor = isCurrentUser
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;

    final textColor = isCurrentUser
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return Card(
      color: backgroundColor,
      elevation: isCurrentUser ? 3 : 1,
      child: ListTile(
        leading: medalEmoji != null
            ? Text(
                medalEmoji,
                style: const TextStyle(fontSize: 28),
              )
            : CircleAvatar(
                backgroundColor: isCurrentUser
                    ? colorScheme.primary
                    : colorScheme.secondaryContainer,
                foregroundColor: isCurrentUser
                    ? colorScheme.onPrimary
                    : colorScheme.onSecondaryContainer,
                child: Text(
                  '$rank',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
        title: Text(
          isCurrentUser ? '${entry.name} (You)' : entry.name,
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
        subtitle: Text(
          '${entry.points} pts',
          style: TextStyle(color: textColor.withValues(alpha: 0.8)),
        ),
        trailing: isCurrentUser
            ? Icon(Icons.star_rounded, color: colorScheme.primary)
            : null,
      ),
    );
  }
}

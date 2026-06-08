import 'package:act_for_earth/features/challenges/domain/challenge.dart';
import 'package:act_for_earth/features/challenges/domain/userChallenge.dart';
import 'package:act_for_earth/features/challenges/presentation/widgets/update_progress_dialog.dart';
import 'package:flutter/material.dart';

class MyChallengiesPage extends StatelessWidget {
  const MyChallengiesPage({
    super.key,
    required this.userChallenges,
    required this.challenges,
    required this.isLoading,
    this.error,
    required this.onUpdateProgress,
    required this.onCompleteChallenge,
    required this.onLeaveChallenge,
  });

  final List<UserChallenge> userChallenges;
  final List<Challenge> challenges;
  final bool isLoading;
  final String? error;
  final Function(String, int) onUpdateProgress;
  final Function(String) onCompleteChallenge;
  final Function(String) onLeaveChallenge;

  Map<String, Challenge> _buildChallengeMap() {
    return {for (var c in challenges) c.challengeId: c};
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading && userChallenges.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error: $error',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    if (userChallenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_ind,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No challenges joined yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Join challenges to track your progress',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    final challengeMap = _buildChallengeMap();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: userChallenges.length,
      itemBuilder: (context, index) {
        final userChallenge = userChallenges[index];
        final challenge = challengeMap[userChallenge.challengeId];

        if (challenge == null) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'by ${challenge.createdBy}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: userChallenge.status == 'completed'
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        userChallenge.status,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${userChallenge.progress}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: userChallenge.progress / 100,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (userChallenge.status != 'completed')
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showUpdateProgressDialog(
                            context,
                            userChallenge,
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text('Update'),
                        ),
                      ),
                    if (userChallenge.status != 'completed')
                      const SizedBox(width: 8),
                    if (userChallenge.status != 'completed')
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () =>
                              onCompleteChallenge(userChallenge.userChallengeId),
                          icon: const Icon(Icons.check),
                          label: const Text('Complete'),
                        ),
                      ),
                    if (userChallenge.status == 'completed')
                      Expanded(
                        child: FilledButton(
                          enabled: false,
                          onPressed: null,
                          child: const Text('Completed'),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            onLeaveChallenge(userChallenge.userChallengeId),
                        icon: const Icon(Icons.close),
                        label: const Text('Leave'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUpdateProgressDialog(
    BuildContext context,
    UserChallenge userChallenge,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => UpdateProgressDialog(
        userChallenge: userChallenge,
        onUpdate: onUpdateProgress,
      ),
    );
  }
}

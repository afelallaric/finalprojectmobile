import 'package:act_for_earth/domain/model/challenge.dart';
import 'package:flutter/material.dart';

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.isJoined,
    required this.onJoin,
  });

  final Challenge challenge;
  final bool isJoined;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
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
                const SizedBox(width: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (challenge.points != null && challenge.points! > 0)
                      Chip(
                        label: Text('${challenge.points}pts'),
                        avatar: Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiaryContainer,
                        ),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .tertiaryContainer,
                      ),
                    Chip(
                      label: Text('${challenge.duration}d'),
                      avatar: Icon(
                        Icons.schedule,
                        size: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: isJoined ? null : onJoin,
              child: Text(isJoined ? 'Joined' : 'Join'),
            ),
          ],
        ),
      ),
    );
  }
}

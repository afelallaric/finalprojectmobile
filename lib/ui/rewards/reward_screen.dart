import 'package:act_for_earth/domain/model/reward_item.dart';
import 'package:act_for_earth/ui/rewards/widgets/reward_card.dart';
import 'package:flutter/material.dart';

class RewardPage extends StatelessWidget {
  const RewardPage({
    super.key,
    required this.totalPoints,
    required this.rewards,
    required this.onEarnPoints,
    required this.onSpendPoints,
    this.badges = const [],
  });

  final int totalPoints;
  final List<RewardItem> rewards;
  final VoidCallback onEarnPoints;
  final VoidCallback onSpendPoints;
  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('Eco Rewards'),
          ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Card(
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your green score',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalPoints points',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: onEarnPoints,
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('Earn 10'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onSpendPoints,
                                icon: const Icon(Icons.remove_circle_outline),
                                label: const Text('Spend 10'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
             SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Badges',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        badges.isEmpty
                            ? Text(
                                'No badges earned yet. Complete habits and suggestions to earn points!',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: badges.map((badge) {
                                  return Chip(
                                    avatar: const Icon(Icons.stars, color: Colors.amber),
                                    label: Text(badge),
                                    backgroundColor: colorScheme.secondaryContainer,
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Text(
                    'Available rewards',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final reward in rewards) ...[
                    RewardCard(reward: reward, pointsBalance: totalPoints),
                    const SizedBox(height: 12),
                  ],
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:act_for_earth/features/rewards/domain/reward_item.dart';
import 'package:flutter/material.dart';

class RewardCard extends StatelessWidget {
  const RewardCard({
    super.key,
    required this.reward,
    required this.pointsBalance,
  });

  final RewardItem reward;
  final int pointsBalance;

  @override
  Widget build(BuildContext context) {
    final canRedeem = pointsBalance >= reward.points;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 24, child: Icon(reward.icon)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reward.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Chip(label: Text('${reward.points} pts')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(reward.description),
                  const SizedBox(height: 12),
                  Text(
                    canRedeem
                        ? 'Ready to redeem'
                        : 'Keep tracking habits to unlock this reward',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

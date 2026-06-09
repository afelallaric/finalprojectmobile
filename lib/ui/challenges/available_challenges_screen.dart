import 'package:act_for_earth/domain/model/challenge.dart';
import 'package:act_for_earth/domain/model/user_challenge.dart';
import 'package:act_for_earth/ui/challenges/challenge_detail_screen.dart';
import 'package:act_for_earth/ui/challenges/widgets/challenge_card.dart';
import 'package:act_for_earth/ui/challenges/widgets/create_challenge_dialog.dart';
import 'package:flutter/material.dart';

class AvailableChallengesPage extends StatelessWidget {
  const AvailableChallengesPage({
    super.key,
    required this.challenges,
    required this.userChallenges,
    required this.isLoading,
    this.error,
    required this.onJoinChallenge,
    required this.currentUserId,
  });

  final List<Challenge> challenges;
  final List<UserChallenge> userChallenges;
  final bool isLoading;
  final String? error;
  final Function(String) onJoinChallenge;
  final String currentUserId;

  Set<String> _getJoinedChallengeIds() {
    return userChallenges.map((uc) => uc.challengeId).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _buildContent(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateChallengeDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading && challenges.isEmpty) {
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

    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No challenges available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create the first challenge to get started',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    final joinedIds = _getJoinedChallengeIds();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        final isJoined = joinedIds.contains(challenge.challengeId);

        return GestureDetector(
          onTap: () => _showChallengeDetail(context, challenge),
          child: ChallengeCard(
            challenge: challenge,
            isJoined: isJoined,
            onJoin: () => onJoinChallenge(challenge.challengeId),
          ),
        );
      },
    );
  }

  void _showChallengeDetail(BuildContext context, Challenge challenge) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChallengeDetailPage(challenge: challenge),
      ),
    );
  }

  void _showCreateChallengeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => CreateChallengeDialog(currentUserId: currentUserId),
    );
  }
}

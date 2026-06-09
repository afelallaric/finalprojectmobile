import 'package:act_for_earth/data/remote/ai_suggestion_firestore_service.dart';
import 'package:act_for_earth/data/remote/habit_log_firestore_service.dart';
import 'package:act_for_earth/data/remote/llm_service.dart';
import 'package:act_for_earth/data/remote/reward_firestore_service.dart';
import 'package:act_for_earth/domain/model/ai_suggestion.dart';
import 'package:act_for_earth/domain/model/habit.dart';
import 'package:act_for_earth/domain/repository/habit_repository.dart';
import 'package:flutter/material.dart';

class AISuggestionsPage extends StatefulWidget {
  const AISuggestionsPage({
    super.key,
    required this.userId,
    required this.habitRepository,
  });

  final String userId;
  final HabitRepository habitRepository;

  @override
  State<AISuggestionsPage> createState() => _AISuggestionsPageState();
}

class _AISuggestionsPageState extends State<AISuggestionsPage> {
  final _suggestionService = AISuggestionFirestoreService();
  final _rewardService = RewardFirestoreService();
  final _logService = HabitLogFirestoreService();
  final _llmService = LLMService();

  bool _isGenerating = false;

  Future<void> _requestSuggestions(List<Habit> habits) async {
    if (habits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some habits first before requesting suggestions.')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // Fetch some logs to summarize activity
      final logs = await _logService.watchAllLogs().first.catchError((_) => []);
      final logsSummary = logs.map((log) {
        final habit = habits.firstWhere(
          (h) => h.habitId == log.habitId,
          orElse: () => Habit(userId: '', title: 'Unknown', category: '', targetFrequency: 1, createdAt: DateTime.now()),
        );
        return '${habit.title} log completed status: ${log.status} on ${log.date.toLocal().toString().split(' ')[0]}';
      }).toList();

      final habitStrings = habits.map((h) => '${h.title} (Category: ${h.category}, Goal: ${h.targetFrequency}/week)').toList();

      final suggestions = await _llmService.generateSuggestions(
        habits: habitStrings,
        logsSummary: logsSummary.isEmpty ? ['No completions logged yet.'] : logsSummary,
      );

      for (final text in suggestions) {
        await _suggestionService.createSuggestion(
          AISuggestion(
            suggestionId: '',
            userId: widget.userId,
            text: text,
            status: 'pending',
            createdAt: DateTime.now(),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI Suggestions generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate suggestions: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _markCompleted(AISuggestion suggestion) async {
    try {
      await _suggestionService.updateSuggestionStatus(suggestion.suggestionId, 'completed');
      // Reward user with 15 points!
      await _rewardService.addPoints(widget.userId, 15);
      
      // Auto-unlock badges if points criteria is met
      final rewards = await _rewardService.getOrCreateUserReward(widget.userId);
      if (rewards.points >= 200) {
        await _rewardService.addBadge(widget.userId, 'Eco Guardian');
      } else if (rewards.points >= 100) {
        await _rewardService.addBadge(widget.userId, 'Eco Hero');
      } else if (rewards.points >= 50) {
        await _rewardService.addBadge(widget.userId, 'Green Pioneer');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suggestion completed! Earned 15 points! 🎉')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteSuggestion(AISuggestion suggestion) async {
    try {
      await _suggestionService.deleteSuggestion(suggestion.suggestionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suggestion deleted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<Habit>>(
      stream: widget.habitRepository.watchHabits(widget.userId),
      builder: (context, habitSnapshot) {
        final habits = habitSnapshot.data ?? [];

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.1),
                  colorScheme.surface,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Eco-Suggestions',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Personalized tips based on your logged habits.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _isGenerating
                            ? const CircularProgressIndicator()
                            : FloatingActionButton.extended(
                                onPressed: () => _requestSuggestions(habits),
                                icon: const Icon(Icons.psychology),
                                label: const Text('Generate'),
                              ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: StreamBuilder<List<AISuggestion>>(
                        stream: _suggestionService.watchSuggestions(widget.userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final suggestions = snapshot.data ?? [];
                          if (suggestions.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.tips_and_updates_outlined,
                                    size: 64,
                                    color: colorScheme.secondary.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No suggestions yet.',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap Generate to get custom eco-friendly suggestions!',
                                    style: Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: suggestions.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final suggestion = suggestions[index];
                              final isCompleted = suggestion.status == 'completed';

                              return Card(
                                elevation: isCompleted ? 1 : 3,
                                color: isCompleted
                                    ? colorScheme.surfaceVariant.withValues(alpha: 0.5)
                                    : colorScheme.surface,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            isCompleted ? Icons.check_circle : Icons.lightbulb,
                                            color: isCompleted ? Colors.green : Colors.amber,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              suggestion.text,
                                              style: TextStyle(
                                                fontSize: 15,
                                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                                fontWeight: isCompleted ? FontWeight.normal : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 20),
                                            onPressed: () => _deleteSuggestion(suggestion),
                                          ),
                                        ],
                                      ),
                                      if (!isCompleted) ...[
                                        const Divider(height: 24),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () => _markCompleted(suggestion),
                                            icon: const Icon(Icons.done, size: 18),
                                            label: const Text('Mark Completed'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:act_for_earth/features/challenges/data/challenge_firestore_service.dart';
import 'package:act_for_earth/features/challenges/domain/challenge.dart';
import 'package:flutter/material.dart';

class CreateChallengeDialog extends StatefulWidget {
  const CreateChallengeDialog({
    super.key,
    required this.currentUserId,
  });

  final String currentUserId;

  @override
  State<CreateChallengeDialog> createState() => _CreateChallengeDialogState();
}

class _CreateChallengeDialogState extends State<CreateChallengeDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _durationController = TextEditingController(text: '7');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final duration = int.tryParse(_durationController.text.trim());

    if (title.isEmpty || description.isEmpty || duration == null || duration <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final service = ChallengeFirestoreService();
      final challenge = Challenge(
        title: title,
        description: description,
        duration: duration,
        createdBy: widget.currentUserId,
      );
      await service.createChallenge(challenge);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge created!')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Challenge'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Plastic-Free Week',
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Challenge details',
              ),
              maxLines: 3,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(
                labelText: 'Duration (days)',
                hintText: '7',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}

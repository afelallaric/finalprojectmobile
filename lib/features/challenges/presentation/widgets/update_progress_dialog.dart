import 'package:act_for_earth/features/challenges/domain/userChallenge.dart';
import 'package:flutter/material.dart';

class UpdateProgressDialog extends StatefulWidget {
  const UpdateProgressDialog({
    super.key,
    required this.userChallenge,
    required this.onUpdate,
  });

  final UserChallenge userChallenge;
  final Function(String, int) onUpdate;

  @override
  State<UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<UpdateProgressDialog> {
  late int _progress;

  @override
  void initState() {
    super.initState();
    _progress = widget.userChallenge.progress;
  }

  Future<void> _submitUpdate() async {
    try {
      await widget.onUpdate(
        widget.userChallenge.userChallengeId,
        _progress,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Progress'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Current Progress: $_progress%',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Slider(
            value: _progress.toDouble(),
            min: 0,
            max: 100,
            divisions: 10,
            label: '$_progress%',
            onChanged: (value) => setState(() => _progress = value.toInt()),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mark Complete?',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Switch(
                  value: _progress == 100,
                  onChanged: (value) {
                    setState(() => _progress = value ? 100 : 0);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitUpdate,
          child: const Text('Update'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class LeaderboardEntryDialog extends StatefulWidget {
  const LeaderboardEntryDialog({
    super.key,
    this.initialName = '',
    this.initialPoints = 0,
  });

  final String initialName;
  final int initialPoints;

  @override
  State<LeaderboardEntryDialog> createState() => _LeaderboardEntryDialogState();
}

class _LeaderboardEntryDialogState extends State<LeaderboardEntryDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _pointsController = TextEditingController(
      text: widget.initialPoints.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final points = int.tryParse(_pointsController.text.trim());

    if (name.isEmpty || points == null) {
      return;
    }

    Navigator.of(
      context,
    ).pop(LeaderboardFormResult(name: name, points: points));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Leaderboard entry'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pointsController,
            decoration: const InputDecoration(labelText: 'Points'),
            keyboardType: TextInputType.number,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

class LeaderboardFormResult {
  const LeaderboardFormResult({required this.name, required this.points});

  final String name;
  final int points;
}

import 'package:flutter/material.dart';

class HabitFormDialog extends StatefulWidget {
  const HabitFormDialog({
    super.key,
    this.initialTitle = '',
    this.initialCategory = '',
    this.initialTargetFrequency = 1,
  });

  final String initialTitle;
  final String initialCategory;
  final int initialTargetFrequency;

  @override
  State<HabitFormDialog> createState() => _HabitFormDialogState();
}

class _HabitFormDialogState extends State<HabitFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _frequencyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _categoryController = TextEditingController(text: widget.initialCategory);
    _frequencyController = TextEditingController(
      text: widget.initialTargetFrequency.toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final category = _categoryController.text.trim();
    final targetFrequency = int.tryParse(_frequencyController.text.trim());

    if (title.isEmpty ||
        category.isEmpty ||
        targetFrequency == null ||
        targetFrequency <= 0) {
      return;
    }

    Navigator.of(context).pop(
      HabitFormResult(
        title: title,
        category: category,
        targetFrequency: targetFrequency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Habit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Category'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _frequencyController,
            decoration: const InputDecoration(
              labelText: 'Target frequency per week',
            ),
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

class HabitFormResult {
  const HabitFormResult({
    required this.title,
    required this.category,
    required this.targetFrequency,
  });

  final String title;
  final String category;
  final int targetFrequency;
}

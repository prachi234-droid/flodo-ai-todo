import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task_draft.dart';
import '../models/task_item.dart';
import '../models/task_status.dart';
import '../utils/date_formatter.dart';

Future<void> showTaskFormSheet(
  BuildContext context, {
  required TaskController controller,
  TaskItem? task,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return TaskFormSheet(controller: controller, task: task);
    },
  );
}

class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({
    required this.controller,
    this.task,
    super.key,
  });

  final TaskController controller;
  final TaskItem? task;

  bool get isEditing => task != null;

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _dueDate;
  late TaskStatus _status;
  String? _blockedByTaskId;

  bool get _isEditing => widget.isEditing;

  @override
  void initState() {
    super.initState();
    final draft = widget.controller.draft;
    final initialTask = widget.task;

    _titleController = TextEditingController(
      text: initialTask?.title ?? draft.title,
    )..addListener(_persistDraftIfNeeded);
    _descriptionController = TextEditingController(
      text: initialTask?.description ?? draft.description,
    )..addListener(_persistDraftIfNeeded);
    _dueDate = initialTask?.dueDate ?? draft.dueDate ?? DateTime.now();
    _status = initialTask?.status ?? draft.status;
    _blockedByTaskId = initialTask?.blockedByTaskId ?? draft.blockedByTaskId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _persistDraftIfNeeded() {
    if (_isEditing) {
      return;
    }
    widget.controller.saveDraft(
      TaskDraft(
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        status: _status,
        blockedByTaskId: _blockedByTaskId,
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _dueDate = selected;
    });
    _persistDraftIfNeeded();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isEditing) {
      await widget.controller.updateTask(
        original: widget.task!,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        status: _status,
        blockedByTaskId: _blockedByTaskId,
      );
    } else {
      await widget.controller.createTask(
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        status: _status,
        blockedByTaskId: _blockedByTaskId,
      );
    }

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final blockerOptions = widget.controller.availableBlockers
        .where((candidate) => candidate.id != widget.task?.id)
        .toList();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4DCE6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isEditing ? 'Edit task' : 'Create task',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEditing
                          ? 'Update the details and keep execution moving.'
                          : 'Draft values are preserved if you close this form before saving.',
                      style: const TextStyle(
                        color: Color(0xFF5A6B83),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Design onboarding flow',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Add the implementation details for the task.',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(18),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Due date: ${formatDate(_dueDate)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskStatus>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: TaskStatus.values
                          .map(
                            (status) => DropdownMenuItem<TaskStatus>(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _status = value;
                        });
                        _persistDraftIfNeeded();
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      value: blockerOptions.any((task) => task.id == _blockedByTaskId)
                          ? _blockedByTaskId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Blocked by',
                        hintText: 'Select dependency',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('No dependency'),
                        ),
                        ...blockerOptions.map(
                          (candidate) => DropdownMenuItem<String?>(
                            value: candidate.id,
                            child: Text(candidate.title),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _blockedByTaskId = value;
                        });
                        _persistDraftIfNeeded();
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.controller.isSaving ? null : _submit,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: widget.controller.isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.2),
                              )
                            : Text(_isEditing ? 'Save changes' : 'Save task'),
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

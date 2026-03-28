import 'package:flutter/material.dart';

import '../models/task_status.dart';

class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({
    required this.status,
    super.key,
  });

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = switch (status) {
      TaskStatus.todo => (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
      TaskStatus.inProgress => (const Color(0xFFDCEAFE), const Color(0xFF1D4ED8)),
      TaskStatus.done => (const Color(0xFFDCFCE7), const Color(0xFF166534)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: colors.$2,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

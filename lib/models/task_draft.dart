import 'dart:convert';

import 'task_status.dart';

class TaskDraft {
  const TaskDraft({
    this.title = '',
    this.description = '',
    this.dueDate,
    this.status = TaskStatus.todo,
    this.blockedByTaskId,
  });

  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskStatus status;
  final String? blockedByTaskId;

  bool get isEmpty =>
      title.trim().isEmpty &&
      description.trim().isEmpty &&
      dueDate == null &&
      blockedByTaskId == null &&
      status == TaskStatus.todo;

  TaskDraft copyWith({
    String? title,
    String? description,
    Object? dueDate = _sentinel,
    TaskStatus? status,
    Object? blockedByTaskId = _sentinel,
  }) {
    return TaskDraft(
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate == _sentinel ? this.dueDate : dueDate as DateTime?,
      status: status ?? this.status,
      blockedByTaskId: blockedByTaskId == _sentinel
          ? this.blockedByTaskId
          : blockedByTaskId as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'status': status.name,
      'blockedByTaskId': blockedByTaskId,
    };
  }

  factory TaskDraft.fromMap(Map<String, dynamic> map) {
    return TaskDraft(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueDate: map['dueDate'] == null
          ? null
          : DateTime.parse(map['dueDate'] as String),
      status: TaskStatus.fromKey(map['status'] as String? ?? ''),
      blockedByTaskId: map['blockedByTaskId'] as String?,
    );
  }

  String encode() => jsonEncode(toMap());

  factory TaskDraft.decode(String raw) {
    return TaskDraft.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }
}

const _sentinel = Object();

import 'dart:convert';

import 'task_status.dart';

class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedByTaskId,
    required this.position,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final String? blockedByTaskId;
  final int position;
  final DateTime createdAt;

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    Object? blockedByTaskId = _sentinel,
    int? position,
    DateTime? createdAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedByTaskId: blockedByTaskId == _sentinel
          ? this.blockedByTaskId
          : blockedByTaskId as String?,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'blockedByTaskId': blockedByTaskId,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueDate: DateTime.parse(map['dueDate'] as String),
      status: TaskStatus.fromKey(map['status'] as String? ?? ''),
      blockedByTaskId: map['blockedByTaskId'] as String?,
      position: map['position'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  static List<TaskItem> decodeList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => TaskItem.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static String encodeList(List<TaskItem> tasks) {
    return jsonEncode(tasks.map((task) => task.toMap()).toList());
  }
}

const _sentinel = Object();

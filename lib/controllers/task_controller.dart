import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task_draft.dart';
import '../models/task_item.dart';
import '../models/task_status.dart';
import '../services/local_storage_service.dart';

class TaskController extends ChangeNotifier {
  TaskController({required LocalStorageService storage}) : _storage = storage;

  final LocalStorageService _storage;

  final List<TaskItem> _tasks = [];
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isSaving = false;
  String _searchQuery = '';
  String _effectiveSearchQuery = '';
  TaskStatus? _statusFilter;
  Timer? _searchDebounce;
  TaskDraft _draft = const TaskDraft();

  List<TaskItem> get tasks => List.unmodifiable(_tasks);
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String get searchQuery => _searchQuery;
  String get effectiveSearchQuery => _effectiveSearchQuery;
  TaskStatus? get statusFilter => _statusFilter;
  TaskDraft get draft => _draft;

  List<TaskItem> get visibleTasks {
    final query = _searchQuery.trim().toLowerCase();
    return _sortedTasks.where((task) {
      final matchesSearch = query.isEmpty || task.title.toLowerCase().contains(query);
      final matchesFilter = _statusFilter == null || task.status == _statusFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<TaskItem> get autocompleteSuggestions {
    final query = _effectiveSearchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return const [];
    }

    final seen = <String>{};
    final matches = <TaskItem>[];
    for (final task in _sortedTasks) {
      final title = task.title.trim();
      if (title.toLowerCase().contains(query) && seen.add(title.toLowerCase())) {
        matches.add(task);
      }
      if (matches.length == 5) {
        break;
      }
    }
    return matches;
  }

  List<TaskItem> get availableBlockers => _sortedTasks;

  List<TaskItem> get _sortedTasks {
    final items = [..._tasks];
    items.sort((a, b) {
      final positionCompare = a.position.compareTo(b.position);
      if (positionCompare != 0) {
        return positionCompare;
      }
      return a.createdAt.compareTo(b.createdAt);
    });
    return items;
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _tasks
      ..clear()
      ..addAll(await _storage.loadTasks());
    _draft = await _storage.loadDraft();
    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskStatus status,
    String? blockedByTaskId,
  }) async {
    if (_isSaving) {
      return;
    }

    _isSaving = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(seconds: 2));

    final task = TaskItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
      status: status,
      blockedByTaskId: blockedByTaskId,
      position: _tasks.length,
      createdAt: DateTime.now(),
    );

    _tasks.add(task);
    await _storage.saveTasks(_tasks);
    await clearDraft();

    _isSaving = false;
    notifyListeners();
  }

  Future<void> updateTask({
    required TaskItem original,
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskStatus status,
    String? blockedByTaskId,
  }) async {
    if (_isSaving) {
      return;
    }

    _isSaving = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(seconds: 2));

    final index = _tasks.indexWhere((task) => task.id == original.id);
    if (index == -1) {
      _isSaving = false;
      notifyListeners();
      return;
    }

    _tasks[index] = original.copyWith(
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
      status: status,
      blockedByTaskId: blockedByTaskId,
    );
    await _storage.saveTasks(_tasks);
    _isSaving = false;
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    for (var i = 0; i < _tasks.length; i++) {
      _tasks[i] = _tasks[i].copyWith(
        position: i,
        blockedByTaskId: _tasks[i].blockedByTaskId == taskId
            ? null
            : _tasks[i].blockedByTaskId,
      );
    }
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    final items = [..._sortedTasks];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final moved = items.removeAt(oldIndex);
    items.insert(newIndex, moved);

    for (var i = 0; i < items.length; i++) {
      final currentIndex = _tasks.indexWhere((task) => task.id == items[i].id);
      _tasks[currentIndex] = items[i].copyWith(position: i);
    }

    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> saveDraft(TaskDraft draft) async {
    _draft = draft;
    notifyListeners();
    await _storage.saveDraft(draft);
  }

  Future<void> clearDraft() async {
    _draft = const TaskDraft();
    notifyListeners();
    await _storage.clearDraft();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _effectiveSearchQuery = value;
      notifyListeners();
    });
  }

  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void applySuggestion(String title) {
    _searchQuery = title;
    _effectiveSearchQuery = title;
    notifyListeners();
  }

  bool isBlocked(TaskItem task) {
    if (task.blockedByTaskId == null) {
      return false;
    }
    final dependency = getTaskById(task.blockedByTaskId!);
    return dependency != null && dependency.status != TaskStatus.done;
  }

  TaskItem? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}

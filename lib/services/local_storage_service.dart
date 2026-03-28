import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_draft.dart';
import '../models/task_item.dart';

class LocalStorageService {
  static const _tasksKey = 'tasks';
  static const _draftKey = 'create_task_draft';

  Future<List<TaskItem>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    return TaskItem.decodeList(raw);
  }

  Future<void> saveTasks(List<TaskItem> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksKey, TaskItem.encodeList(tasks));
  }

  Future<TaskDraft> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey);
    if (raw == null || raw.isEmpty) {
      return const TaskDraft();
    }
    return TaskDraft.decode(raw);
  }

  Future<void> saveDraft(TaskDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    if (draft.isEmpty) {
      await prefs.remove(_draftKey);
      return;
    }
    await prefs.setString(_draftKey, draft.encode());
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }
}

import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task_status.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import 'task_form_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.controller,
    super.key,
  });

  final TaskController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()
      ..text = widget.controller.searchQuery;
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (_searchController.text == widget.controller.searchQuery) {
      return;
    }
    _searchController.value = TextEditingValue(
      text: widget.controller.searchQuery,
      selection: TextSelection.collapsed(
        offset: widget.controller.searchQuery.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showTaskFormSheet(
              context,
              controller: widget.controller,
            ),
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('New task'),
          ),
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE6FFFB), Color(0xFFF4F7FB), Color(0xFFFFFBEB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: widget.controller.isLoading && !widget.controller.isInitialized
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: widget.controller.initialize,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Execution board',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Track work, surface blockers, and keep drafts safe.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: const Color(0xFF516277).withOpacity(0.95),
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  _OverviewBanner(controller: widget.controller),
                                  const SizedBox(height: 18),
                                  TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.search_rounded),
                                      hintText: 'Search tasks by title',
                                    ),
                                    onChanged: widget.controller.setSearchQuery,
                                  ),
                                  if (widget.controller.autocompleteSuggestions.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        children: widget.controller.autocompleteSuggestions
                                            .map(
                                              (task) => ListTile(
                                                dense: true,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                title: Text(task.title),
                                                subtitle: Text(
                                                  task.status.label,
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                                onTap: () {
                                                  widget.controller.applySuggestion(task.title);
                                                },
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _FilterChip(
                                          label: 'All',
                                          selected: widget.controller.statusFilter == null,
                                          onTap: () => widget.controller.setStatusFilter(null),
                                        ),
                                        ...TaskStatus.values.map(
                                          (status) => _FilterChip(
                                            label: status.label,
                                            selected:
                                                widget.controller.statusFilter == status,
                                            onTap: () => widget.controller.setStatusFilter(status),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
                          if (widget.controller.visibleTasks.isEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: EmptyState(
                                  title: widget.controller.tasks.isEmpty
                                      ? 'No tasks yet'
                                      : 'No matching tasks',
                                  message: widget.controller.tasks.isEmpty
                                      ? 'Create your first task to start tracking work and dependencies.'
                                      : 'Try a different search term or status filter.',
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                              sliver: SliverReorderableList(
                                itemCount: widget.controller.visibleTasks.length,
                                onReorder: widget.controller.searchQuery.isNotEmpty ||
                                        widget.controller.statusFilter != null
                                    ? (_, __) {}
                                    : widget.controller.reorderTasks,
                                itemBuilder: (context, index) {
                                  final task = widget.controller.visibleTasks[index];
                                  final blocker = task.blockedByTaskId == null
                                      ? null
                                      : widget.controller.getTaskById(task.blockedByTaskId!);
                                  return Padding(
                                    key: ValueKey(task.id),
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: TaskCard(
                                      task: task,
                                      blockerTitle: blocker?.title,
                                      isBlocked: widget.controller.isBlocked(task),
                                      highlightQuery: widget.controller.searchQuery,
                                      onEdit: () => showTaskFormSheet(
                                        context,
                                        controller: widget.controller,
                                        task: task,
                                      ),
                                      onDelete: () => widget.controller.deleteTask(task.id),
                                    ),
                                  );
                                },
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

class _OverviewBanner extends StatelessWidget {
  const _OverviewBanner({required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    final doneCount = controller.tasks
        .where((task) => task.status == TaskStatus.done)
        .length;
    final blockedCount = controller.tasks.where(controller.isBlocked).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF115E59), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0369A1).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Wrap(
        runSpacing: 18,
        spacing: 18,
        alignment: WrapAlignment.spaceBetween,
        children: [
          _Metric(label: 'Total', value: controller.tasks.length.toString()),
          _Metric(label: 'Done', value: doneCount.toString()),
          _Metric(label: 'Blocked', value: blockedCount.toString()),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFFCCFBF1),
        side: BorderSide.none,
        labelStyle: TextStyle(
          color: selected ? const Color(0xFF115E59) : const Color(0xFF475569),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

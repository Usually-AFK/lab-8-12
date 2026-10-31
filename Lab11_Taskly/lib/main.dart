import 'package:flutter/material.dart';

import 'models/task.dart';
import 'repositories/task_repository.dart';

void main() => runApp(TasklyApp(repository: TaskRepository()));

class TasklyApp extends StatelessWidget {
  const TasklyApp({super.key, required this.repository});
  final TaskRepository repository;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Taskly',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff315f55)),
      useMaterial3: true,
    ),
    home: TaskListScreen(repository: repository),
  );
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, required this.repository});
  final TaskRepository repository;
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _input = TextEditingController();
  void _add() {
    final value = _input.text.trim();
    if (value.isEmpty) return;
    setState(() {
      widget.repository.addTask(value);
      _input.clear();
    });
  }

  Future<void> _open(Task task) async {
    final updated = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );
    if (updated != null && mounted) {
      setState(() => widget.repository.updateTask(updated));
    }
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.repository.tasks;
    return Scaffold(
      appBar: AppBar(title: const Text('Taskly')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('newTaskField'),
                    controller: _input,
                    onSubmitted: (_) => _add(),
                    decoration: const InputDecoration(
                      hintText: 'What needs to get done?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  key: const Key('addTaskButton'),
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                  tooltip: 'Add task',
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('No tasks yet. Add one!'))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ListTile(
                        key: ValueKey(task.id),
                        leading: Checkbox(
                          value: task.completed,
                          onChanged: (_) => setState(
                            () => widget.repository.updateTask(task.toggle()),
                          ),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        onTap: () => _open(task),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => setState(
                            () => widget.repository.deleteTask(task.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.task});
  final Task task;
  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late final _title = TextEditingController(text: widget.task.title);
  void _save() {
    final value = _title.text.trim();
    if (value.isEmpty) return;
    Navigator.pop(context, widget.task.copyWith(title: value));
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Task Detail')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            key: const Key('detailTitleField'),
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Task title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('saveTaskButton'),
            onPressed: _save,
            child: const Text('Save changes'),
          ),
        ],
      ),
    ),
  );
}

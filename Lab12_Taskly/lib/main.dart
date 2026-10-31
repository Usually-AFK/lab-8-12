import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => TaskProvider(),
    child: const TasklyOptimizedApp(),
  ),
);

class TaskItem {
  const TaskItem({required this.id, required this.title, this.done = false});
  final int id;
  final String title;
  final bool done;
  TaskItem copyWith({String? title, bool? done}) =>
      TaskItem(id: id, title: title ?? this.title, done: done ?? this.done);
}

class TaskProvider extends ChangeNotifier {
  final List<TaskItem> _items = [];
  int _nextId = 1;
  List<TaskItem> get tasks => List.unmodifiable(_items);
  void add(String title) {
    _items.add(TaskItem(id: _nextId++, title: title));
    notifyListeners();
  }

  void toggle(TaskItem task) {
    final i = _items.indexWhere((e) => e.id == task.id);
    if (i < 0) return;
    _items[i] = task.copyWith(done: !task.done);
    notifyListeners();
  }

  void delete(TaskItem task) {
    _items.removeWhere((e) => e.id == task.id);
    notifyListeners();
  }

  void rename(TaskItem task, String title) {
    final i = _items.indexWhere((e) => e.id == task.id);
    if (i < 0) return;
    _items[i] = task.copyWith(title: title);
    notifyListeners();
  }
}

class TasklyOptimizedApp extends StatelessWidget {
  const TasklyOptimizedApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Taskly Optimized',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff286a54)),
      useMaterial3: true,
    ),
    home: const OptimizedTaskListScreen(),
  );
}

class OptimizedTaskListScreen extends StatefulWidget {
  const OptimizedTaskListScreen({super.key});
  @override
  State<OptimizedTaskListScreen> createState() =>
      _OptimizedTaskListScreenState();
}

class _OptimizedTaskListScreenState extends State<OptimizedTaskListScreen> {
  final _input = TextEditingController();
  @override
  void initState() {
    super.initState();
    precacheImage(const AssetImage('assets/task_icon.png'), context);
  }

  void _add() {
    final title = _input.text.trim();
    if (title.isEmpty) return;
    context.read<TaskProvider>().add(title);
    _input.clear();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Row(
        children: [
          Image.asset('assets/task_icon.png', width: 28, height: 28),
          const SizedBox(width: 10),
          const Text('Taskly'),
        ],
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  onSubmitted: (_) => _add(),
                  decoration: const InputDecoration(
                    hintText: 'Add a task',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(onPressed: _add, icon: const Icon(Icons.add)),
            ],
          ),
        ),
        Expanded(
          child: Selector<TaskProvider, List<TaskItem>>(
            selector: (_, provider) => provider.tasks,
            builder: (context, tasks, _) => tasks.isEmpty
                ? const Center(child: Text('Nothing on your list yet.'))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskTile(key: ValueKey(task.id), taskId: task.id);
                    },
                  ),
          ),
        ),
      ],
    ),
  );
}

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.taskId});
  final int taskId;
  @override
  Widget build(BuildContext context) => Selector<TaskProvider, TaskItem?>(
    selector: (_, provider) {
      for (final task in provider.tasks) {
        if (task.id == taskId) return task;
      }
      return null;
    },
    builder: (context, task, _) => task == null
        ? const SizedBox.shrink()
        : ListTile(
            key: ValueKey(task.id),
            leading: Checkbox(
              value: task.done,
              onChanged: (_) => context.read<TaskProvider>().toggle(task),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.done ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => context.read<TaskProvider>().delete(task),
            ),
          ),
  );
}

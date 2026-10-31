import '../models/task.dart';

class TaskRepository {
  TaskRepository({List<Task> initial = const []}) : _tasks = List.of(initial) {
    _nextId =
        _tasks.fold<int>(0, (max, task) => task.id > max ? task.id : max) + 1;
  }
  final List<Task> _tasks;
  List<Task> get tasks => List.unmodifiable(_tasks);
  int _nextId = 1;
  Task addTask(String title) {
    final task = Task(id: _nextId++, title: title);
    _tasks.add(task);
    return task;
  }

  bool deleteTask(int id) {
    final i = _tasks.indexWhere((e) => e.id == id);
    if (i < 0) return false;
    _tasks.removeAt(i);
    return true;
  }

  void updateTask(Task task) {
    final i = _tasks.indexWhere((e) => e.id == task.id);
    if (i >= 0) _tasks[i] = task;
  }
}

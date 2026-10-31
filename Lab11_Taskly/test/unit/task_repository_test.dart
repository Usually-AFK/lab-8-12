import 'package:flutter_test/flutter_test.dart';
import 'package:lab11_taskly/models/task.dart';
import 'package:lab11_taskly/repositories/task_repository.dart';

void main() {
  late TaskRepository repository;
  setUp(() => repository = TaskRepository());
  test('addTask creates a task with a unique id', () {
    final first = repository.addTask('One');
    final second = repository.addTask('Two');
    expect(repository.tasks.map((task) => task.title), ['One', 'Two']);
    expect(first.id, isNot(second.id));
  });
  test('deleteTask removes the matching task', () {
    final task = repository.addTask('Remove me');
    expect(repository.deleteTask(task.id), isTrue);
    expect(repository.tasks, isEmpty);
  });
  test('updateTask replaces the matching task', () {
    final task = repository.addTask('Before');
    repository.updateTask(task.copyWith(title: 'After'));
    expect(repository.tasks.single.title, 'After');
  });
  test('seeded IDs do not collide with newly added tasks', () {
    repository = TaskRepository(initial: const [Task(id: 5, title: 'Seed')]);
    expect(repository.addTask('New').id, 6);
  });
}

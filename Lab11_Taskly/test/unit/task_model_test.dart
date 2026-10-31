import 'package:flutter_test/flutter_test.dart';
import 'package:lab11_taskly/models/task.dart';

void main() {
  test('new tasks are incomplete by default', () {
    const task = Task(id: 1, title: 'Read');
    expect(task.completed, isFalse);
  });
  test('toggle switches completion both ways', () {
    const task = Task(id: 1, title: 'Read');
    expect(task.toggle().completed, isTrue);
    expect(task.toggle().toggle().completed, isFalse);
  });
}

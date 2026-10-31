import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab11_taskly/main.dart';
import 'package:lab11_taskly/models/task.dart';
import 'package:lab11_taskly/repositories/task_repository.dart';

void main() {
  testWidgets('tapping a task opens its detail screen', (tester) async {
    final repository = TaskRepository(initial: const [Task(id: 1, title: 'Seed task')]);
    await tester.pumpWidget(TasklyApp(repository: repository));
    await tester.tap(find.text('Seed task'));
    await tester.pumpAndSettle();
    expect(find.text('Task Detail'), findsOneWidget);
    expect(find.byKey(const Key('detailTitleField')), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab11_taskly/main.dart';
import 'package:lab11_taskly/repositories/task_repository.dart';

void main() {
  testWidgets('shows the empty state', (tester) async {
    await tester.pumpWidget(TasklyApp(repository: TaskRepository()));
    expect(find.text('No tasks yet. Add one!'), findsOneWidget);
  });
  testWidgets('adds tasks from the input', (tester) async {
    await tester.pumpWidget(TasklyApp(repository: TaskRepository()));
    await tester.enterText(find.byKey(const Key('newTaskField')), 'Buy milk');
    await tester.tap(find.byKey(const Key('addTaskButton')));
    await tester.pump();
    expect(find.text('Buy milk'), findsOneWidget);
  });
  testWidgets('shows multiple tasks', (tester) async {
    await tester.pumpWidget(TasklyApp(repository: TaskRepository()));
    for (final title in ['First task', 'Second task']) {
      await tester.enterText(find.byKey(const Key('newTaskField')), title);
      await tester.tap(find.byKey(const Key('addTaskButton')));
      await tester.pump();
    }
    expect(find.text('First task'), findsOneWidget);
    expect(find.text('Second task'), findsOneWidget);
  });
}

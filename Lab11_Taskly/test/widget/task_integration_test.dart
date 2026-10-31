import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab11_taskly/main.dart';
import 'package:lab11_taskly/repositories/task_repository.dart';

void main() {
  testWidgets('add, edit, save, and see the updated task', (tester) async {
    await tester.pumpWidget(TasklyApp(repository: TaskRepository()));
    await tester.enterText(find.byKey(const Key('newTaskField')), 'Original title');
    await tester.tap(find.byKey(const Key('addTaskButton')));
    await tester.pump();
    await tester.tap(find.text('Original title'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('detailTitleField')), 'Updated title');
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();
    expect(find.text('Updated title'), findsOneWidget);
  });
}

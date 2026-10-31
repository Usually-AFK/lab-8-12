class Task {
  const Task({required this.id, required this.title, this.completed = false});
  final int id;
  final String title;
  final bool completed;
  Task toggle() => copyWith(completed: !completed);
  Task copyWith({String? title, bool? completed}) => Task(
    id: id,
    title: title ?? this.title,
    completed: completed ?? this.completed,
  );
}

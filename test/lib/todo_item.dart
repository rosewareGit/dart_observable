class TodoItem {
  final String id;
  final String title;
  final String description;
  final bool completed;

  TodoItem({
    required this.id,
    this.title = '',
    this.description = '',
    this.completed = false,
  });
}

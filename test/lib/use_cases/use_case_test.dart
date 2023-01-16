import 'package:test/test.dart';

void main() {
  group('Use Case tests', () {
    test('Show the number of uncompleted tasks', () {});
  });
}

class TodoItem {
  final String id;
  final String name;
  final bool isCompleted;

  TodoItem({
    required this.id,
    required this.name,
    required this.isCompleted,
  });
}

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

import '../../../../todo_item.dart';

void main() {
  group('ObservableStatefulSet', () {
    group('length', () {
      test('should return the length', () {
        final RxStatefulSet<int, String> set = RxStatefulSet<int, String>(initial: <int>{1, 2, 3});
        expect(set.length, 3);

        set.add(4);
        expect(set.length, 4);

        set.setState('custom');
        expect(set.length, null);
      });
    });

    group('changeFactory', () {
      test('should change the factory', () async {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>{1, 2, 3});
        final ObservableStatefulSet<int, String> rxNew = rxSet.changeFactory((final Iterable<int>? items) {
          return Set<int>.of(items ?? <int>[]);
        });

        rxNew.listen();

        expect(rxNew.value.leftOrThrow.setView, <int>{1, 2, 3});

        rxSet.add(4);

        expect(rxNew.value.leftOrThrow.setView, <int>[1, 2, 3, 4]);

        rxSet.setState('custom');

        expect(rxNew.value.leftOrNull, null);

        rxSet.add(5);

        expect(rxNew.value.leftOrThrow.setView, <int>[5]);

        await rxSet.dispose();

        expect(rxNew.disposed, true);
      });
    });

    group('filterItem', () {
      test('should filter the items', () async {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulSet<int, String> rxNew = rxSet.filterItem((final int item) => item.isOdd);

        rxNew.listen();
        expect(rxNew.value.leftOrThrow.setView, <int>[1, 3, 5]);

        rxSet.add(6);
        expect(rxNew.value.leftOrThrow.setView, <int>[1, 3, 5]);

        rxSet.add(7);
        expect(rxNew.value.leftOrThrow.setView, <int>[1, 3, 5, 7]);

        rxSet.remove(3);
        expect(rxNew.value.leftOrThrow.setView, <int>[1, 5, 7]);

        rxSet.setState('custom');
        expect(rxNew.value.leftOrNull, null);

        rxSet.add(8);
        expect(rxNew.value.leftOrThrow.setView, <int>[]);

        rxSet.add(9);
        expect(rxNew.value.leftOrThrow.setView, <int>[9]);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.leftOrThrow.setView, <int>[9, 11]);

        rxSet.clear();
        expect(rxNew.value.leftOrThrow.setView, <int>[]);

        await rxSet.dispose();

        expect(rxNew.disposed, true);
      });
    });

    group('rxItem', () {
      test('should return the item by the predicate', () async {
        final TodoItem todoItem1 = TodoItem(id: '1', title: 'title 1', description: 'description 1');
        final TodoItem todoItem2 = TodoItem(id: '2', title: 'title 2', description: 'description 2');
        final TodoItem todoItem2Copy = TodoItem(id: '2', title: 'title 2 copy', description: 'description 2 copy');
        final RxStatefulSet<TodoItem, String> rxSet = RxStatefulSet<TodoItem, String>(
          initial: <TodoItem>[
            todoItem1,
            todoItem2,
          ],
        );

        final Observable<Either<TodoItem?, String>> rxTodoItem = rxSet.rxItem((final TodoItem item) => item.id == '2');

        rxTodoItem.listen();
        expect(rxTodoItem.value.leftOrNull, todoItem2);

        rxSet.add(TodoItem(id: '3', title: 'title 3', description: 'description 3'));

        expect(rxTodoItem.value.leftOrNull, todoItem2);

        rxSet.remove(todoItem2);
        expect(rxTodoItem.value.leftOrNull, null);

        rxSet.add(todoItem2);
        expect(rxTodoItem.value.leftOrNull, todoItem2);

        rxSet.applySetUpdateAction(
          ObservableSetUpdateAction<TodoItem>(
            addItems: <TodoItem>{todoItem2Copy},
            removeItems: <TodoItem>{todoItem2},
          ),
        );

        expect(rxTodoItem.value.leftOrNull, todoItem2Copy);

        rxSet.setState('custom');
        expect(rxTodoItem.value.leftOrNull, null);
        expect(rxTodoItem.value.rightOrNull, 'custom');

        rxSet.clear();
        expect(rxTodoItem.value.leftOrNull, null);

        await rxSet.dispose();

        expect(rxTodoItem.disposed, true);
      });
    });

    group('mapItem', () {
      test('Should map data change', () async {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulSet<String, String> rxNew = rxSet.mapItem((final int item) => item.toString());

        rxNew.listen();
        expect(rxNew.value.leftOrThrow.setView, <String>['1', '2', '3', '4', '5']);

        rxSet.add(6);
        expect(rxNew.value.leftOrThrow.setView, <String>['1', '2', '3', '4', '5', '6']);

        rxSet.add(7);
        expect(rxNew.value.leftOrThrow.setView, <String>['1', '2', '3', '4', '5', '6', '7']);

        rxSet.remove(3);
        expect(rxNew.value.leftOrThrow.setView, <String>['1', '2', '4', '5', '6', '7']);

        rxSet.setState('custom');
        expect(rxNew.value.leftOrNull, null);
        expect(rxNew.value.rightOrThrow, 'custom');

        rxSet.add(8);
        expect(rxNew.value.leftOrThrow.setView, <String>['8']);

        rxSet.add(9);
        expect(rxNew.value.leftOrThrow.setView, <String>['8', '9']);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.leftOrThrow.setView, <String>['8', '9', '10', '11', '12']);

        rxSet.remove(8);
        expect(rxNew.value.leftOrThrow.setView, <String>['9', '10', '11', '12']);

        rxSet.remove(9);
        expect(rxNew.value.leftOrThrow.setView, <String>['10', '11', '12']);

        rxSet.clear();
        expect(rxNew.value.leftOrThrow.setView, <String>[]);

        await rxSet.dispose();

        expect(rxNew.disposed, true);
      });
    });
  });
}

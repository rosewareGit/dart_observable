import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

import '../../../../../todo_item.dart';

void main() {
  group('ObservableSetFailure', () {
    group('length', () {
      test('should return the length', () {
        final RxSetFailure<int, String> set = RxSetFailure<int, String>(initial: <int>[1, 2, 3]);
        expect(set.length.data, 3);

        set.add(4);
        expect(set.length.data, 4);

        set.failure = 'failure';
        expect(set.length.data, null);
        expect(set.length.custom, 'failure');
      });
    });

    group('lengthOrNull', () {
      test('should return the length', () {
        final RxSetFailure<int, String> set = RxSetFailure<int, String>(initial: <int>[1, 2, 3]);
        expect(set.lengthOrNull, 3);

        set.add(4);
        expect(set.lengthOrNull, 4);

        set.failure = 'failure';
        expect(set.lengthOrNull, null);
      });
    });

    group('changeFactory', () {
      test('should change the factory', () async {
        final RxSetFailure<int, String> rxSet = RxSetFailure<int, String>(initial: <int>[1, 2, 3]);
        final ObservableSetFailure<int, String> rxNew = rxSet.changeFactory((final Iterable<int>? items) {
          return Set<int>.of(items ?? <int>[]);
        });

        rxNew.listen();

        expect(rxNew.value.data!.setView, <int>[1, 2, 3]);

        rxSet.add(4);

        expect(rxNew.value.data!.setView, <int>[1, 2, 3, 4]);

        rxSet.failure = 'failure';

        expect(rxNew.value.data, null);

        rxSet.add(5);

        expect(rxNew.value.data!.setView, <int>[5]);

        await rxSet.dispose();

        expect(rxNew.disposed, true);
      });
    });

    group('filterItem', () {
      test('should filter the items', () async {
        final RxSetFailure<int, String> rxSet = RxSetFailure<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableSetFailure<int, String> rxNew = rxSet.filterItem((final int item) => item.isOdd);

        rxNew.listen();
        expect(rxNew.value.data!.setView, <int>[1, 3, 5]);

        rxSet.add(6);
        expect(rxNew.value.data!.setView, <int>[1, 3, 5]);

        rxSet.add(7);
        expect(rxNew.value.data!.setView, <int>[1, 3, 5, 7]);

        rxSet.remove(3);
        expect(rxNew.value.data!.setView, <int>[1, 5, 7]);

        rxSet.failure = 'failure';
        expect(rxNew.value.data, null);

        rxSet.add(8);
        expect(rxNew.value.data!.setView, <int>[]);

        rxSet.add(9);
        expect(rxNew.value.data!.setView, <int>[9]);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.data!.setView, <int>[9, 11]);

        rxSet.clear();
        expect(rxNew.value.data!.setView, <int>[]);

        await rxSet.dispose();

        expect(rxNew.disposed, true);
      });
    });

    group('rxItem', () {
      test('should return the item by the predicate', () async {
        final TodoItem todoItem1 = TodoItem(id: '1', title: 'title 1', description: 'description 1');
        final TodoItem todoItem2 = TodoItem(id: '2', title: 'title 2', description: 'description 2');
        final TodoItem todoItem2Copy = TodoItem(id: '2', title: 'title 2 copy', description: 'description 2 copy');
        final RxSetFailure<TodoItem, String> rxSet = RxSetFailure<TodoItem, String>(
          initial: <TodoItem>[
            todoItem1,
            todoItem2,
          ],
        );

        final Observable<StateOf<TodoItem?, String>> rxTodoItem = rxSet.rxItem((final TodoItem item) => item.id == '2');

        rxTodoItem.listen();
        expect(rxTodoItem.value.data, todoItem2);

        rxSet.add(TodoItem(id: '3', title: 'title 3', description: 'description 3'));

        expect(rxTodoItem.value.data, todoItem2);

        rxSet.remove(todoItem2);
        expect(rxTodoItem.value.data, null);

        rxSet.add(todoItem2);
        expect(rxTodoItem.value.data, todoItem2);

        rxSet.applySetUpdateAction(
          ObservableSetUpdateAction<TodoItem>(
            addItems: <TodoItem>{todoItem2Copy},
            removeItems: <TodoItem>{todoItem2},
          ),
        );

        expect(rxTodoItem.value.data, todoItem2Copy);

        rxSet.failure = 'failure';
        expect(rxTodoItem.value.data, null);
        expect(rxTodoItem.value.custom, 'failure');

        rxSet.clear();
        expect(rxTodoItem.value.data, null);

        await rxSet.dispose();

        expect(rxTodoItem.disposed, true);
      });
    });

    group('mapItem', () {
      test('Should map data change', () async {
        final RxSetFailure<int, String> rxSet = RxSetFailure<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableSetFailure<String, String> rxNew = rxSet.mapItem((final int item) => item.toString());

        rxNew.listen();
        expect(rxNew.value.data!.setView, <String>['1', '2', '3', '4', '5']);

        rxSet.add(6);
        expect(rxNew.value.data!.setView, <String>['1', '2', '3', '4', '5', '6']);

        rxSet.add(7);
        expect(rxNew.value.data!.setView, <String>['1', '2', '3', '4', '5', '6', '7']);

        rxSet.remove(3);
        expect(rxNew.value.data!.setView, <String>['1', '2', '4', '5', '6', '7']);

        rxSet.failure = 'failure';
        expect(rxNew.value.data, null);
        expect(rxNew.value.custom, 'failure');

        rxSet.add(8);
        expect(rxNew.value.data!.setView, <String>['8']);

        rxSet.add(9);
        expect(rxNew.value.data!.setView, <String>['8', '9']);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.data!.setView, <String>['8', '9', '10', '11', '12']);

        rxSet.remove(8);
        expect(rxNew.value.data!.setView, <String>['9', '10', '11', '12']);

        rxSet.remove(9);
        expect(rxNew.value.data!.setView, <String>['10', '11', '12']);

        rxSet.clear();
        expect(rxNew.value.data!.setView, <String>[]);

        await rxSet.dispose();

        expect(rxNew.disposed, true);
      });
    });
  });
}

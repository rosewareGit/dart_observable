import 'dart:async';
import 'dart:collection';

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

import '../../../../todo_item.dart';

void main() {
  group('ObservableStatefulSet', () {
    group('just', () {
      test('should create a new instance', () {
        final ObservableStatefulSet<int, String> set = ObservableStatefulSet<int, String>.just(<int>{1, 2, 3});
        expect(set.value.leftOrThrow.setView, <int>{1, 2, 3});
      });

      test('Should respect the factory', () {
        final ObservableStatefulSet<int, String> set = ObservableStatefulSet<int, String>.just(
          <int>{1, 2, 3},
          factory: (final Iterable<int>? items) {
            return SplayTreeSet<int>.of(items ?? <int>[], (final int a, final int b) => b.compareTo(a));
          },
        );
        expect(set.value.leftOrThrow.setView, <int>{3, 2, 1});
      });
    });

    group('custom', () {
      test('should create a new instance with custom state', () {
        final ObservableStatefulSet<int, String> set = ObservableStatefulSet<int, String>.custom('custom');
        expect(set.value.rightOrThrow, 'custom');
      });
    });

    group('merged', () {
      test('should merge two ObservableStatefulSet', () {
        final ObservableStatefulSet<int, String> set1 = ObservableStatefulSet<int, String>.just(<int>{1, 2});
        final ObservableStatefulSet<int, String> set2 = ObservableStatefulSet<int, String>.just(<int>{3, 4});

        final ObservableStatefulSet<int, String> rxMerged = ObservableStatefulSet<int, String>.merged(
          collections: <ObservableStatefulSet<int, String>>[set1, set2],
        );

        rxMerged.listen();
      });

      test('should handle empty sets', () {
        final ObservableStatefulSet<int, String> set1 = ObservableStatefulSet<int, String>.just(<int>{});
        final ObservableStatefulSet<int, String> set2 = ObservableStatefulSet<int, String>.just(<int>{});

        final ObservableStatefulSet<int, String> rxMerged = ObservableStatefulSet<int, String>.merged(
          collections: <ObservableStatefulSet<int, String>>[set1, set2],
        );

        rxMerged.listen();

        expect(rxMerged.length, 0);
      });

      test('should handle overlapping values', () {
        final RxStatefulSet<int, String> set1 = RxStatefulSet<int, String>(initial: <int>{1, 2});
        final RxStatefulSet<int, String> set2 = RxStatefulSet<int, String>(initial: <int>{2, 3});

        final ObservableStatefulSet<int, String> rxMerged = ObservableStatefulSet<int, String>.merged(
          collections: <ObservableStatefulSet<int, String>>[set1, set2],
        );

        rxMerged.listen();

        expect(rxMerged.value.leftOrThrow.setView, <int>{1, 2, 3});

        set2.remove(2);
        expect(rxMerged.value.leftOrThrow.setView, <int>{1, 2, 3});

        set1.remove(2);
        expect(rxMerged.value.leftOrThrow.setView, <int>{1, 3});
      });

      test('should handle one empty set and one non-empty set', () {
        final ObservableStatefulSet<int, String> set1 = ObservableStatefulSet<int, String>.just(<int>{});
        final ObservableStatefulSet<int, String> set2 = ObservableStatefulSet<int, String>.just(<int>{1});

        final ObservableStatefulSet<int, String> rxMerged = ObservableStatefulSet<int, String>.merged(
          collections: <ObservableStatefulSet<int, String>>[set1, set2],
        );

        rxMerged.listen();

        expect(rxMerged.length, 1);
        expect(rxMerged.value.leftOrThrow.setView, <int>{1});
      });

      test('Should handle custom state with state resolver', () {
        final RxStatefulSet<int, String> set1 = RxStatefulSet<int, String>(
          initial: <int>{1, 2},
        );
        final RxStatefulSet<int, String> set2 = RxStatefulSet<int, String>(
          initial: <int>{1, 3},
        );

        final ObservableStatefulSet<int, String> rxMerged = ObservableStatefulSet<int, String>.merged(
          collections: <ObservableStatefulSet<int, String>>[set1, set2],
          stateResolver: (final String state) {
            expect(state, 'custom');
            return Either<Set<int>, String>.right('customState');
          },
        );

        rxMerged.listen();

        set1.setState('custom');

        expect(rxMerged.value.rightOrNull, 'customState');
      });

      test('Should remove items when a source transitions to custom without a state resolver', () {
        final RxStatefulSet<int, String> set1 = RxStatefulSet<int, String>(
          initial: <int>{1, 2},
        );
        final RxStatefulSet<int, String> set2 = RxStatefulSet<int, String>(
          initial: <int>{1, 3},
        );

        final ObservableStatefulSet<int, String> rxMerged = ObservableStatefulSet<int, String>.merged(
          collections: <ObservableStatefulSet<int, String>>[set1, set2],
        );

        rxMerged.listen();

        set1.setState('custom');

        expect(rxMerged.value.leftOrNull!.setView, <int>{1, 3});
        expect(rxMerged.value.rightOrNull, null);
      });
    });

    group('fromStream', () {
      test('should create an ObservableStatefulSet from a stream', () {
        final StreamController<Either<ObservableSetUpdateAction<int>, String>> controller =
            StreamController<Either<ObservableSetUpdateAction<int>, String>>(sync: true);

        final ObservableStatefulSet<int, String> rxSet =
            ObservableStatefulSet<int, String>.fromStream(stream: controller.stream);

        rxSet.listen();

        controller.add(
          Either<ObservableSetUpdateAction<int>, String>.left(
            ObservableSetUpdateAction<int>(addItems: <int>{1}),
          ),
        );

        expect(rxSet.value.leftOrThrow.setView, <int>{1});

        controller.add(
          Either<ObservableSetUpdateAction<int>, String>.left(
            ObservableSetUpdateAction<int>(addItems: <int>{2}),
          ),
        );
        expect(rxSet.value.leftOrThrow.setView, <int>{1, 2});

        controller.add(
          Either<ObservableSetUpdateAction<int>, String>.left(
            ObservableSetUpdateAction<int>(removeItems: <int>{1}),
          ),
        );
        expect(rxSet.value.leftOrThrow.setView, <int>{2});

        controller.add(
          Either<ObservableSetUpdateAction<int>, String>.right('custom'),
        );
        expect(rxSet.value.leftOrNull, null);
        expect(rxSet.value.rightOrNull, 'custom');
      });

      test('should handle stream errors', () async {
        final StreamController<Either<ObservableSetUpdateAction<int>, String>> controller =
            StreamController<Either<ObservableSetUpdateAction<int>, String>>(sync: true);

        final ObservableStatefulSet<int, String> rxSet = ObservableStatefulSet<int, String>.fromStream(
          stream: controller.stream,
          onError: (final dynamic error) {
            return Either<Set<int>, String>.right('error');
          },
        );

        rxSet.listen();

        controller.addError(Exception('Stream error'));

        expect(rxSet.value.rightOrNull, 'error');
      });

      test('should handle stream completion', () async {
        final StreamController<Either<ObservableSetUpdateAction<int>, String>> controller =
            StreamController<Either<ObservableSetUpdateAction<int>, String>>(sync: true);

        final ObservableStatefulSet<int, String> rxSet =
            ObservableStatefulSet<int, String>.fromStream(stream: controller.stream);

        rxSet.listen();

        await controller.close();

        expect(rxSet.disposed, true);
      });

      test('Should update the set with all the pending changes after listening', () async {
        final StreamController<Either<ObservableSetUpdateAction<int>, String>> controller =
            StreamController<Either<ObservableSetUpdateAction<int>, String>>(sync: true);

        final ObservableStatefulSet<int, String> rxSet =
            ObservableStatefulSet<int, String>.fromStream(stream: controller.stream);

        controller.add(
          Either<ObservableSetUpdateAction<int>, String>.left(
            ObservableSetUpdateAction<int>(addItems: <int>{1}),
          ),
        );

        controller.add(
          Either<ObservableSetUpdateAction<int>, String>.left(
            ObservableSetUpdateAction<int>(addItems: <int>{2}),
          ),
        );

        Disposable listener = rxSet.listen();

        expect(rxSet.value.leftOrThrow.setView, <int>{1, 2});

        listener.dispose();

        controller.add(
          Either<ObservableSetUpdateAction<int>, String>.left(
            ObservableSetUpdateAction<int>(addItems: <int>{3}),
          ),
        );

        listener = rxSet.listen();

        expect(rxSet.value.leftOrThrow.setView, <int>{1, 2, 3});
      });
    });

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

    group('sorted', () {
      test('should sort the items', () async {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>{1, 2, 3});
        final ObservableStatefulSet<int, String> rxSorted = rxSet.sorted((final int a, final int b) => b.compareTo(a));

        rxSorted.listen();
        expect(rxSorted.value.leftOrThrow.setView, <int>[3, 2, 1]);

        rxSet.add(4);
        expect(rxSorted.value.leftOrThrow.setView, <int>[4, 3, 2, 1]);

        rxSet.setState('custom');
        expect(rxSorted.value.leftOrNull, null);

        rxSet.add(5);
        expect(rxSorted.value.leftOrThrow.setView, <int>[5]);

        rxSet.addAll(<int>[6, 7, 8]);
        expect(rxSorted.value.leftOrThrow.setView, <int>[8, 7, 6, 5]);

        rxSet.removeAll(<int>[7, 8, 6]);
        expect(rxSorted.value.leftOrThrow.setView, <int>[5]);

        await rxSet.dispose();
        expect(rxSorted.disposed, true);
      });
    });

    group('changeFactory', () {
      test('should change the factory', () async {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>{1, 2, 3});
        final ObservableStatefulSet<int, String> rxSorted = rxSet.changeFactory((final Iterable<int>? items) {
          return SplayTreeSet<int>.of(items ?? <int>[], (final int a, final int b) => b.compareTo(a));
        });

        rxSorted.listen();
        expect(rxSorted.value.leftOrThrow.setView, <int>[3, 2, 1]);

        rxSet.add(4);
        expect(rxSorted.value.leftOrThrow.setView, <int>[4, 3, 2, 1]);

        rxSet.setState('custom');
        expect(rxSorted.value.leftOrNull, null);

        rxSet.add(5);
        expect(rxSorted.value.leftOrThrow.setView, <int>[5]);

        rxSet.addAll(<int>[6, 7, 8]);
        expect(rxSorted.value.leftOrThrow.setView, <int>[8, 7, 6, 5]);

        rxSet.removeAll(<int>[7, 8, 6]);
        expect(rxSorted.value.leftOrThrow.setView, <int>[5]);

        await rxSet.dispose();
        expect(rxSorted.disposed, true);
      });
    });

    group('filterItem', () {
      test('should filter the items', () async {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulSet<int, String> rxFiltered = rxSet.filterItem((final int item) => item.isOdd);

        rxFiltered.listen();
        expect(rxFiltered.value.leftOrThrow.setView, <int>{1, 3, 5});

        rxSet.add(6);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{1, 3, 5});

        rxSet.add(7);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{1, 3, 5, 7});

        rxSet.remove(3);
        expect(rxFiltered.value.leftOrThrow.setView, <int>[1, 5, 7]);

        rxSet.setState('custom');
        expect(rxFiltered.value.leftOrNull, null);

        rxSet.add(8);
        expect(rxFiltered.value.leftOrThrow.setView, <int>[]);

        rxSet.add(9);
        expect(rxFiltered.value.leftOrThrow.setView, <int>[9]);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxFiltered.value.leftOrThrow.setView, <int>[9, 11]);

        rxSet.clear();
        expect(rxFiltered.value.leftOrThrow.setView, <int>[]);

        await rxSet.dispose();

        expect(rxFiltered.disposed, true);
      });

      test('Should respect factory when set', () async {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulSet<int, String> rxFiltered = rxSet.filterItem(
          (final int item) => item.isOdd,
          factory: (final Iterable<int>? items) {
            return SplayTreeSet<int>.of(items ?? <int>[], (final int a, final int b) => b.compareTo(a));
          },
        );

        rxFiltered.listen();
        expect(rxFiltered.value.leftOrThrow.setView, <int>{5, 3, 1});

        rxSet.add(6);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{5, 3, 1});

        rxSet.add(7);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{7, 5, 3, 1});

        rxSet.remove(3);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{7, 5, 1});

        rxSet.setState('custom');
        expect(rxFiltered.value.leftOrNull, null);
        expect(rxFiltered.value.rightOrThrow, 'custom');

        rxSet.add(8);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{});

        rxSet.add(9);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{9});

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{11, 9});

        rxSet.clear();
        expect(rxFiltered.value.leftOrThrow.setView, <int>[]);

        await rxSet.dispose();
        expect(rxFiltered.disposed, true);
      });
    });

    group('filterItemWithState', () {
      test('should filter the items with state change', () async {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulSet<int, String> rxFiltered =
            rxSet.filterItemWithState((final Either<int, String> item) {
          return item.fold(
            onLeft: (final int value) => value.isOdd,
            onRight: (final String state) => state == 'custom',
          );
        });

        rxFiltered.listen();
        expect(rxFiltered.value.leftOrThrow.setView, <int>{1, 3, 5});

        rxSet.add(6);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{1, 3, 5});

        rxSet.add(7);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{1, 3, 5, 7});

        rxSet.remove(3);
        expect(rxFiltered.value.leftOrThrow.setView, <int>[1, 5, 7]);

        rxSet.setState('test');
        expect(rxFiltered.value.leftOrThrow.setView, <int>[1, 5, 7]);

        rxSet.setState('custom');
        expect(rxFiltered.value.leftOrNull, null);
        expect(rxFiltered.value.rightOrThrow, 'custom');

        rxSet.setState('test');
        expect(rxFiltered.value.leftOrNull, null);
        expect(rxFiltered.value.rightOrThrow, 'custom');

        rxSet.add(8);
        expect(rxFiltered.value.leftOrThrow.setView, <int>[]);

        rxSet.add(9);
        expect(rxFiltered.value.leftOrThrow.setView, <int>[9]);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxFiltered.value.leftOrThrow.setView, <int>[9, 11]);

        rxSet.clear();
        expect(rxFiltered.value.leftOrThrow.setView, <int>[]);

        await rxSet.dispose();
        expect(rxFiltered.disposed, true);
      });

      test('Should respect factory when set', () async {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulSet<int, String> rxFiltered = rxSet.filterItemWithState(
          (final Either<int, String> item) {
            return item.fold(
              onLeft: (final int value) => value.isOdd,
              onRight: (final String state) => state == 'custom',
            );
          },
          factory: (final Iterable<int>? items) {
            return SplayTreeSet<int>.of(items ?? <int>[], (final int a, final int b) => b.compareTo(a));
          },
        );

        rxFiltered.listen();
        expect(rxFiltered.value.leftOrThrow.setView, <int>{5, 3, 1});

        rxSet.add(6);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{5, 3, 1});

        rxSet.add(7);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{7, 5, 3, 1});

        rxSet.remove(3);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{7, 5, 1});

        rxSet.setState('test');
        expect(rxFiltered.value.leftOrThrow.setView, <int>{7, 5, 1});

        rxSet.setState('custom');
        expect(rxFiltered.value.leftOrNull, null);
        expect(rxFiltered.value.rightOrThrow, 'custom');

        rxSet.setState('test');
        expect(rxFiltered.value.leftOrNull, null);
        expect(rxFiltered.value.rightOrThrow, 'custom');

        rxSet.add(8);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{});

        rxSet.add(9);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{9});

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxFiltered.value.leftOrThrow.setView, <int>{11, 9});

        rxSet.clear();
        expect(rxFiltered.value.leftOrThrow.setView, <int>[]);

        await rxSet.dispose();
        expect(rxFiltered.disposed, true);
      });
    });

    group('rxItem', () {
      test('should return the item by the predicate', () async {
        final TodoItem todoItem1 = TodoItem(id: '1', title: 'title 1', description: 'description 1');
        final TodoItem todoItem2 = TodoItem(id: '2', title: 'title 2', description: 'description 2');
        final TodoItem todoItem2Copy = TodoItem(id: '2', title: 'title 2 copy', description: 'description 2 copy');

        final RxStatefulSet<TodoItem, String> rxSet = RxStatefulSet<TodoItem, String>(
          initial: <TodoItem>[todoItem1, todoItem2],
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

      test('Should respect factory when set', () async {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulSet<String, String> rxNew = rxSet.mapItem(
          (final int item) => item.toString(),
          factory: (final Iterable<String>? items) {
            return SplayTreeSet<String>.of(items ?? <String>[], (final String a, final String b) => b.compareTo(a));
          },
        );

        rxNew.listen();
        expect(rxNew.value.leftOrThrow.setView, <String>['5', '4', '3', '2', '1']);

        rxSet.add(6);
        expect(rxNew.value.leftOrThrow.setView, <String>['6', '5', '4', '3', '2', '1']);

        rxSet.add(7);
        expect(rxNew.value.leftOrThrow.setView, <String>['7', '6', '5', '4', '3', '2', '1']);

        rxSet.remove(3);
        expect(rxNew.value.leftOrThrow.setView, <String>['7', '6', '5', '4', '2', '1']);

        rxSet.setState('custom');
        expect(rxNew.value.leftOrNull, null);
        expect(rxNew.value.rightOrThrow, 'custom');

        rxSet.add(8);
        expect(rxNew.value.leftOrThrow.setView, <String>['8']);

        rxSet.add(9);
        expect(rxNew.value.leftOrThrow.setView, <String>['9', '8']);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.leftOrThrow.setView, <String>['9', '8', '12', '11', '10']);

        rxSet.remove(8);
        expect(rxNew.value.leftOrThrow.setView, <String>['9', '12', '11', '10']);

        await rxSet.dispose();
        expect(rxNew.disposed, true);
      });
    });

    group('mapItemWithState', () {
      test('Should map data change with state change', () async {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulSet<String, String> rxNew = rxSet.mapItemWithState(
          mapper: (final int item) => item.toString(),
          stateMapper: (final String state) => state.toUpperCase(),
        );

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
        expect(rxNew.value.rightOrThrow, 'CUSTOM');

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

      test('Should respect factory when set', () async {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulSet<String, String> rxNew = rxSet.mapItemWithState(
          mapper: (final int item) => item.toString(),
          stateMapper: (final String state) => state.toUpperCase(),
          factory: (final Iterable<String>? items) {
            return SplayTreeSet<String>.of(items ?? <String>[], (final String a, final String b) => b.compareTo(a));
          },
        );

        rxNew.listen();
        expect(rxNew.value.leftOrThrow.setView, <String>['5', '4', '3', '2', '1']);

        rxSet.add(6);
        expect(rxNew.value.leftOrThrow.setView, <String>['6', '5', '4', '3', '2', '1']);

        rxSet.add(7);
        expect(rxNew.value.leftOrThrow.setView, <String>['7', '6', '5', '4', '3', '2', '1']);

        rxSet.remove(3);
        expect(rxNew.value.leftOrThrow.setView, <String>['7', '6', '5', '4', '2', '1']);

        rxSet.setState('custom');
        expect(rxNew.value.leftOrNull, null);
        expect(rxNew.value.rightOrThrow, 'CUSTOM');

        rxSet.add(8);
        expect(rxNew.value.leftOrThrow.setView, <String>['8']);

        rxSet.add(9);
        expect(rxNew.value.leftOrThrow.setView, <String>['9', '8']);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.leftOrThrow.setView, <String>['9', '8', '12', '11', '10']);

        rxSet.remove(8);
        expect(rxNew.value.leftOrThrow.setView, <String>['9', '12', '11', '10']);

        await rxSet.dispose();
        expect(rxNew.disposed, true);
      });
    });
  });
}

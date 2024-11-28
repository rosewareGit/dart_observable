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
        expect(set.value.leftOrThrow, <int>{1, 2, 3});
      });

      test('Should respect the factory', () {
        final ObservableStatefulSet<int, String> set = ObservableStatefulSet<int, String>.just(
          <int>{1, 2, 3},
          factory: (final Iterable<int>? items) {
            return SplayTreeSet<int>.of(items ?? <int>[], (final int a, final int b) => b.compareTo(a));
          },
        );
        expect(set.value.leftOrThrow, <int>{3, 2, 1});
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

        expect(rxMerged.value.leftOrThrow, <int>{1, 2, 3});

        set2.remove(2);
        expect(rxMerged.value.leftOrThrow, <int>{1, 2, 3});

        set1.remove(2);
        expect(rxMerged.value.leftOrThrow, <int>{1, 3});
      });

      test('should handle one empty set and one non-empty set', () {
        final ObservableStatefulSet<int, String> set1 = ObservableStatefulSet<int, String>.just(<int>{});
        final ObservableStatefulSet<int, String> set2 = ObservableStatefulSet<int, String>.just(<int>{1});

        final ObservableStatefulSet<int, String> rxMerged = ObservableStatefulSet<int, String>.merged(
          collections: <ObservableStatefulSet<int, String>>[set1, set2],
        );

        rxMerged.listen();

        expect(rxMerged.length, 1);
        expect(rxMerged.value.leftOrThrow, <int>{1});
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

        expect(rxMerged.value.leftOrNull!, <int>{1, 3});
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

        expect(rxSet.value.leftOrThrow, <int>{1});

        controller.add(
          Either<ObservableSetUpdateAction<int>, String>.left(
            ObservableSetUpdateAction<int>(addItems: <int>{2}),
          ),
        );
        expect(rxSet.value.leftOrThrow, <int>{1, 2});

        controller.add(
          Either<ObservableSetUpdateAction<int>, String>.left(
            ObservableSetUpdateAction<int>(removeItems: <int>{1}),
          ),
        );
        expect(rxSet.value.leftOrThrow, <int>{2});

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

        expect(rxSet.value.leftOrThrow, <int>{1, 2});

        listener.dispose();

        controller.add(
          Either<ObservableSetUpdateAction<int>, String>.left(
            ObservableSetUpdateAction<int>(addItems: <int>{3}),
          ),
        );

        listener = rxSet.listen();

        expect(rxSet.value.leftOrThrow, <int>{1, 2, 3});
      });
    });

    group('value', () {
      test('Should return an unmodifiable view of the set', () {
        final ObservableStatefulSet<int, String> set = ObservableStatefulSet<int, String>.just(<int>{1, 2, 3});
        final UnmodifiableSetView<int> value = set.value.leftOrThrow;

        expect(() => value.add(4), throwsUnsupportedError);
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
        expect(rxSorted.value.leftOrThrow, <int>[3, 2, 1]);

        rxSet.add(4);
        expect(rxSorted.value.leftOrThrow, <int>[4, 3, 2, 1]);

        rxSet.setState('custom');
        expect(rxSorted.value.leftOrNull, null);

        rxSet.add(5);
        expect(rxSorted.value.leftOrThrow, <int>[5]);

        rxSet.addAll(<int>[6, 7, 8]);
        expect(rxSorted.value.leftOrThrow, <int>[8, 7, 6, 5]);

        rxSet.removeAll(<int>[7, 8, 6]);
        expect(rxSorted.value.leftOrThrow, <int>[5]);

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
        expect(rxSorted.value.leftOrThrow, <int>[3, 2, 1]);

        rxSet.add(4);
        expect(rxSorted.value.leftOrThrow, <int>[4, 3, 2, 1]);

        rxSet.setState('custom');
        expect(rxSorted.value.leftOrNull, null);

        rxSet.add(5);
        expect(rxSorted.value.leftOrThrow, <int>[5]);

        rxSet.addAll(<int>[6, 7, 8]);
        expect(rxSorted.value.leftOrThrow, <int>[8, 7, 6, 5]);

        rxSet.removeAll(<int>[7, 8, 6]);
        expect(rxSorted.value.leftOrThrow, <int>[5]);

        await rxSet.dispose();
        expect(rxSorted.disposed, true);
      });
    });

    group('filterItem', () {
      test('should filter the items', () async {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulSet<int, String> rxFiltered = rxSet.filterItem((final int item) => item.isOdd);

        rxFiltered.listen();
        expect(rxFiltered.value.leftOrThrow, <int>{1, 3, 5});

        rxSet.add(6);
        expect(rxFiltered.value.leftOrThrow, <int>{1, 3, 5});

        rxSet.add(7);
        expect(rxFiltered.value.leftOrThrow, <int>{1, 3, 5, 7});

        rxSet.remove(3);
        expect(rxFiltered.value.leftOrThrow, <int>[1, 5, 7]);

        rxSet.setState('custom');
        expect(rxFiltered.value.leftOrNull, null);

        rxSet.add(8);
        expect(rxFiltered.value.leftOrThrow, <int>[]);

        rxSet.add(9);
        expect(rxFiltered.value.leftOrThrow, <int>[9]);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxFiltered.value.leftOrThrow, <int>[9, 11]);

        rxSet.clear();
        expect(rxFiltered.value.leftOrThrow, <int>[]);

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
        expect(rxFiltered.value.leftOrThrow, <int>{5, 3, 1});

        rxSet.add(6);
        expect(rxFiltered.value.leftOrThrow, <int>{5, 3, 1});

        rxSet.add(7);
        expect(rxFiltered.value.leftOrThrow, <int>{7, 5, 3, 1});

        rxSet.remove(3);
        expect(rxFiltered.value.leftOrThrow, <int>{7, 5, 1});

        rxSet.setState('custom');
        expect(rxFiltered.value.leftOrNull, null);
        expect(rxFiltered.value.rightOrThrow, 'custom');

        rxSet.add(8);
        expect(rxFiltered.value.leftOrThrow, <int>{});

        rxSet.add(9);
        expect(rxFiltered.value.leftOrThrow, <int>{9});

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxFiltered.value.leftOrThrow, <int>{11, 9});

        rxSet.clear();
        expect(rxFiltered.value.leftOrThrow, <int>[]);

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
        expect(rxFiltered.value.leftOrThrow, <int>{1, 3, 5});

        rxSet.add(6);
        expect(rxFiltered.value.leftOrThrow, <int>{1, 3, 5});

        rxSet.add(7);
        expect(rxFiltered.value.leftOrThrow, <int>{1, 3, 5, 7});

        rxSet.remove(3);
        expect(rxFiltered.value.leftOrThrow, <int>[1, 5, 7]);

        rxSet.setState('test');
        expect(rxFiltered.value.leftOrThrow, <int>[1, 5, 7]);

        rxSet.setState('custom');
        expect(rxFiltered.value.leftOrNull, null);
        expect(rxFiltered.value.rightOrThrow, 'custom');

        rxSet.setState('test');
        expect(rxFiltered.value.leftOrNull, null);
        expect(rxFiltered.value.rightOrThrow, 'custom');

        rxSet.add(8);
        expect(rxFiltered.value.leftOrThrow, <int>[]);

        rxSet.add(9);
        expect(rxFiltered.value.leftOrThrow, <int>[9]);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxFiltered.value.leftOrThrow, <int>[9, 11]);

        rxSet.clear();
        expect(rxFiltered.value.leftOrThrow, <int>[]);

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
        expect(rxFiltered.value.leftOrThrow, <int>{5, 3, 1});

        rxSet.add(6);
        expect(rxFiltered.value.leftOrThrow, <int>{5, 3, 1});

        rxSet.add(7);
        expect(rxFiltered.value.leftOrThrow, <int>{7, 5, 3, 1});

        rxSet.remove(3);
        expect(rxFiltered.value.leftOrThrow, <int>{7, 5, 1});

        rxSet.setState('test');
        expect(rxFiltered.value.leftOrThrow, <int>{7, 5, 1});

        rxSet.setState('custom');
        expect(rxFiltered.value.leftOrNull, null);
        expect(rxFiltered.value.rightOrThrow, 'custom');

        rxSet.setState('test');
        expect(rxFiltered.value.leftOrNull, null);
        expect(rxFiltered.value.rightOrThrow, 'custom');

        rxSet.add(8);
        expect(rxFiltered.value.leftOrThrow, <int>{});

        rxSet.add(9);
        expect(rxFiltered.value.leftOrThrow, <int>{9});

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxFiltered.value.leftOrThrow, <int>{11, 9});

        rxSet.clear();
        expect(rxFiltered.value.leftOrThrow, <int>[]);

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

        rxSet.remove(todoItem2);
        rxSet.add(todoItem2Copy);

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
        expect(rxNew.value.leftOrThrow, <String>['1', '2', '3', '4', '5']);

        rxSet.add(6);
        expect(rxNew.value.leftOrThrow, <String>['1', '2', '3', '4', '5', '6']);

        rxSet.add(7);
        expect(rxNew.value.leftOrThrow, <String>['1', '2', '3', '4', '5', '6', '7']);

        rxSet.remove(3);
        expect(rxNew.value.leftOrThrow, <String>['1', '2', '4', '5', '6', '7']);

        rxSet.setState('custom');
        expect(rxNew.value.leftOrNull, null);
        expect(rxNew.value.rightOrThrow, 'custom');

        rxSet.add(8);
        expect(rxNew.value.leftOrThrow, <String>['8']);

        rxSet.add(9);
        expect(rxNew.value.leftOrThrow, <String>['8', '9']);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.leftOrThrow, <String>['8', '9', '10', '11', '12']);

        rxSet.remove(8);
        expect(rxNew.value.leftOrThrow, <String>['9', '10', '11', '12']);

        rxSet.remove(9);
        expect(rxNew.value.leftOrThrow, <String>['10', '11', '12']);

        rxSet.clear();
        expect(rxNew.value.leftOrThrow, <String>[]);

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
        expect(rxNew.value.leftOrThrow, <String>['5', '4', '3', '2', '1']);

        rxSet.add(6);
        expect(rxNew.value.leftOrThrow, <String>['6', '5', '4', '3', '2', '1']);

        rxSet.add(7);
        expect(rxNew.value.leftOrThrow, <String>['7', '6', '5', '4', '3', '2', '1']);

        rxSet.remove(3);
        expect(rxNew.value.leftOrThrow, <String>['7', '6', '5', '4', '2', '1']);

        rxSet.setState('custom');
        expect(rxNew.value.leftOrNull, null);
        expect(rxNew.value.rightOrThrow, 'custom');

        rxSet.add(8);
        expect(rxNew.value.leftOrThrow, <String>['8']);

        rxSet.add(9);
        expect(rxNew.value.leftOrThrow, <String>['9', '8']);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.leftOrThrow, <String>['9', '8', '12', '11', '10']);

        rxSet.remove(8);
        expect(rxNew.value.leftOrThrow, <String>['9', '12', '11', '10']);

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
        expect(rxNew.value.leftOrThrow, <String>['1', '2', '3', '4', '5']);

        rxSet.add(6);
        expect(rxNew.value.leftOrThrow, <String>['1', '2', '3', '4', '5', '6']);

        rxSet.add(7);
        expect(rxNew.value.leftOrThrow, <String>['1', '2', '3', '4', '5', '6', '7']);

        rxSet.remove(3);
        expect(rxNew.value.leftOrThrow, <String>['1', '2', '4', '5', '6', '7']);

        rxSet.setState('custom');
        expect(rxNew.value.leftOrNull, null);
        expect(rxNew.value.rightOrThrow, 'CUSTOM');

        rxSet.add(8);
        expect(rxNew.value.leftOrThrow, <String>['8']);

        rxSet.add(9);
        expect(rxNew.value.leftOrThrow, <String>['8', '9']);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.leftOrThrow, <String>['8', '9', '10', '11', '12']);

        rxSet.remove(8);
        expect(rxNew.value.leftOrThrow, <String>['9', '10', '11', '12']);

        rxSet.remove(9);
        expect(rxNew.value.leftOrThrow, <String>['10', '11', '12']);

        rxSet.clear();
        expect(rxNew.value.leftOrThrow, <String>[]);

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
        expect(rxNew.value.leftOrThrow, <String>['5', '4', '3', '2', '1']);

        rxSet.add(6);
        expect(rxNew.value.leftOrThrow, <String>['6', '5', '4', '3', '2', '1']);

        rxSet.add(7);
        expect(rxNew.value.leftOrThrow, <String>['7', '6', '5', '4', '3', '2', '1']);

        rxSet.remove(3);
        expect(rxNew.value.leftOrThrow, <String>['7', '6', '5', '4', '2', '1']);

        rxSet.setState('custom');
        expect(rxNew.value.leftOrNull, null);
        expect(rxNew.value.rightOrThrow, 'CUSTOM');

        rxSet.add(8);
        expect(rxNew.value.leftOrThrow, <String>['8']);

        rxSet.add(9);
        expect(rxNew.value.leftOrThrow, <String>['9', '8']);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.leftOrThrow, <String>['9', '8', '12', '11', '10']);

        rxSet.remove(8);
        expect(rxNew.value.leftOrThrow, <String>['9', '12', '11', '10']);

        await rxSet.dispose();
        expect(rxNew.disposed, true);
      });
    });

    group('transformAs', () {
      group('list', () {
        test('Should transform the set to a list', () async {
          final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
          rxSet.add(6);

          final ObservableList<int> rxList = rxSet.transformAs.list(
            transform: (
              final ObservableList<int> state,
              final Either<Set<int>, String> value,
              final Emitter<List<int>> updater,
            ) {
              // convert to i*2, or -1 if it's a custom state
              updater(
                value.fold(
                  onLeft: (final Set<int> items) => items.map<int>((final int item) => item * 2).toList(),
                  onRight: (final _) => <int>[-1],
                ),
              );
            },
          );

          rxList.listen();

          expect(rxList.value, <int>[2, 4, 6, 8, 10, 12]);

          rxSet.setState('custom');
          expect(rxList.value, <int>[-1]);

          rxSet.addAll(<int>[4, 6, 7]);
          expect(rxList.value, <int>[8, 12, 14]);

          rxSet.remove(4);
          expect(rxList.value, <int>[12, 14]);

          await rxSet.dispose();
          expect(rxList.disposed, true);
        });
      });

      group('statefulList', () {
        test('Should transform the set to a stateful list', () async {
          final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
          rxSet.add(6);

          final ObservableStatefulList<int, String> rxList = rxSet.transformAs.statefulList(
            transform: (
              final ObservableStatefulList<int, String> state,
              final Either<Set<int>, String> value,
              final Emitter<Either<List<int>, String>> updater,
            ) {
              // convert to i*2, or to custom state
              updater(
                value.fold(
                  onLeft: (final Set<int> items) => Either<List<int>, String>.left(
                    items.map<int>((final int item) => item * 2).toList(),
                  ),
                  onRight: (final String state) => Either<List<int>, String>.right(state),
                ),
              );
            },
          );

          rxList.listen();

          expect(rxList.value.leftOrThrow, <int>[2, 4, 6, 8, 10, 12]);

          rxSet.setState('custom');
          expect(rxList.value.leftOrNull, null);
          expect(rxList.value.rightOrThrow, 'custom');

          rxSet.addAll(<int>[4, 6, 7]);
          expect(rxList.value.leftOrThrow, <int>[8, 12, 14]);

          rxSet.remove(4);
          expect(rxList.value.leftOrThrow, <int>[12, 14]);

          await rxSet.dispose();
          expect(rxList.disposed, true);
        });
      });

      group('map', () {
        test('Should transform the set to a map', () async {
          final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
          rxSet.add(6);

          final ObservableMap<int, String> rxMap = rxSet.transformAs.map(
            transform: (
              final ObservableMap<int, String> state,
              final Either<Set<int>, String> value,
              final Emitter<Map<int, String>> updater,
            ) {
              // convert to i*2, or -1:custom state
              updater(
                value.fold(
                  onLeft: (final Set<int> items) => items.fold<Map<int, String>>(
                    <int, String>{},
                    (final Map<int, String> acc, final int item) => acc..[item] = (item * 2).toString(),
                  ),
                  onRight: (final String state) => <int, String>{-1: state},
                ),
              );
            },
          );

          rxMap.listen();

          expect(rxMap.value, <int, String>{1: '2', 2: '4', 3: '6', 4: '8', 5: '10', 6: '12'});

          rxSet.setState('custom');
          expect(rxMap.value, <int, String>{-1: 'custom'});

          rxSet.addAll(<int>[4, 6, 7]);
          expect(rxMap.value, <int, String>{4: '8', 6: '12', 7: '14'});

          rxSet.remove(4);
          expect(rxMap.value, <int, String>{6: '12', 7: '14'});

          await rxSet.dispose();
          expect(rxMap.disposed, true);
        });
      });

      group('statefulMap', () {
        test('Should transform the set to a stateful map', () async {
          final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
          rxSet.add(6);

          final ObservableStatefulMap<int, String, String> rxMap = rxSet.transformAs.statefulMap(
            transform: (
              final ObservableStatefulMap<int, String, String> state,
              final Either<Set<int>, String> value,
              final Emitter<Either<Map<int, String>, String>> updater,
            ) {
              // convert to i*2, or to custom state
              updater(
                value.fold(
                  onLeft: (final Set<int> items) => Either<Map<int, String>, String>.left(
                    items.fold<Map<int, String>>(
                      <int, String>{},
                      (final Map<int, String> acc, final int item) => acc..[item] = (item * 2).toString(),
                    ),
                  ),
                  onRight: (final String state) => Either<Map<int, String>, String>.right(state),
                ),
              );
            },
          );

          rxMap.listen();

          expect(rxMap.value.leftOrThrow, <int, String>{1: '2', 2: '4', 3: '6', 4: '8', 5: '10', 6: '12'});

          rxSet.setState('custom');
          expect(rxMap.value.leftOrNull, null);
          expect(rxMap.value.rightOrThrow, 'custom');

          rxSet.addAll(<int>[4, 6, 7]);
          expect(rxMap.value.leftOrThrow, <int, String>{4: '8', 6: '12', 7: '14'});

          rxSet.remove(4);
          expect(rxMap.value.leftOrThrow, <int, String>{6: '12', 7: '14'});

          await rxSet.dispose();
          expect(rxMap.disposed, true);
        });
      });

      group('set', () {
        test('Should transform the set to a set', () async {
          final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
          rxSet.add(6);

          final ObservableSet<String> rxSetTransformed = rxSet.transformAs.set(
            transform: (
              final ObservableSet<String> state,
              final Either<Set<int>, String> value,
              final Emitter<Set<String>> updater,
            ) {
              // convert to 'Ei*2', or to -1 if custom
              updater(
                value.fold(
                  onLeft: (final Set<int> items) => items.map<String>((final int item) => 'E${item * 2}').toSet(),
                  onRight: (final String state) => <String>{'-1'},
                ),
              );
            },
          );

          rxSetTransformed.listen();

          expect(rxSetTransformed.value, <String>{'E2', 'E4', 'E6', 'E8', 'E10', 'E12'});

          rxSet.setState('custom');
          expect(rxSetTransformed.value, <String>{'-1'});

          rxSet.addAll(<int>[4, 6, 7]);
          expect(rxSetTransformed.value, <String>{'E8', 'E12', 'E14'});

          rxSet.remove(4);
          expect(rxSetTransformed.value, <String>{'E12', 'E14'});

          await rxSet.dispose();
          expect(rxSetTransformed.disposed, true);
        });
      });

      group('statefulSet', () {
        test('Should transform the set to a stateful set', () async {
          final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
          rxSet.add(6);

          final ObservableStatefulSet<String, String> rxSetTransformed = rxSet.transformAs.statefulSet(
            transform: (
              final ObservableStatefulSet<String, String> state,
              final Either<Set<int>, String> value,
              final Emitter<Either<Set<String>, String>> updater,
            ) {
              // convert to 'Ei*2', or to custom state
              updater(
                value.fold(
                  onLeft: (final Set<int> items) => Either<Set<String>, String>.left(
                    items.map<String>((final int item) => 'E${item * 2}').toSet(),
                  ),
                  onRight: (final String state) => Either<Set<String>, String>.right(state),
                ),
              );
            },
          );

          rxSetTransformed.listen();

          expect(rxSetTransformed.value.leftOrThrow, <String>{'E2', 'E4', 'E6', 'E8', 'E10', 'E12'});

          rxSet.setState('custom');
          expect(rxSetTransformed.value.leftOrNull, null);
          expect(rxSetTransformed.value.rightOrThrow, 'custom');

          rxSet.addAll(<int>[4, 6, 7]);
          expect(rxSetTransformed.value.leftOrThrow, <String>{'E8', 'E12', 'E14'});

          rxSet.remove(4);
          expect(rxSetTransformed.value.leftOrThrow, <String>{'E12', 'E14'});

          await rxSet.dispose();
          expect(rxSetTransformed.disposed, true);
        });
      });
    });

    group('transformChangeAs', () {
      group('list', () {
        test('Should transform the set to a list', () async {
          final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
          rxSet.add(6);

          final ObservableList<String> rxList = rxSet.transformChangeAs.list(
            transform: (
              final ObservableList<String> current,
              final Either<Set<int>, String> state,
              final Either<ObservableSetChange<int>, String> change,
              final Emitter<ObservableListUpdateAction<String>> updater,
            ) {
              // convert to 'Ei*2', or to empty if custom

              String mapItem(final int item) => 'E${item * 2}';

              final ObservableListUpdateAction<String> action = change.fold(
                onLeft: (final ObservableSetChange<int> change) {
                  final Set<int> added = change.added;
                  final Set<int> removed = change.removed;

                  final Set<int> indexesToRemove = <int>{};
                  for (final int item in removed) {
                    final int index = current.value.indexOf(mapItem(item));
                    if (index != -1) {
                      indexesToRemove.add(index);
                    }
                  }

                  return ObservableListUpdateAction<String>(
                    removeAtPositions: indexesToRemove,
                    addItems: added.map<String>(mapItem).toList(),
                  );
                },
                onRight: (final String state) {
                  return ObservableListUpdateAction<String>(clear: true);
                },
              );

              updater(action);
            },
          );

          final Disposable listener = rxList.listen();

          expect(rxList.value, <String>['E2', 'E4', 'E6', 'E8', 'E10', 'E12']);

          rxSet.setState('custom');
          expect(rxList.value, <String>[]);

          rxSet.addAll(<int>[4, 6, 7]);
          expect(rxSet.value.leftOrThrow, <int>{4, 6, 7});
          expect(rxList.value, <String>['E8', 'E12', 'E14']);

          rxSet.remove(4);
          expect(rxSet.value.leftOrThrow, <int>{6, 7});
          expect(rxList.value, <String>['E12', 'E14']);

          await listener.dispose();

          // buffer changes
          rxSet.add(8);
          rxSet.remove(6);

          expect(rxSet.value.leftOrThrow, <int>{8, 7});
          expect(rxList.value, <String>['E12', 'E14']);

          rxList.listen();

          expect(rxList.value, <String>['E14', 'E16']);

          await rxSet.dispose();
          expect(rxList.disposed, true);
        });
      });

      group('statefulList', () {
        test('Should transform the set to a stateful list', () async {
          final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
          rxSet.add(6);

          final ObservableStatefulList<String, String> rxList = rxSet.transformChangeAs.statefulList(
            transform: (
              final ObservableStatefulList<String, String> current,
              final Either<Set<int>, String> state,
              final Either<ObservableSetChange<int>, String> change,
              final Emitter<Either<ObservableListUpdateAction<String>, String>> updater,
            ) {
              // convert to 'Ei*2', or to custom if custom

              String mapItem(final int item) => 'E${item * 2}';

              final Either<ObservableListUpdateAction<String>, String> action = change.fold(
                onLeft: (final ObservableSetChange<int> change) {
                  final Set<int> added = change.added;
                  final Set<int> removed = change.removed;

                  final Set<int> indexesToRemove = <int>{};
                  for (final int item in removed) {
                    final int index = current.value.leftOrThrow.indexOf(mapItem(item));
                    if (index != -1) {
                      indexesToRemove.add(index);
                    }
                  }

                  return Either<ObservableListUpdateAction<String>, String>.left(
                    ObservableListUpdateAction<String>(
                      removeAtPositions: indexesToRemove,
                      addItems: added.map<String>(mapItem).toList(),
                    ),
                  );
                },
                onRight: (final String state) {
                  return Either<ObservableListUpdateAction<String>, String>.right(state);
                },
              );

              updater(action);
            },
          );

          final Disposable listener = rxList.listen();

          expect(rxList.value.leftOrThrow, <String>['E2', 'E4', 'E6', 'E8', 'E10', 'E12']);

          rxSet.setState('custom');
          expect(rxList.value.leftOrNull, null);
          expect(rxList.value.rightOrThrow, 'custom');

          rxSet.addAll(<int>[4, 6, 7]);
          expect(rxSet.value.leftOrThrow, <int>{4, 6, 7});
          expect(rxList.value.leftOrThrow, <String>['E8', 'E12', 'E14']);

          rxSet.remove(4);
          expect(rxSet.value.leftOrThrow, <int>{6, 7});
          expect(rxList.value.leftOrThrow, <String>['E12', 'E14']);

          await listener.dispose();

          // buffer changes
          rxSet.add(8);
          rxSet.remove(6);

          expect(rxSet.value.leftOrThrow, <int>{8, 7});
          expect(rxList.value.leftOrThrow, <String>['E12', 'E14']);

          rxList.listen();

          expect(rxList.value.leftOrThrow, <String>['E14', 'E16']);

          await rxSet.dispose();
          expect(rxList.disposed, true);
        });
      });

      group('map', () {
        test('Should transform the set to a map', () async {
          final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
          rxSet.add(6);

          final ObservableMap<int, String> rxMap = rxSet.transformChangeAs.map(
            transform: (
              final ObservableMap<int, String> current,
              final Either<Set<int>, String> state,
              final Either<ObservableSetChange<int>, String> change,
              final Emitter<ObservableMapUpdateAction<int, String>> updater,
            ) {
              // convert to key: 'Ei*2', or to empty if custom

              String mapItem(final int item) => 'E${item * 2}';

              final ObservableMapUpdateAction<int, String> action = change.fold(
                onLeft: (final ObservableSetChange<int> change) {
                  final Set<int> added = change.added;
                  final Set<int> removed = change.removed;

                  return ObservableMapUpdateAction<int, String>(
                    removeKeys: removed,
                    addItems: added.fold<Map<int, String>>(
                      <int, String>{},
                      (final Map<int, String> acc, final int item) => acc..[item] = mapItem(item),
                    ),
                  );
                },
                onRight: (final String state) {
                  return ObservableMapUpdateAction<int, String>(clear: true);
                },
              );

              updater(action);
            },
          );

          final Disposable listener = rxMap.listen();

          expect(rxMap.value, <int, String>{1: 'E2', 2: 'E4', 3: 'E6', 4: 'E8', 5: 'E10', 6: 'E12'});

          rxSet.setState('custom');
          expect(rxMap.value, <int, String>{});

          rxSet.addAll(<int>[4, 6, 7]);
          expect(rxSet.value.leftOrThrow, <int>{4, 6, 7});
          expect(rxMap.value, <int, String>{4: 'E8', 6: 'E12', 7: 'E14'});

          rxSet.remove(4);
          expect(rxSet.value.leftOrThrow, <int>{6, 7});
          expect(rxMap.value, <int, String>{6: 'E12', 7: 'E14'});

          await listener.dispose();

          // buffer changes
          rxSet.add(8);
          rxSet.remove(6);
          expect(rxSet.value.leftOrThrow, <int>{8, 7});

          rxMap.listen();
          expect(rxMap.value, <int, String>{8: 'E16', 7: 'E14'});

          await rxSet.dispose();
          expect(rxMap.disposed, true);
        });
      });

      group('statefulMap', () {
        test('Should transform the set to a stateful map', () async {
          final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
          rxSet.add(6);

          final ObservableStatefulMap<int, String, String> rxMap = rxSet.transformChangeAs.statefulMap(
            transform: (
              final ObservableStatefulMap<int, String, String> current,
              final Either<Set<int>, String> state,
              final Either<ObservableSetChange<int>, String> change,
              final Emitter<Either<ObservableMapUpdateAction<int, String>, String>> updater,
            ) {
              // convert to key: 'Ei*2', or to custom if custom

              String mapItem(final int item) => 'E${item * 2}';

              final Either<ObservableMapUpdateAction<int, String>, String> action = change.fold(
                onLeft: (final ObservableSetChange<int> change) {
                  final Set<int> added = change.added;
                  final Set<int> removed = change.removed;

                  return Either<ObservableMapUpdateAction<int, String>, String>.left(
                    ObservableMapUpdateAction<int, String>(
                      removeKeys: removed,
                      addItems: added.fold<Map<int, String>>(
                        <int, String>{},
                        (final Map<int, String> acc, final int item) => acc..[item] = mapItem(item),
                      ),
                    ),
                  );
                },
                onRight: (final String state) {
                  return Either<ObservableMapUpdateAction<int, String>, String>.right(state);
                },
              );

              updater(action);
            },
          );

          final Disposable listener = rxMap.listen();

          expect(rxMap.value.leftOrThrow, <int, String>{1: 'E2', 2: 'E4', 3: 'E6', 4: 'E8', 5: 'E10', 6: 'E12'});

          rxSet.setState('custom');
          expect(rxMap.value.leftOrNull, null);
          expect(rxMap.value.rightOrThrow, 'custom');

          rxSet.addAll(<int>[4, 6, 7]);
          expect(rxSet.value.leftOrThrow, <int>{4, 6, 7});
          expect(rxMap.value.leftOrThrow, <int, String>{4: 'E8', 6: 'E12', 7: 'E14'});

          rxSet.remove(4);
          expect(rxSet.value.leftOrThrow, <int>{6, 7});
          expect(rxMap.value.leftOrThrow, <int, String>{6: 'E12', 7: 'E14'});

          await listener.dispose();

          // buffer changes
          rxSet.add(8);
          rxSet.remove(6);
          expect(rxSet.value.leftOrThrow, <int>{8, 7});

          rxMap.listen();
          expect(rxMap.value.leftOrThrow, <int, String>{8: 'E16', 7: 'E14'});

          await rxSet.dispose();
          expect(rxMap.disposed, true);
        });
      });

      group('set', () {
        test('Should transform the set to a set', () async {
          final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
          rxSet.add(6);

          final ObservableSet<String> rxSetTransformed = rxSet.transformChangeAs.set(
            transform: (
              final ObservableSet<String> current,
              final Either<Set<int>, String> state,
              final Either<ObservableSetChange<int>, String> change,
              final Emitter<ObservableSetUpdateAction<String>> updater,
            ) {
              // convert to 'Ei*2', or to empty if custom

              String mapItem(final int item) => 'E${item * 2}';

              final ObservableSetUpdateAction<String> action = change.fold(
                onLeft: (final ObservableSetChange<int> change) {
                  final Set<int> added = change.added;
                  final Set<int> removed = change.removed;

                  return ObservableSetUpdateAction<String>(
                    removeItems: removed.map<String>(mapItem).toSet(),
                    addItems: added.map<String>(mapItem).toSet(),
                  );
                },
                onRight: (final String state) {
                  return ObservableSetUpdateAction<String>(clear: true);
                },
              );

              updater(action);
            },
          );

          final Disposable listener = rxSetTransformed.listen();

          expect(rxSetTransformed.value, <String>{'E2', 'E4', 'E6', 'E8', 'E10', 'E12'});

          rxSet.setState('custom');
          expect(rxSetTransformed.value, <String>{});

          rxSet.addAll(<int>[4, 6, 7]);
          expect(rxSet.value.leftOrThrow, <int>{4, 6, 7});
          expect(rxSetTransformed.value, <String>{'E8', 'E12', 'E14'});

          rxSet.remove(4);
          expect(rxSet.value.leftOrThrow, <int>{6, 7});
          expect(rxSetTransformed.value, <String>{'E12', 'E14'});

          await listener.dispose();

          // buffer changes
          rxSet.add(8);
          rxSet.remove(6);
          expect(rxSet.value.leftOrThrow, <int>{8, 7});
          expect(rxSetTransformed.value, <String>{'E12', 'E14'});

          rxSetTransformed.listen();
          expect(rxSetTransformed.value, <String>{'E14', 'E16'});

          await rxSet.dispose();
          expect(rxSetTransformed.disposed, true);
        });
      });

      group('statefulSet', () {
        test('Should transform the set to a stateful set', () async {
          final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3, 4, 5]);
          rxSet.add(6);

          final ObservableStatefulSet<String, String> rxSetTransformed = rxSet.transformChangeAs.statefulSet(
            transform: (
              final ObservableStatefulSet<String, String> current,
              final Either<Set<int>, String> state,
              final Either<ObservableSetChange<int>, String> change,
              final Emitter<Either<ObservableSetUpdateAction<String>, String>> updater,
            ) {
              // convert to 'Ei*2', or to custom if custom

              String mapItem(final int item) => 'E${item * 2}';

              final Either<ObservableSetUpdateAction<String>, String> action = change.fold(
                onLeft: (final ObservableSetChange<int> change) {
                  final Set<int> added = change.added;
                  final Set<int> removed = change.removed;

                  return Either<ObservableSetUpdateAction<String>, String>.left(
                    ObservableSetUpdateAction<String>(
                      removeItems: removed.map<String>(mapItem).toSet(),
                      addItems: added.map<String>(mapItem).toSet(),
                    ),
                  );
                },
                onRight: (final String state) {
                  return Either<ObservableSetUpdateAction<String>, String>.right(state);
                },
              );

              updater(action);
            },
          );

          final Disposable listener = rxSetTransformed.listen();

          expect(rxSetTransformed.value.leftOrThrow, <String>{'E2', 'E4', 'E6', 'E8', 'E10', 'E12'});

          rxSet.setState('custom');
          expect(rxSetTransformed.value.leftOrNull, null);
          expect(rxSetTransformed.value.rightOrThrow, 'custom');

          rxSet.addAll(<int>[4, 6, 7]);
          expect(rxSet.value.leftOrThrow, <int>{4, 6, 7});
          expect(rxSetTransformed.value.leftOrThrow, <String>{'E8', 'E12', 'E14'});

          rxSet.remove(4);
          expect(rxSet.value.leftOrThrow, <int>{6, 7});
          expect(rxSetTransformed.value.leftOrThrow, <String>{'E12', 'E14'});

          await listener.dispose();

          // buffer changes
          rxSet.add(8);
          rxSet.remove(6);
          expect(rxSet.value.leftOrThrow, <int>{8, 7});
          expect(rxSetTransformed.value.leftOrThrow, <String>{'E12', 'E14'});

          rxSetTransformed.listen();
          expect(rxSetTransformed.value.leftOrThrow, <String>{'E14', 'E16'});

          await rxSet.dispose();
          expect(rxSetTransformed.disposed, true);
        });
      });
    });
  });
}

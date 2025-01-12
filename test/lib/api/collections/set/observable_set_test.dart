import 'dart:async';
import 'dart:collection';

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

import '../../../todo_item.dart';

void main() {
  group('ObservableSet', () {
    group('just', () {
      test('Should create a new ObservableSet with the given value', () {
        final ObservableSet<int> rx = ObservableSet<int>.just(<int>{1, 2, 3});
        expect(rx.toList(), <int>[1, 2, 3]);
      });

      test('Should create a new ObservableSet with the given value and factory', () {
        final ObservableSet<int> rx = ObservableSet<int>.just(
          <int>{1, 2, 3},
          factory: (final Iterable<int>? items) {
            return SplayTreeSet<int>.of(
              items ?? <int>{},
              (final int a, final int b) {
                return b.compareTo(a);
              },
            );
          },
        );
        expect(rx.toList(), <int>[3, 2, 1]);
      });
    });

    group('merged', () {
      test('Should create a new ObservableSet with the given collections', () {
        final ObservableSet<int> rx1 = ObservableSet<int>.just(<int>{1, 2, 3});
        final ObservableSet<int> rx2 = ObservableSet<int>.just(<int>{4, 5, 6});
        final ObservableSet<int> rx = ObservableSet<int>.merged(collections: <ObservableSet<int>>[rx1, rx2]);

        rx.listen();

        expect(rx.toList(), <int>[1, 2, 3, 4, 5, 6]);
      });

      test('Should create a new ObservableSet with the given collections and factory', () {
        final ObservableSet<int> rx1 = ObservableSet<int>.just(<int>{1, 2, 3});
        final ObservableSet<int> rx2 = ObservableSet<int>.just(<int>{4, 5, 6});
        final ObservableSet<int> rx = ObservableSet<int>.merged(
          collections: <ObservableSet<int>>[rx1, rx2],
          factory: (final Iterable<int>? items) {
            return SplayTreeSet<int>.of(
              items ?? <int>{},
              (final int a, final int b) {
                return b.compareTo(a);
              },
            );
          },
        );

        rx.listen();

        expect(rx.toList(), <int>[6, 5, 4, 3, 2, 1]);
      });

      test('Should update when the source collections change', () {
        final RxSet<int> rx1 = RxSet<int>(initial: <int>{1, 2, 3});
        final RxSet<int> rx2 = RxSet<int>(initial: <int>{4, 5, 6});
        final ObservableSet<int> rx = ObservableSet<int>.merged(collections: <ObservableSet<int>>[rx1, rx2]);
        rx.listen();

        expect(rx.toList(), <int>[1, 2, 3, 4, 5, 6]);

        rx1.add(7);
        expect(rx.toList(), <int>[1, 2, 3, 4, 5, 6, 7]);

        rx2.remove(5);
        expect(rx.toList(), <int>[1, 2, 3, 4, 6, 7]);

        rx1.remove(1);
        expect(rx.toList(), <int>[2, 3, 4, 6, 7]);
      });

      test('Should update with factory when the source collections change', () {
        final RxSet<int> rx1 = RxSet<int>(initial: <int>{1, 2, 3});
        final RxSet<int> rx2 = RxSet<int>(initial: <int>{4, 5, 6});
        final ObservableSet<int> rx = ObservableSet<int>.merged(
          collections: <ObservableSet<int>>[rx1, rx2],
          factory: (final Iterable<int>? items) {
            return SplayTreeSet<int>.of(
              items ?? <int>{},
              (final int a, final int b) {
                return b.compareTo(a);
              },
            );
          },
        );
        rx.listen();

        expect(rx.toList(), <int>[6, 5, 4, 3, 2, 1]);

        rx1.add(7);
        expect(rx.toList(), <int>[7, 6, 5, 4, 3, 2, 1]);

        rx2.remove(5);
        expect(rx.toList(), <int>[7, 6, 4, 3, 2, 1]);

        rx1.remove(1);
        expect(rx.toList(), <int>[7, 6, 4, 3, 2]);
      });

      test('Should dispose when all source collections are disposed', () async {
        final RxSet<int> rx1 = RxSet<int>(initial: <int>{1, 2, 3});
        final RxSet<int> rx2 = RxSet<int>(initial: <int>{4, 5, 6});
        final ObservableSet<int> rx = ObservableSet<int>.merged(collections: <ObservableSet<int>>[rx1, rx2]);
        final Disposable listener = rx.listen();

        expect(rx.disposed, false);

        await rx1.dispose();
        expect(rx.disposed, false);

        await rx2.dispose();
        expect(rx.disposed, true);

        await listener.dispose();
      });

      test('Should continue to function when one source collection is disposed', () async {
        final RxSet<int> rx1 = RxSet<int>(initial: <int>{1, 2, 3});
        final RxSet<int> rx2 = RxSet<int>(initial: <int>{4, 5, 6});
        final ObservableSet<int> rx = ObservableSet<int>.merged(collections: <ObservableSet<int>>[rx1, rx2]);
        rx.listen();

        expect(rx.toList(), <int>[1, 2, 3, 4, 5, 6]);

        await rx1.dispose();
        expect(rx.toList(), <int>[1, 2, 3, 4, 5, 6]);
        expect(rx.disposed, false);

        rx2.add(7);
        expect(rx.toList(), <int>[1, 2, 3, 4, 5, 6, 7]);

        rx2.remove(5);
        expect(rx.toList(), <int>[1, 2, 3, 4, 6, 7]);

        await rx2.dispose();
        expect(rx.disposed, true);
      });

      test('Should create a new ObservableSet with overlapping collections', () {
        final RxSet<int> rx1 = RxSet<int>(initial: <int>{1, 2, 3});
        final RxSet<int> rx2 = RxSet<int>(initial: <int>{3, 4, 5});
        final ObservableSet<int> rx = ObservableSet<int>.merged(collections: <ObservableSet<int>>[rx1, rx2]);

        rx.listen();

        expect(rx.toList(), <int>[1, 2, 3, 4, 5]);

        rx2.remove(3);

        expect(
          rx.toList(),
          <int>[1, 2, 3, 4, 5],
          reason: 'Should not remove because the item is in the other collection',
        );

        rx1.remove(3);
        expect(rx.toList(), <int>[1, 2, 4, 5]);
      });
    });

    group('fromStream', () {
      test('Should create an ObservableSet from the specified stream', () async {
        final StreamController<ObservableSetUpdateAction<int>> controller =
            StreamController<ObservableSetUpdateAction<int>>(sync: true);

        final ObservableSet<int> rxList = ObservableSet<int>.fromStream(
          stream: controller.stream,
          initial: <int>{0},
        );
        rxList.listen();

        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{1, 2}));
        expect(rxList.length, 3);
        expect(rxList.value, <int>{0, 1, 2});

        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{3, 4}));
        expect(rxList.length, 5);
        expect(rxList.value, <int>{0, 1, 2, 3, 4});

        controller.add(ObservableSetUpdateAction<int>(removeItems: <int>{0}));
        expect(rxList.length, 4);
        expect(rxList.value, <int>{1, 2, 3, 4});

        await controller.close();
        await rxList.dispose();

        expect(rxList.disposed, true);
      });

      test('Should handle multiple rapid updates from the stream', () {
        final StreamController<ObservableSetUpdateAction<int>> controller =
            StreamController<ObservableSetUpdateAction<int>>(sync: true);

        final ObservableSet<int> rxList = ObservableSet<int>.fromStream(
          stream: controller.stream,
          initial: <int>{0},
        );
        rxList.listen();

        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{1}));
        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{2}));
        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{3}));

        expect(rxList.length, 4);
        expect(rxList.value, <int>[0, 1, 2, 3]);
      });

      test('Should respect factory', () {
        final StreamController<ObservableSetUpdateAction<int>> controller =
            StreamController<ObservableSetUpdateAction<int>>(sync: true);

        final ObservableSet<int> rxList = ObservableSet<int>.fromStream(
          stream: controller.stream,
          initial: <int>{0},
          factory: (final Iterable<int>? items) {
            return SplayTreeSet<int>.of(
              items ?? <int>{},
              (final int a, final int b) {
                return b.compareTo(a);
              },
            );
          },
        );
        rxList.listen();

        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{1}));
        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{2}));
        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{3}));

        expect(rxList.length, 4);
        expect(rxList.value, <int>[3, 2, 1, 0]);
      });

      test('Should handle stream errors when onError is set', () async {
        final StreamController<ObservableSetUpdateAction<int>> controller =
            StreamController<ObservableSetUpdateAction<int>>(sync: true);

        final ObservableSet<int> rxList = ObservableSet<int>.fromStream(
          stream: controller.stream,
          initial: <int>{0},
          onError: (final dynamic error) {
            return <int>{-1};
          },
        );
        rxList.listen();

        controller.addError(Exception('Stream error'));

        expect(rxList.length, 1);
        expect(rxList.value, <int>[-1]);

        await controller.close();
        await rxList.dispose();

        expect(rxList.disposed, true);
      });

      test('Should handle error when onError is set without returning a new set', () {
        final StreamController<ObservableSetUpdateAction<int>> controller =
            StreamController<ObservableSetUpdateAction<int>>(sync: true);

        final ObservableSet<int> rxList = ObservableSet<int>.fromStream(
          stream: controller.stream,
          initial: <int>{0},
          onError: (final dynamic error) {
            return null;
          },
        );
        rxList.listen();

        controller.addError(Exception('Stream error'));

        expect(rxList.length, 1);
        expect(rxList.value, <int>[0]);
      });

      test('Should propagate error to downstream handler', () {
        final StreamController<ObservableSetUpdateAction<int>> controller =
            StreamController<ObservableSetUpdateAction<int>>(sync: true);

        final ObservableSet<int> rxList = ObservableSet<int>.fromStream(
          stream: controller.stream,
          initial: <int>{0},
        );

        bool errorReceived = false;

        rxList.listen(
          onError: (final dynamic error, final StackTrace stack) {
            errorReceived = true;
            expect(error, isException);
          },
        );
        controller.addError(Exception('Stream error'));

        expect(errorReceived, true);
      });

      test('Should throw stream errors when onError is not set', () async {
        final StreamController<ObservableSetUpdateAction<int>> controller =
            StreamController<ObservableSetUpdateAction<int>>(sync: true);

        final ObservableSet<int> rxList = ObservableSet<int>.fromStream(
          stream: controller.stream,
          initial: <int>{0},
        );

        bool catchError = false;

        runZonedGuarded(() {
          rxList.listen();
        }, (final Object error, final _) {
          catchError = true;
          expect(error, isA<StateError>());
          expect((error as StateError).message, 'Stream error');
        });

        controller.addError(StateError('Stream error'));

        expect(catchError, true);

        expect(rxList.length, 1);
        expect(rxList.value, <int>[0]);

        await controller.close();
        await rxList.dispose();

        expect(rxList.disposed, true);
      });

      test('Should update the set with all the pending changes after listening', () async {
        final StreamController<ObservableSetUpdateAction<int>> controller =
            StreamController<ObservableSetUpdateAction<int>>(sync: true);

        final ObservableSet<int> rxList = ObservableSet<int>.fromStream(
          stream: controller.stream,
          initial: <int>{0},
        );

        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{1}));
        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{2}));
        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{3}));

        Disposable listener = rxList.listen();

        expect(rxList.length, 4);
        expect(rxList.value, <int>[0, 1, 2, 3]);

        await listener.dispose();

        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{4}));
        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{5}));

        listener = rxList.listen();

        expect(rxList.length, 6);
        expect(rxList.value, <int>[0, 1, 2, 3, 4, 5]);
      });
    });

    group('value', () {
      test('Should return an unmodifiable view of the set', () {
        final ObservableSet<int> rx = ObservableSet<int>.just(<int>{1, 2, 3});
        expect(rx.value, <int>{1, 2, 3});
        expect(() => rx.value.add(4), throwsUnsupportedError);
      });
    });

    group('length', () {
      test('Should return the length of the set', () {
        final RxSet<int> rx = RxSet<int>(initial: <int>{1, 2, 3});
        expect(rx.length, 3);
      });
    });

    group('changeFactory', () {
      test('Should return a new ObservableSet with the given factory', () async {
        final RxSet<int> rxSource = RxSet<int>(initial: <int>{1, 2, 3});
        final ObservableSet<int> rx = rxSource.changeFactory(
          (final Iterable<int>? items) {
            return SplayTreeSet<int>.of(
              items ?? <int>{},
              (final int a, final int b) {
                return b.compareTo(a);
              },
            );
          },
        );
        rx.listen();

        expect(rx.toList(), <int>[3, 2, 1]);

        rxSource.add(4);
        expect(rx.toList(), <int>[4, 3, 2, 1]);

        rxSource.remove(2);
        expect(rx.toList(), <int>[4, 3, 1]);

        await rxSource.dispose();
        expect(rx.disposed, true);
      });
    });

    group('sorted', () {
      test('Should return a new ObservableSet with the items sorted by the given comparator', () async {
        final RxSet<int> rx = RxSet<int>(initial: <int>{3, 1, 2});
        final ObservableSet<int> rxSorted = rx.sorted((final int a, final int b) => a.compareTo(b));
        final Disposable listener = rxSorted.listen();

        expect(rxSorted.toList(), <int>[1, 2, 3]);

        rx.add(4);
        expect(rxSorted.toList(), <int>[1, 2, 3, 4]);

        rx.remove(2);
        expect(rxSorted.toList(), <int>[1, 3, 4]);

        await listener.dispose();
        // add buffered changes
        rx.addAll(<int>[5, 6]);
        rx.remove(5);
        rx.add(7);
        rx.add(0);
        rx.remove(3);
        rx.remove(4);

        expect(rxSorted.toList(), <int>[1, 3, 4]);

        rxSorted.listen();

        expect(rxSorted.toList(), <int>[0, 1, 6, 7]);

        await rx.dispose();
        expect(rxSorted.disposed, true);
      });
    });

    group('contains', () {
      test('Should return true if the item is in the set', () {
        final RxSet<int> rx = RxSet<int>(initial: <int>{1, 2, 3});
        expect(rx.contains(1), true);
        expect(rx.contains(2), true);
        expect(rx.contains(3), true);
        expect(rx.contains(4), false);
      });
    });

    group('filterItem', () {
      test('Should return a new ObservableSet with the items that match the predicate', () async {
        final RxSet<int> rx = RxSet<int>(initial: <int>{1, 2, 3});
        final ObservableSet<int> rxFiltered = rx.filterItem(
          (final int item) {
            return item > 1;
          },
        );
        final Disposable listener = rxFiltered.listen();

        expect(rxFiltered.toList(), <int>[2, 3]);

        rx.add(4);
        expect(rxFiltered.toList(), <int>[2, 3, 4]);

        rx.remove(2);
        expect(rxFiltered.toList(), <int>[3, 4]);

        await listener.dispose();
        // add buffered changes
        rx.addAll(<int>[5, 6]);
        rx.remove(5);
        rx.add(7);
        rx.add(0);
        rx.remove(3);
        rx.remove(4);

        expect(rxFiltered.toList(), <int>[3, 4]);

        rxFiltered.listen();

        expect(rxFiltered.toList(), <int>[6, 7]);

        await rx.dispose();
        expect(rxFiltered.disposed, true);
      });

      test('Should respect factory when set', () async {
        final RxSet<int> rx = RxSet<int>(initial: <int>{1, 2, 3});
        final ObservableSet<int> rxFiltered = rx.filterItem(
          (final int item) {
            return item > 1;
          },
          factory: (final Iterable<int>? items) {
            return SplayTreeSet<int>.of(
              items ?? <int>{},
              (final int a, final int b) {
                return b.compareTo(a);
              },
            );
          },
        );
        final Disposable listener = rxFiltered.listen();

        expect(rxFiltered.toList(), <int>[3, 2]);

        rx.add(4);
        expect(rxFiltered.toList(), <int>[4, 3, 2]);

        rx.remove(2);
        expect(rxFiltered.toList(), <int>[4, 3]);

        await listener.dispose();
        // add buffered changes
        rx.addAll(<int>[5, 6]);
        rx.remove(5);
        rx.add(7);
        rx.add(0);
        rx.remove(3);
        rx.remove(4);

        expect(rxFiltered.toList(), <int>[4, 3]);

        rxFiltered.listen();

        expect(rxFiltered.toList(), <int>[7, 6]);

        await rx.dispose();
        expect(rxFiltered.disposed, true);
      });
    });

    group('mapItem', () {
      test('Should return a new ObservableSet with the items mapped by the given function', () async {
        final RxSet<int> rxSource = RxSet<int>();
        final ObservableSet<String> rxTitles = rxSource.mapItem<String>(
          (final int item) {
            return item.toString().toUpperCase();
          },
        );

        final Disposable listener = rxTitles.listen();

        rxSource.addAll(<int>[1, 2, 3]);
        expect(rxTitles.toList(), <String>['1', '2', '3']);

        rxSource.add(4);
        expect(rxTitles.toList(), <String>['1', '2', '3', '4']);

        rxSource.remove(2);
        expect(rxTitles.toList(), <String>['1', '3', '4']);

        await listener.dispose();
        // add buffered changes
        rxSource.addAll(<int>[5, 6]);
        rxSource.remove(5);
        rxSource.add(7);
        rxSource.removeAll(<int>[2, 3]);

        expect(rxTitles.toList(), <String>['1', '3', '4']);

        rxTitles.listen();

        expect(rxTitles.toList(), <String>['1', '4', '6', '7']);

        await rxSource.dispose();
        expect(rxTitles.disposed, true);
      });

      test('Should respect factory when set', () async {
        final RxSet<int> rxSource = RxSet<int>();
        final ObservableSet<String> rxTitles = rxSource.mapItem<String>(
          (final int item) {
            return item.toString().toUpperCase();
          },
          factory: (final Iterable<String>? items) {
            return SplayTreeSet<String>.of(
              items ?? <String>{},
              (final String a, final String b) {
                return b.compareTo(a);
              },
            );
          },
        );

        final Disposable listener = rxTitles.listen();

        rxSource.addAll(<int>[1, 2, 3]);
        expect(rxTitles.toList(), <String>['3', '2', '1']);

        rxSource.add(4);
        expect(rxTitles.toList(), <String>['4', '3', '2', '1']);

        rxSource.remove(2);
        expect(rxTitles.toList(), <String>['4', '3', '1']);

        await listener.dispose();
        // add buffered changes
        rxSource.addAll(<int>[5, 6]);
        rxSource.remove(5);
        rxSource.add(7);
        rxSource.removeAll(<int>[2, 3]);

        expect(rxTitles.toList(), <String>['4', '3', '1']);

        rxTitles.listen();

        expect(rxTitles.toList(), <String>['7', '6', '4', '1']);
      });
    });

    group('rxItem', () {
      test('Should return the item by the predicate', () async {
        final RxSet<TodoItem> rx = RxSet<TodoItem>();
        final Observable<TodoItem?> rxItem = rx.rxItem(
          (final TodoItem item) {
            return item.id == '1';
          },
        );

        final Disposable listener = rxItem.listen();
        final TodoItem item1 = TodoItem(
          id: '1',
          title: 'title1',
          description: 'description1',
          completed: false,
        );

        rx.addAll(<TodoItem>[item1]);

        expect(rxItem.value, item1);

        rx.remove(item1);
        expect(rxItem.value, null);

        rx.add(TodoItem(id: '2'));
        expect(rxItem.value, null);

        rx.add(item1);
        expect(rxItem.value, item1);

        await listener.dispose();

        rx.remove(item1);
        expect(rxItem.value, item1);

        rxItem.listen();

        expect(rxItem.value, null);

        await rx.dispose();
        expect(rxItem.disposed, true);
      });
    });

    group('toList', () {
      test('Should return a list with the items of the set', () {
        final RxSet<int> rx = RxSet<int>.splayTreeSet(
          compare: (final int a, final int b) => b.compareTo(a),
          initial: <int>{1, 2, 3},
        );
        expect(rx.toList(), <int>[3, 2, 1]);
      });
    });

    group('transformAs', () {
      group('list', () {
        test('Should return an ObservableList with the given transform', () async {
          final RxSet<int> rx = RxSet<int>(initial: <int>{1, 2, 3});
          rx.add(4);

          final ObservableList<String> rxList = rx.transformAs.list<String>(
            transform: (
              final ObservableList<String> state,
              final Set<int> value,
              final Emitter<List<String>> updater,
            ) {
              updater(value.map((final int item) => item.toString()).toList());
            },
          );
          final Disposable listener = rxList.listen();

          expect(rxList.value, <String>['1', '2', '3', '4']);

          rx.remove(2);
          expect(rxList.value, <String>['1', '3', '4']);

          await listener.dispose();
          // add buffered changes
          rx.addAll(<int>[5, 6]);
          rx.remove(5);
          rx.add(7);
          rx.removeAll(<int>[2, 3]);

          expect(rxList.value, <String>['1', '3', '4']);

          rxList.listen();

          expect(rxList.value, <String>['1', '4', '6', '7']);

          await rx.dispose();
          expect(rxList.disposed, true);
        });
      });

      group('statefulList', () {
        test('Should return an ObservableStatefulList with the given transform', () async {
          final RxSet<int> rx = RxSet<int>(initial: <int>{1, 2, 3});
          rx.add(4);

          final ObservableStatefulList<String, int> rxList = rx.transformAs.statefulList<String, int>(
            transform: (
              final ObservableStatefulList<String, int> state,
              final Set<int> value,
              final Emitter<Either<List<String>, int>> updater,
            ) {
              updater(Either<List<String>, int>.left(value.map((final int item) => item.toString()).toList()));
            },
          );
          final Disposable listener = rxList.listen();

          expect(rxList.value.leftOrThrow, <String>['1', '2', '3', '4']);

          rx.remove(2);
          expect(rxList.value.leftOrThrow, <String>['1', '3', '4']);

          await listener.dispose();
          // add buffered changes
          rx.addAll(<int>[5, 6]);
          rx.remove(5);
          rx.add(7);
          rx.removeAll(<int>[2, 3]);

          expect(rxList.value.leftOrThrow, <String>['1', '3', '4']);

          rxList.listen();

          expect(rxList.value.leftOrThrow, <String>['1', '4', '6', '7']);

          await rx.dispose();
          expect(rxList.disposed, true);
        });
      });

      group('map', () {
        test('Should return an ObservableMap with the given transform', () async {
          final RxSet<int> rx = RxSet<int>(initial: <int>{1, 2, 3});
          rx.add(4);

          final ObservableMap<int, String> rxMap = rx.transformAs.map<int, String>(
            transform: (
              final ObservableMap<int, String> state,
              final Set<int> value,
              final Emitter<Map<int, String>> updater,
            ) {
              // convert to E+index
              updater(
                value.fold<Map<int, String>>(<int, String>{}, (final Map<int, String> acc, final int item) {
                  acc[item] = 'E${item.toString()}';
                  return acc;
                }),
              );
            },
          );
          final Disposable listener = rxMap.listen();

          expect(rxMap.value, <int, String>{1: 'E1', 2: 'E2', 3: 'E3', 4: 'E4'});

          rx.remove(2);
          expect(rxMap.value, <int, String>{1: 'E1', 3: 'E3', 4: 'E4'});

          await listener.dispose();
          // add buffered changes

          rx.addAll(<int>[5, 6]);
          rx.remove(5);
          rx.add(7);
          rx.removeAll(<int>[2, 3]);

          expect(rxMap.value, <int, String>{1: 'E1', 3: 'E3', 4: 'E4'});

          rxMap.listen();

          expect(rxMap.value, <int, String>{1: 'E1', 4: 'E4', 6: 'E6', 7: 'E7'});

          await rx.dispose();
          expect(rxMap.disposed, true);
        });
      });

      group('statefulMap', () {
        test('Should return an ObservableStatefulMap with the given transform', () async {
          final RxSet<int> rx = RxSet<int>(initial: <int>{1, 2, 3});
          rx.add(4);

          final ObservableStatefulMap<int, String, int> rxMap = rx.transformAs.statefulMap<int, String, int>(
            transform: (
              final ObservableStatefulMap<int, String, int> state,
              final Set<int> value,
              final Emitter<Either<Map<int, String>, int>> updater,
            ) {
              // convert to E+index
              updater(
                Either<Map<int, String>, int>.left(
                  value.fold<Map<int, String>>(<int, String>{}, (final Map<int, String> acc, final int item) {
                    acc[item] = 'E${item.toString()}';
                    return acc;
                  }),
                ),
              );
            },
          );
          final Disposable listener = rxMap.listen();

          expect(rxMap.value.leftOrThrow, <int, String>{1: 'E1', 2: 'E2', 3: 'E3', 4: 'E4'});

          rx.remove(2);
          expect(rxMap.value.leftOrThrow, <int, String>{1: 'E1', 3: 'E3', 4: 'E4'});

          await listener.dispose();
          // add buffered changes

          rx.addAll(<int>[5, 6]);
          rx.remove(5);
          rx.add(7);
          rx.removeAll(<int>[2, 3]);

          expect(rxMap.value.leftOrThrow, <int, String>{1: 'E1', 3: 'E3', 4: 'E4'});

          rxMap.listen();

          expect(rxMap.value.leftOrThrow, <int, String>{1: 'E1', 4: 'E4', 6: 'E6', 7: 'E7'});

          await rx.dispose();
          expect(rxMap.disposed, true);
        });
      });

      group('set', () {
        test('Should return an ObservableSet with the given transform', () async {
          final RxSet<int> rx = RxSet<int>(initial: <int>{1, 2, 3});
          rx.add(4);

          final ObservableSet<String> rxSet = rx.transformAs.set<String>(
            transform: (
              final ObservableSet<String> state,
              final Set<int> value,
              final Emitter<Set<String>> updater,
            ) {
              // convert to E+index
              updater(
                value.map((final int item) => 'E${item.toString()}').toSet(),
              );
            },
          );
          final Disposable listener = rxSet.listen();

          expect(rxSet.toList(), <String>['E1', 'E2', 'E3', 'E4']);

          rx.remove(2);
          expect(rxSet.toList(), <String>['E1', 'E3', 'E4']);

          await listener.dispose();
          // add buffered changes

          rx.addAll(<int>[5, 6]);
          rx.remove(5);
          rx.add(7);
          rx.removeAll(<int>[2, 3]);

          expect(rxSet.toList(), <String>['E1', 'E3', 'E4']);

          rxSet.listen();

          expect(rxSet.toList(), <String>['E1', 'E4', 'E6', 'E7']);

          await rx.dispose();
          expect(rxSet.disposed, true);
        });
      });

      group('statefulSet', () {
        test('Should return an ObservableStatefulSet with the given transform', () async {
          final RxSet<int> rx = RxSet<int>(initial: <int>{1, 2, 3});
          rx.add(4);

          final ObservableStatefulSet<String, int> rxSet = rx.transformAs.statefulSet<String, int>(
            transform: (
              final ObservableStatefulSet<String, int> state,
              final Set<int> value,
              final Emitter<Either<Set<String>, int>> updater,
            ) {
              // convert to E+index
              updater(
                Either<Set<String>, int>.left(
                  value.map((final int item) => 'E${item.toString()}').toSet(),
                ),
              );
            },
          );
          final Disposable listener = rxSet.listen();

          expect(rxSet.value.leftOrThrow, <String>{'E1', 'E2', 'E3', 'E4'});

          rx.remove(2);
          expect(rxSet.value.leftOrThrow, <String>{'E1', 'E3', 'E4'});

          await listener.dispose();
          // add buffered changes

          rx.addAll(<int>[5, 6]);
          rx.remove(5);
          rx.add(7);
          rx.removeAll(<int>[2, 3]);

          expect(rxSet.value.leftOrThrow, <String>{'E1', 'E3', 'E4'});

          rxSet.listen();

          expect(rxSet.value.leftOrThrow, <String>{'E1', 'E4', 'E6', 'E7'});

          await rx.dispose();
          expect(rxSet.disposed, true);
        });
      });
    });

    group('transformChangeAs', () {
      group('list', () {
        test('Should transform changes as a list', () async {
          final RxSet<int> rxSource = RxSet<int>(initial: <int>{1, 2, 3});
          rxSource.add(4);
          rxSource.remove(2);

          final ObservableList<String> rxList = rxSource.transformChangeAs.list<String>(
            transform: (
              final ObservableList<String> state,
              final Set<int> value,
              final ObservableSetChange<int> change,
              final Emitter<ObservableListUpdateAction<String>> updater,
            ) {
              // convert to E+index
              final Set<int> removedItems = change.removed;
              final Set<int> removeIndexes = <int>{};

              String mapItem(final int item) => 'E$item';

              for (final int item in removedItems) {
                final int indexOf = state.value.indexOf(mapItem(item));
                if (indexOf != -1) {
                  removeIndexes.add(indexOf);
                }
              }

              final List<String> addedItems = change.added.map((final int item) => mapItem(item)).toList();

              updater(
                ObservableListUpdateAction<String>(
                  addItems: addedItems,
                  removeAtPositions: removeIndexes,
                ),
              );
            },
          );

          final Disposable listener = rxList.listen();
          expect(rxSource.value, <int>{1, 3, 4});
          expect(rxList.value, <String>['E1', 'E3', 'E4']);

          rxSource.add(5);
          expect(rxSource.value, <int>{1, 3, 4, 5});
          expect(rxList.value, <String>['E1', 'E3', 'E4', 'E5']);

          rxSource.remove(3);
          expect(rxSource.value, <int>{1, 4, 5});
          expect(rxList.value, <String>['E1', 'E4', 'E5']);

          rxSource.addAll(<int>[6, 7]);
          expect(rxSource.value, <int>{1, 4, 5, 6, 7});

          rxSource.removeAll(<int>[1, 4]);
          expect(rxSource.value, <int>{5, 6, 7});
          expect(rxList.value, <String>['E5', 'E6', 'E7']);

          rxSource.clear();
          expect(rxSource.value, <int>{});
          expect(rxList.value, <String>[]);

          rxSource.addAll(<int>[1, 2, 3]);
          expect(rxSource.value, <int>{1, 2, 3});
          expect(rxList.value, <String>['E1', 'E2', 'E3']);

          listener.dispose();

          rxSource.add(4);
          rxSource.remove(2);
          expect(rxSource.value, <int>{1, 3, 4});
          expect(rxList.value, <String>['E1', 'E2', 'E3']);

          rxList.listen();
          expect(rxList.value, <String>['E1', 'E3', 'E4']);

          await rxSource.dispose();
          expect(rxList.disposed, true);
        });
      });

      group('statefulList', () {
        test('Should transform changes as a stateful list', () async {
          final RxSet<int> rxSource = RxSet<int>(initial: <int>{1, 2, 3});
          rxSource.add(4);
          rxSource.remove(2);

          final ObservableStatefulList<String, String> rxList = rxSource.transformChangeAs.statefulList<String, String>(
            transform: (
              final ObservableStatefulList<String, String> state,
              final Set<int> value,
              final ObservableSetChange<int> change,
              final Emitter<Either<ObservableListUpdateAction<String>, String>> updater,
            ) {
              if (value.isEmpty) {
                updater(Either<ObservableListUpdateAction<String>, String>.right('empty'));
                return;
              }

              // convert to E+index
              final Set<int> removedItems = change.removed;
              final Set<int> removeIndexes = <int>{};

              String mapItem(final int item) => 'E$item';

              for (final int item in removedItems) {
                final int indexOf = state.value.leftOrThrow.indexOf(mapItem(item));
                if (indexOf != -1) {
                  removeIndexes.add(indexOf);
                }
              }

              final List<String> addedItems = change.added.map((final int item) => mapItem(item)).toList();

              updater(
                Either<ObservableListUpdateAction<String>, String>.left(
                  ObservableListUpdateAction<String>(
                    addItems: addedItems,
                    removeAtPositions: removeIndexes,
                  ),
                ),
              );
            },
          );

          final Disposable listener = rxList.listen();
          expect(rxSource.value, <int>{1, 3, 4});
          expect(rxList.value.leftOrThrow, <String>['E1', 'E3', 'E4']);

          rxSource.add(5);
          expect(rxSource.value, <int>{1, 3, 4, 5});
          expect(rxList.value.leftOrThrow, <String>['E1', 'E3', 'E4', 'E5']);

          rxSource.remove(3);
          expect(rxSource.value, <int>{1, 4, 5});
          expect(rxList.value.leftOrThrow, <String>['E1', 'E4', 'E5']);

          rxSource.addAll(<int>[6, 7]);
          expect(rxSource.value, <int>{1, 4, 5, 6, 7});

          rxSource.removeAll(<int>[1, 4]);
          expect(rxSource.value, <int>{5, 6, 7});
          expect(rxList.value.leftOrThrow, <String>['E5', 'E6', 'E7']);

          rxSource.clear();
          expect(rxSource.value, <int>{});
          expect(rxList.value.rightOrThrow, 'empty');

          rxSource.addAll(<int>[1, 2, 3]);
          expect(rxSource.value, <int>{1, 2, 3});
          expect(rxList.value.leftOrThrow, <String>['E1', 'E2', 'E3']);

          listener.dispose();

          rxSource.add(4);
          rxSource.remove(2);
          expect(rxSource.value, <int>{1, 3, 4});
          expect(rxList.value.leftOrThrow, <String>['E1', 'E2', 'E3']);

          rxList.listen();
          expect(rxList.value.leftOrThrow, <String>['E1', 'E3', 'E4']);

          await rxSource.dispose();
          expect(rxList.disposed, true);
        });
      });

      group('map', () {
        test('Should transform changes as a map', () async {
          final RxSet<int> rxSource = RxSet<int>(initial: <int>{1, 2, 3});
          rxSource.add(4);
          rxSource.remove(2);

          final ObservableMap<int, String> rxMap = rxSource.transformChangeAs.map<int, String>(
            transform: (
              final ObservableMap<int, String> state,
              final Set<int> value,
              final ObservableSetChange<int> change,
              final Emitter<ObservableMapUpdateAction<int, String>> updater,
            ) {
              // convert to value: E+index
              final Set<int> removedItems = change.removed;
              final Set<int> removeKeys = <int>{};

              String mapItem(final int item) => 'E$item';

              for (final int item in removedItems) {
                removeKeys.add(item);
              }

              final Map<int, String> addedItems = <int, String>{};
              for (final int item in change.added) {
                addedItems[item] = mapItem(item);
              }

              updater(
                ObservableMapUpdateAction<int, String>(
                  addItems: addedItems,
                  removeKeys: removeKeys,
                ),
              );
            },
          );

          final Disposable listener = rxMap.listen();
          expect(rxSource.value, <int>{1, 3, 4});
          expect(rxMap.value, <int, String>{1: 'E1', 3: 'E3', 4: 'E4'});

          rxSource.add(5);
          expect(rxSource.value, <int>{1, 3, 4, 5});
          expect(rxMap.value, <int, String>{1: 'E1', 3: 'E3', 4: 'E4', 5: 'E5'});

          rxSource.remove(3);
          expect(rxSource.value, <int>{1, 4, 5});
          expect(rxMap.value, <int, String>{1: 'E1', 4: 'E4', 5: 'E5'});

          rxSource.addAll(<int>[6, 7]);
          expect(rxSource.value, <int>{1, 4, 5, 6, 7});
          expect(rxMap.value, <int, String>{1: 'E1', 4: 'E4', 5: 'E5', 6: 'E6', 7: 'E7'});

          rxSource.removeAll(<int>[1, 4]);
          expect(rxSource.value, <int>{5, 6, 7});
          expect(rxMap.value, <int, String>{5: 'E5', 6: 'E6', 7: 'E7'});

          await listener.dispose();

          rxSource.clear();
          expect(rxSource.value, <int>{});
          expect(rxMap.value, <int, String>{5: 'E5', 6: 'E6', 7: 'E7'});

          rxSource.addAll(<int>[1, 2, 3]);
          expect(rxSource.value, <int>{1, 2, 3});
          expect(rxMap.value, <int, String>{5: 'E5', 6: 'E6', 7: 'E7'});

          rxMap.listen();
          expect(rxMap.value, <int, String>{1: 'E1', 2: 'E2', 3: 'E3'});

          await rxSource.dispose();
          expect(rxMap.disposed, true);
        });
      });

      group('statefulMap', () {
        test('Should transform changes as a stateful map', () async {
          final RxSet<int> rxSource = RxSet<int>(initial: <int>{1, 2, 3});
          rxSource.add(4);
          rxSource.remove(2);

          final ObservableStatefulMap<int, String, String> rxMap =
              rxSource.transformChangeAs.statefulMap<int, String, String>(
            transform: (
              final ObservableStatefulMap<int, String, String> state,
              final Set<int> value,
              final ObservableSetChange<int> change,
              final Emitter<Either<ObservableMapUpdateAction<int, String>, String>> updater,
            ) {
              if (value.isEmpty) {
                updater(Either<ObservableMapUpdateAction<int, String>, String>.right('empty'));
                return;
              }
              // convert to value: E+index
              final Set<int> removedItems = change.removed;
              final Set<int> removeKeys = <int>{};

              String mapItem(final int item) => 'E$item';

              for (final int item in removedItems) {
                removeKeys.add(item);
              }

              final Map<int, String> addedItems = <int, String>{};
              for (final int item in change.added) {
                addedItems[item] = mapItem(item);
              }

              updater(
                Either<ObservableMapUpdateAction<int, String>, String>.left(
                  ObservableMapUpdateAction<int, String>(
                    addItems: addedItems,
                    removeKeys: removeKeys,
                  ),
                ),
              );
            },
          );

          final Disposable listener = rxMap.listen();
          expect(rxSource.value, <int>{1, 3, 4});
          expect(rxMap.value.leftOrThrow, <int, String>{1: 'E1', 3: 'E3', 4: 'E4'});

          rxSource.add(5);
          expect(rxSource.value, <int>{1, 3, 4, 5});
          expect(rxMap.value.leftOrThrow, <int, String>{1: 'E1', 3: 'E3', 4: 'E4', 5: 'E5'});

          rxSource.remove(3);
          expect(rxSource.value, <int>{1, 4, 5});
          expect(rxMap.value.leftOrThrow, <int, String>{1: 'E1', 4: 'E4', 5: 'E5'});

          rxSource.addAll(<int>[6, 7]);
          expect(rxSource.value, <int>{1, 4, 5, 6, 7});
          expect(rxMap.value.leftOrThrow, <int, String>{1: 'E1', 4: 'E4', 5: 'E5', 6: 'E6', 7: 'E7'});

          rxSource.removeAll(<int>[1, 4]);
          expect(rxSource.value, <int>{5, 6, 7});
          expect(rxMap.value.leftOrThrow, <int, String>{5: 'E5', 6: 'E6', 7: 'E7'});

          rxSource.clear();
          expect(rxSource.value, <int>{});
          expect(rxMap.value.rightOrThrow, 'empty');

          rxSource.addAll(<int>[1, 2, 3]);
          expect(rxSource.value, <int>{1, 2, 3});
          expect(rxMap.value.leftOrThrow, <int, String>{1: 'E1', 2: 'E2', 3: 'E3'});

          await listener.dispose();

          rxSource.add(4);
          rxSource.remove(2);
          expect(rxSource.value, <int>{1, 3, 4});
          expect(rxMap.value.leftOrThrow, <int, String>{1: 'E1', 2: 'E2', 3: 'E3'});

          rxMap.listen();
          expect(rxMap.value.leftOrThrow, <int, String>{1: 'E1', 3: 'E3', 4: 'E4'});

          await rxSource.dispose();
          expect(rxMap.disposed, true);
        });
      });

      group('set', () {
        test('Should transform changes as a set', () async {
          final RxSet<int> rxSource = RxSet<int>(initial: <int>{1, 2, 3});
          rxSource.add(4);
          rxSource.remove(2);

          final ObservableSet<String> rxSet = rxSource.transformChangeAs.set<String>(
            transform: (
              final ObservableSet<String> state,
              final Set<int> value,
              final ObservableSetChange<int> change,
              final Emitter<ObservableSetUpdateAction<String>> updater,
            ) {
              // convert to E+index
              final Set<int> removedItems = change.removed;
              final Set<String> removeItems = <String>{};

              String mapItem(final int item) => 'E$item';

              for (final int item in removedItems) {
                removeItems.add(mapItem(item));
              }

              final Set<String> addedItems = change.added.map((final int item) => mapItem(item)).toSet();

              updater(
                ObservableSetUpdateAction<String>(
                  addItems: addedItems,
                  removeItems: removeItems,
                ),
              );
            },
          );

          final Disposable listener = rxSet.listen();
          expect(rxSource.value, <int>{1, 3, 4});
          expect(rxSet.value, <String>{'E1', 'E3', 'E4'});

          rxSource.add(5);
          expect(rxSource.value, <int>{1, 3, 4, 5});
          expect(rxSet.value, <String>{'E1', 'E3', 'E4', 'E5'});

          rxSource.remove(3);
          expect(rxSource.value, <int>{1, 4, 5});
          expect(rxSet.value, <String>{'E1', 'E4', 'E5'});

          rxSource.addAll(<int>[6, 7]);
          expect(rxSource.value, <int>{1, 4, 5, 6, 7});
          expect(rxSet.value, <String>{'E1', 'E4', 'E5', 'E6', 'E7'});

          rxSource.removeAll(<int>[1, 4]);
          expect(rxSource.value, <int>{5, 6, 7});
          expect(rxSet.value, <String>{'E5', 'E6', 'E7'});

          rxSource.clear();
          expect(rxSource.value, <int>{});
          expect(rxSet.value, <String>{});

          await listener.dispose();

          rxSource.addAll(<int>[1, 2, 3]);
          expect(rxSource.value, <int>{1, 2, 3});
          expect(rxSet.value, <String>{});

          rxSet.listen();
          expect(rxSet.value, <String>{'E1', 'E2', 'E3'});

          await rxSource.dispose();
          expect(rxSet.disposed, true);
        });
      });

      group('statefulSet', () {
        test('Should transform changes as a stateful set', () async {
          final RxSet<int> rxSource = RxSet<int>(initial: <int>{1, 2, 3});
          rxSource.add(4);
          rxSource.remove(2);

          final ObservableStatefulSet<String, String> rxSet = rxSource.transformChangeAs.statefulSet<String, String>(
            transform: (
              final ObservableStatefulSet<String, String> state,
              final Set<int> value,
              final ObservableSetChange<int> change,
              final Emitter<Either<ObservableSetUpdateAction<String>, String>> updater,
            ) {
              if (value.isEmpty) {
                updater(Either<ObservableSetUpdateAction<String>, String>.right('empty'));
                return;
              }
              // convert to E+index
              final Set<int> removedItems = change.removed;
              final Set<String> removeItems = <String>{};

              String mapItem(final int item) => 'E$item';

              for (final int item in removedItems) {
                removeItems.add(mapItem(item));
              }

              final Set<String> addedItems = change.added.map((final int item) => mapItem(item)).toSet();

              updater(
                Either<ObservableSetUpdateAction<String>, String>.left(
                  ObservableSetUpdateAction<String>(
                    addItems: addedItems,
                    removeItems: removeItems,
                  ),
                ),
              );
            },
          );

          final Disposable listener = rxSet.listen();
          expect(rxSource.value, <int>{1, 3, 4});
          expect(rxSet.value.leftOrThrow, <String>{'E1', 'E3', 'E4'});

          rxSource.add(5);
          expect(rxSource.value, <int>{1, 3, 4, 5});
          expect(rxSet.value.leftOrThrow, <String>{'E1', 'E3', 'E4', 'E5'});

          rxSource.remove(3);
          expect(rxSource.value, <int>{1, 4, 5});
          expect(rxSet.value.leftOrThrow, <String>{'E1', 'E4', 'E5'});

          rxSource.addAll(<int>[6, 7]);
          expect(rxSource.value, <int>{1, 4, 5, 6, 7});
          expect(rxSet.value.leftOrThrow, <String>{'E1', 'E4', 'E5', 'E6', 'E7'});

          rxSource.removeAll(<int>[1, 4]);
          expect(rxSource.value, <int>{5, 6, 7});
          expect(rxSet.value.leftOrThrow, <String>{'E5', 'E6', 'E7'});

          rxSource.clear();
          expect(rxSource.value, <int>{});
          expect(rxSet.value.rightOrThrow, 'empty');

          rxSource.addAll(<int>[1, 2, 3]);
          expect(rxSource.value, <int>{1, 2, 3});
          expect(rxSet.value.leftOrThrow, <String>{'E1', 'E2', 'E3'});

          await listener.dispose();

          rxSource.add(4);
          rxSource.remove(2);
          expect(rxSource.value, <int>{1, 3, 4});
          expect(rxSet.value.leftOrThrow, <String>{'E1', 'E2', 'E3'});

          rxSet.listen();
          expect(rxSet.value.leftOrThrow, <String>{'E1', 'E3', 'E4'});

          await rxSource.dispose();
          expect(rxSet.disposed, true);
        });
      });
    });
  });
}

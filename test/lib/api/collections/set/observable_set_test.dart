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
        expect(rxList.value.setView, <int>{0, 1, 2});

        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{3, 4}));
        expect(rxList.length, 5);
        expect(rxList.value.setView, <int>{0, 1, 2, 3, 4});

        controller.add(ObservableSetUpdateAction<int>(removeItems: <int>{0}));
        expect(rxList.length, 4);
        expect(rxList.value.setView, <int>{1, 2, 3, 4});

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
        expect(rxList.value.setView, <int>[0, 1, 2, 3]);
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
        expect(rxList.value.setView, <int>[3, 2, 1, 0]);
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
        expect(rxList.value.setView, <int>[-1]);

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
        expect(rxList.value.setView, <int>[0]);
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
        expect(rxList.value.setView, <int>[0]);

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
        expect(rxList.value.setView, <int>[0, 1, 2, 3]);

        await listener.dispose();

        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{4}));
        controller.add(ObservableSetUpdateAction<int>(addItems: <int>{5}));

        listener = rxList.listen();

        expect(rxList.length, 6);
        expect(rxList.value.setView, <int>[0, 1, 2, 3, 4, 5]);
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

    group('sorted', (){
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
  });
}

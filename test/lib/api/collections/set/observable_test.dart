import 'dart:collection';

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

import '../../../todo_item.dart';

void main() {
  group('ObservableSet', () {
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
    });

    group('mapItem', () {
      test('Should return a new ObservableSet with the items mapped by the given function', () async {
        final RxSet<TodoItem> rxSource = RxSet<TodoItem>();
        final ObservableSet<String> rxTitles = rxSource.mapItem<String>(
          (final TodoItem item) {
            return item.title;
          },
        );

        final Disposable listener = rxTitles.listen();

        final TodoItem item1 = TodoItem(
          id: '1',
          title: 'title1',
          description: 'description1',
          completed: false,
        );

        final TodoItem item2 = TodoItem(
          id: '2',
          title: 'title2',
          description: 'description2',
          completed: false,
        );

        rxSource.addAll(<TodoItem>[item1, item2]);

        expect(rxTitles.toList(), <String>['title1', 'title2']);

        rxSource.remove(item1);

        expect(rxTitles.toList(), <String>['title2']);

        await listener.dispose();

        rxSource.add(item1);

        expect(rxTitles.toList(), <String>['title2']);

        rxTitles.listen();

        expect(rxTitles.toList(), <String>['title2', 'title1']);

        await rxSource.dispose();
        expect(rxTitles.disposed, true);
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

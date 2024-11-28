import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxSet', () {
    group('value', () {
      test('Should return an unmodifiable view of the set', () {
        final RxSet<int> rx = RxSet<int>(initial: <int>{1, 2, 3});
        expect(rx.value, <int>{1, 2, 3});
        expect(() => rx.value.add(4), throwsUnsupportedError);
      });

      test('Should set new value', () {
        final RxSet<int> rx = RxSet<int>(initial: <int>{1, 2, 3});
        rx.value = <int>{2, 4, 6};

        expect(rx.value, <int>{2, 4, 6});
        final ObservableSetChange<int> change = rx.change;
        expect(change.added, <int>{4, 6});
        expect(change.removed, <int>{1, 3});

        // 2,4,6 -> 1,2,3
        rx.value = <int>{1, 2, 3};
        expect(rx.value, <int>{1, 2, 3});
        expect(rx.change.added, <int>{1, 3});
        expect(rx.change.removed, <int>{4, 6});

        // 1,2,3 -> 1,2,3,4
        rx.value = <int>{1, 2, 3, 4};
        expect(rx.value, <int>{1, 2, 3, 4});
        expect(rx.change.added, <int>{4});
        expect(rx.change.removed, <int>{});

        // 1,2,3,4 -> {}
        rx.value = <int>{};
        expect(rx.value, <int>{});
        expect(rx.change.added, <int>{});
        expect(rx.change.removed, <int>{1, 2, 3, 4});
      });
    });

    group('add', () {
      test('should add item', () {
        final RxSet<int> set = RxSet<int>(initial: <int>[1, 2, 3]);
        final ObservableSetChange<int>? change = set.add(4);

        expect(change, isNotNull);
        expect(change!.added, <int>{4});
        expect(change.removed, <int>{});

        expect(set.value, <int>{1, 2, 3, 4});
      });
    });

    group('addAll', () {
      test('should add items', () {
        final RxSet<int> set = RxSet<int>(initial: <int>[1, 2, 3]);
        final ObservableSetChange<int>? change = set.addAll(<int>[4, 5, 6]);

        expect(change, isNotNull);
        expect(change!.added, <int>{4, 5, 6});
        expect(change.removed, <int>{});

        expect(set.value, <int>{1, 2, 3, 4, 5, 6});
      });
    });

    group('clear', () {
      test('should clear items', () {
        final RxSet<int> set = RxSet<int>(initial: <int>[1, 2, 3]);
        final ObservableSetChange<int>? change = set.clear();

        expect(change, isNotNull);
        expect(change!.added, <int>{});
        expect(change.removed, <int>{1, 2, 3});

        expect(set.value, <int>{});
      });
    });

    group('remove', () {
      test('should remove item', () {
        final RxSet<int> set = RxSet<int>(initial: <int>[1, 2, 3]);
        final ObservableSetChange<int>? change = set.remove(2);

        expect(change, isNotNull);
        expect(change!.added, <int>{});
        expect(change.removed, <int>{2});

        expect(set.value, <int>{1, 3});
      });
    });

    group('removeWhere', () {
      test('should remove items', () {
        final RxSet<int> set = RxSet<int>(initial: <int>[1, 2, 3]);
        final ObservableSetChange<int>? change = set.removeWhere((final int item) => item.isOdd);

        expect(change, isNotNull);
        expect(change!.added, <int>{});
        expect(change.removed, <int>{1, 3});

        expect(set.value, <int>{2});
      });
    });

    group('setData', () {
      test('should set data', () {
        final RxSet<int> set = RxSet<int>(initial: <int>[1, 2, 3]);
        final ObservableSetChange<int>? change = set.setData(<int>{2, 4, 6});

        expect(change, isNotNull);
        expect(change!.added, <int>{4, 6});
        expect(change.removed, <int>{1, 3});

        expect(set.value, <int>{2, 4, 6});
      });

      test('Should use the existing factory', () {
        final RxSet<int> rxReversed = RxSet<int>.splayTreeSet(
          compare: (final int a, final int b) => b.compareTo(a),
          initial: <int>[1, 2, 3],
        );

        expect(rxReversed.toList(), <int>[3, 2, 1]);

        final ObservableSetChange<int>? change = rxReversed.setData(<int>{2, 1, 4, 6});

        expect(change, isNotNull);
        expect(change!.added, <int>{4, 6});
        expect(change.removed, <int>{3});
        expect(rxReversed.toList(), <int>[6, 4, 2, 1]);
      });
    });

    group('set value', () {
      test('should set value', () {
        final RxSet<int> rxSet = RxSet<int>(initial: <int>[1, 2, 3]);
        rxSet.value = <int>{2, 4, 6};

        expect(rxSet.value, <int>{2, 4, 6});
        final ObservableSetChange<int> change = rxSet.change;

        expect(change.added, <int>{4, 6});
        expect(change.removed, <int>{1, 3});
      });
    });
  });
}

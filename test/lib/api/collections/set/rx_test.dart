import 'package:dart_observable/dart_observable.dart';
import 'package:dart_observable/src/core/collections/set/set_state.dart';
import 'package:test/test.dart';

void main() {
  group('RxSet', () {
    group('add', () {
      test('should add item', () {
        final RxSet<int> set = RxSet<int>(<int>[1, 2, 3]);
        final ObservableSetChange<int>? change = set.add(4);

        expect(change, isNotNull);
        expect(change!.added, <int>{4});
        expect(change.removed, <int>{});

        expect(set.value.setView, <int>{1, 2, 3, 4});
      });
    });

    group('addAll', () {
      test('should add items', () {
        final RxSet<int> set = RxSet<int>(<int>[1, 2, 3]);
        final ObservableSetChange<int>? change = set.addAll(<int>[4, 5, 6]);

        expect(change, isNotNull);
        expect(change!.added, <int>{4, 5, 6});
        expect(change.removed, <int>{});

        expect(set.value.setView, <int>{1, 2, 3, 4, 5, 6});
      });
    });

    group('clear', () {
      test('should clear items', () {
        final RxSet<int> set = RxSet<int>(<int>[1, 2, 3]);
        final ObservableSetChange<int>? change = set.clear();

        expect(change, isNotNull);
        expect(change!.added, <int>{});
        expect(change.removed, <int>{1, 2, 3});

        expect(set.value.setView, <int>{});
      });
    });

    group('remove', () {
      test('should remove item', () {
        final RxSet<int> set = RxSet<int>(<int>[1, 2, 3]);
        final ObservableSetChange<int>? change = set.remove(2);

        expect(change, isNotNull);
        expect(change!.added, <int>{});
        expect(change.removed, <int>{2});

        expect(set.value.setView, <int>{1, 3});
      });
    });

    group('removeWhere', () {
      test('should remove items', () {
        final RxSet<int> set = RxSet<int>(<int>[1, 2, 3]);
        final ObservableSetChange<int>? change = set.removeWhere((final int item) => item.isOdd);

        expect(change, isNotNull);
        expect(change!.added, <int>{});
        expect(change.removed, <int>{1, 3});

        expect(set.value.setView, <int>{2});
      });
    });

    group('setData', () {
      test('should set data', () {
        final RxSet<int> set = RxSet<int>(<int>[1, 2, 3]);
        final ObservableSetChange<int>? change = set.setData(<int>{2, 4, 6});

        expect(change, isNotNull);
        expect(change!.added, <int>{4, 6});
        expect(change.removed, <int>{1, 3});

        expect(set.value.setView, <int>{2, 4, 6});
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
        final RxSet<int> rxSet = RxSet<int>(<int>[1, 2, 3]);
        rxSet.value = RxSetState<int>.initial(<int>{2, 4, 6});

        expect(rxSet.value.setView, <int>{2, 4, 6});
        final ObservableSetChange<int> change = rxSet.value.lastChange;

        expect(change.added, <int>{4, 6});
        expect(change.removed, <int>{1, 3});
      });
    });
  });
}

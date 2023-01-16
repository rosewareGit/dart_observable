import 'package:dart_observable/dart_observable.dart';
import 'package:dart_observable/src/api/collections/list/change.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableListChange', () {
    group('fromAdded', () {
      test('Should return an ObservableListChange instance with added items', () {
        final List<int> state = <int>[1, 2, 3];
        final ObservableListChange<int> change = ObservableListChange<int>.fromAdded(
          state,
          <MapEntry<int?, Iterable<int>>>[
            MapEntry<int?, Iterable<int>>(null, <int>[4, 5]),
            MapEntry<int?, Iterable<int>>(1, <int>[6, 7]),
            MapEntry<int?, Iterable<int>>(10, <int>[10]),
          ],
        );

        expect(change.added, <int, int>{
          5: 4,
          6: 5,
          1: 6,
          2: 7,
          7: 10,
        });
        expect(change.removed, <int, int>{});
        expect(change.updated, <int, ObservableItemChange<int>>{});

        expect(state, <int>[1, 6, 7, 2, 3, 4, 5, 10]);
      });
    });

    group('fromRemoved', () {
      test('Should return an ObservableListChange instance with removed items', () {
        final List<int> state = <int>[1, 2, 3];
        final ObservableListChange<int> change = ObservableListChange<int>.fromRemoved(
          state,
          <int>{0, 2},
        );

        expect(change.added, <int, int>{});
        expect(change.removed, <int, int>{
          0: 1,
          2: 3,
        });
        expect(change.updated, <int, ObservableItemChange<int>>{});

        expect(state, <int>[2]);
      });
    });

    group('fromUpdated', () {
      test('Should return an ObservableListChange instance with updated items', () {
        final List<int> state = <int>[1, 2, 3];
        final ObservableListChange<int> change = ObservableListChange<int>.fromUpdated(
          state,
          <int, int>{
            0: 4,
            2: 5,
            3: 6,
          },
        );

        expect(change.added, <int, int>{
          3: 6,
        });
        expect(change.removed, <int, int>{});
        expect(change.updated, <int, ObservableItemChange<int>>{
          0: ObservableItemChange<int>(oldValue: 1, newValue: 4),
          2: ObservableItemChange<int>(oldValue: 3, newValue: 5),
        });

        expect(state, <int>[4, 2, 5, 6]);
      });
    });

    group('isEmpty', () {
      test('Should return true when there are no added, removed or updated items', () {
        final ObservableListChange<int> change = ObservableListChange<int>();
        expect(change.isEmpty, true);
      });

      test('Should return false when there are added items', () {
        final ObservableListChange<int> change = ObservableListChange<int>.fromAdded(
          <int>[],
          <MapEntry<int?, Iterable<int>>>[
            MapEntry<int?, Iterable<int>>(null, <int>[1]),
          ],
        );
        expect(change.isEmpty, false);
      });

      test('Should return false when there are removed items', () {
        final ObservableListChange<int> change = ObservableListChange<int>.fromRemoved(
          <int>[1],
          <int>{0},
        );
        expect(change.isEmpty, false);
      });

      test('Should return false when there are updated items', () {
        final ObservableListChange<int> change = ObservableListChange<int>.fromUpdated(
          <int>[1],
          <int, int>{
            0: 2,
          },
        );
        expect(change.isEmpty, false);
      });
    });
  });
}

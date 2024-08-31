import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableListUpdateAction', () {
    group('fromChange', () {
      test('Should return an ObservableListUpdateAction instance with added items', () {
        final ObservableListChange<int> change = ObservableListChange<int>(
          added: <int, int>{
            1: 4,
            2: 5,
          },
        );
        final ObservableListUpdateAction<int> action = ObservableListUpdateAction<int>.fromChange(change);
        final MapEntry<int?, Iterable<int>> insert = action.insertItemAtPosition.first;
        expect(insert.key, null);
        expect(insert.value, <int>[4, 5]);

        expect(action.removeIndexes, <int>{});
        expect(action.updateItemAtPosition, <int, int>{});
      });

      test('Should return an ObservableListUpdateAction instance with removed items', () {
        final ObservableListChange<int> change = ObservableListChange<int>(
          removed: <int, int>{
            0: 1,
            2: 3,
          },
        );
        final ObservableListUpdateAction<int> action = ObservableListUpdateAction<int>.fromChange(change);
        final MapEntry<int?, Iterable<int>> insert = action.insertItemAtPosition.first;
        expect(insert.key, null);
        expect(insert.value, <int>[]);

        expect(action.removeIndexes, <int>{0, 2});
        expect(action.updateItemAtPosition, <int, int>{});
      });

      test('Should return an ObservableListUpdateAction instance with updated items', () {
        final ObservableListChange<int> change = ObservableListChange<int>(
          updated: <int, ObservableItemChange<int>>{
            0: ObservableItemChange<int>(
              oldValue: 1,
              newValue: 4,
            ),
            2: ObservableItemChange<int>(
              oldValue: 3,
              newValue: 5,
            ),
          },
        );
        final ObservableListUpdateAction<int> action = ObservableListUpdateAction<int>.fromChange(change);
        final MapEntry<int?, Iterable<int>> insert = action.insertItemAtPosition.first;
        expect(insert.key, null);
        expect(insert.value, <int>[]);

        expect(action.removeIndexes, <int>{});
        expect(action.updateItemAtPosition, <int, int>{0: 4, 2: 5});
      });

      test('Should return an ObservableListUpdateAction instance with added, removed and updated items', () {
        final ObservableListChange<int> change = ObservableListChange<int>(
          added: <int, int>{
            1: 4,
            2: 5,
          },
          removed: <int, int>{
            0: 1,
            2: 3,
          },
          updated: <int, ObservableItemChange<int>>{
            0: ObservableItemChange<int>(
              oldValue: 1,
              newValue: 4,
            ),
            2: ObservableItemChange<int>(
              oldValue: 3,
              newValue: 5,
            ),
          },
        );
        final ObservableListUpdateAction<int> action = ObservableListUpdateAction<int>.fromChange(change);
        final MapEntry<int?, Iterable<int>> insert = action.insertItemAtPosition.first;
        expect(insert.key, null);
        expect(insert.value, <int>[4, 5]);

        expect(action.removeIndexes, <int>{0, 2});
        expect(action.updateItemAtPosition, <int, int>{0: 4, 2: 5});
      });
    });

    group('apply', () {
      test('Should return empty change when action is empty', () {
        final List<int> state = <int>[1, 2, 3];
        final ObservableListUpdateAction<int> action = ObservableListUpdateAction<int>();
        final ObservableListChange<int> change = action.apply(state);
        expect(change.isEmpty, true);
      });

      test('Should return an ObservableListChange instance with added items', () {
        final List<int> state = <int>[1, 2, 3];
        final ObservableListUpdateAction<int> action = ObservableListUpdateAction<int>.add(
          <MapEntry<int?, Iterable<int>>>[
            MapEntry<int?, Iterable<int>>(null, <int>[4, 5]),
            MapEntry<int?, Iterable<int>>(1, <int>[6, 7]),
            MapEntry<int?, Iterable<int>>(10, <int>[10]),
          ],
        );
        final ObservableListChange<int> change = action.apply(state);
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

      test('Should return an ObservableListChange instance with removed items', () {
        final List<int> state = <int>[1, 2, 3];
        final ObservableListUpdateAction<int> action = ObservableListUpdateAction<int>.remove(
          <int>{0, 2},
        );
        final ObservableListChange<int> change = action.apply(state);

        expect(change.added, <int, int>{});
        expect(change.removed, <int, int>{
          0: 1,
          2: 3,
        });
        expect(change.updated, <int, ObservableItemChange<int>>{});

        expect(state, <int>[2]);
      });

      test('Should return an ObservableListChange instance with updated items', () {
        final List<int> state = <int>[1, 2, 3];
        final ObservableListUpdateAction<int> action = ObservableListUpdateAction<int>.update(
          <int, int>{
            0: 4,
            2: 5,
            3: 6,
          },
        );
        final ObservableListChange<int> change = action.apply(state);

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
        final ObservableListUpdateAction<int> action = ObservableListUpdateAction<int>();
        expect(action.isEmpty, true);
      });

      test('Should return false when there are added items', () {
        final ObservableListUpdateAction<int> action = ObservableListUpdateAction<int>.add(
          <MapEntry<int?, Iterable<int>>>[
            MapEntry<int?, Iterable<int>>(null, <int>[1]),
          ],
        );
        expect(action.isEmpty, false);
      });

      test('Should return false when there are removed items', () {
        final ObservableListUpdateAction<int> action = ObservableListUpdateAction<int>.remove(
          <int>{0},
        );
        expect(action.isEmpty, false);
      });

      test('Should return false when there are updated items', () {
        final ObservableListUpdateAction<int> action = ObservableListUpdateAction<int>.update(
          <int, int>{
            0: 2,
          },
        );
        expect(action.isEmpty, false);
      });
    });
  });
}

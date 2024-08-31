import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableListChange', () {
    group('isEmpty', () {
      test('Should return true if all maps are empty', () {
        final ObservableListChange<int> change = ObservableListChange<int>();
        expect(change.isEmpty, true);
      });

      test('Should return false when added is not empty', () {
        final ObservableListChange<int> change = ObservableListChange<int>(
          added: <int, int>{1: 1},
        );
        expect(change.isEmpty, false);
      });

      test('Should return false when removed is not empty', () {
        final ObservableListChange<int> change = ObservableListChange<int>(
          removed: <int, int>{1: 1},
        );
        expect(change.isEmpty, false);
      });

      test('Should return false when updated is not empty', () {
        final ObservableListChange<int> change = ObservableListChange<int>(
          updated: <int, ObservableItemChange<int>>{
            1: ObservableItemChange<int>(
              oldValue: 1,
              newValue: 2,
            ),
          },
        );
        expect(change.isEmpty, false);
      });
    });

    group('fromDiff', () {
      test('Should return an ObservableListChange with added items', () {
        final ObservableListChange<int> change = ObservableListChange<int>.fromDiff(
          <int>[1, 2, 3],
          <int>[1, 2, 3, 4],
        );
        expect(change.added, <int, int>{3: 4});
      });

      test('Should return an ObservableListChange with removed items', () {
        final ObservableListChange<int> change = ObservableListChange<int>.fromDiff(
          <int>[1, 2, 3],
          <int>[1],
        );
        expect(change.removed, <int, int>{1: 2, 2: 3});
      });

      test('Should return an ObservableListChange with updated items', () {
        final ObservableListChange<int> change = ObservableListChange<int>.fromDiff(
          <int>[1, 2, 3],
          <int>[1, 4, 3],
        );
        expect(change.updated, <int, ObservableItemChange<int>>{
          1: ObservableItemChange<int>(
            oldValue: 2,
            newValue: 4,
          ),
        });
      });

      test('Should return complex change', () {
        final ObservableListChange<int> change = ObservableListChange<int>.fromDiff(
          <int>[1, 2, 3, 4, 5],
          <int>[1, 4, 3, 6],
        );
        expect(change.added, <int, int>{});
        expect(change.removed, <int, int>{4: 5});
        expect(change.updated, <int, ObservableItemChange<int>>{
          1: ObservableItemChange<int>(
            oldValue: 2,
            newValue: 4,
          ),
          3: ObservableItemChange<int>(
            oldValue: 4,
            newValue: 6,
          ),
        });
      });
    });
  });
}

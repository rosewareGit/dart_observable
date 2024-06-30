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
  });
}

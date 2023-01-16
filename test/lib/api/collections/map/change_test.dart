import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableMapChange', () {
    group('fromAction', () {
      test('Should return the diff and update the state in place', () {
        final Map<String, int> state = <String, int>{
          'a': 1,
          'b': 2,
        };
        final ObservableMapChange<String, int> change = ObservableMapChange.fromAction<String, int>(
          state: state,
          addItems: <String, int>{
            'a': 2,
            'c': 3,
          },
          removeItems: <String>['b'],
        );
        expect(change.added, <String, int>{
          'c': 3,
        });
        expect(change.updated, <String, ObservableItemChange<int>>{
          'a': ObservableItemChange<int>(
            oldValue: 1,
            newValue: 2,
          ),
        });
        expect(change.removed, <String, int>{
          'b': 2,
        });
        expect(state, <String, int>{
          'a': 2,
          'c': 3,
        });
      });
    });

    group('fromDiff', () {
      test('Should properly return the difference', () {
        final Map<String, int> previous = <String, int>{
          'a': 1,
          'b': 2,
          'c': 3,
        };

        final ObservableMapChange<String, int> change = ObservableMapChange<String, int>.fromDiff(
          previous,
          <String, int>{
            'a': 2,
            'b': 2,
            'd': 4,
          },
        );

        expect(change.added, <String, int>{
          'd': 4,
        });
        expect(change.updated, <String, ObservableItemChange<int>>{
          'a': ObservableItemChange<int>(
            oldValue: 1,
            newValue: 2,
          ),
        });
        expect(change.removed, <String, int>{
          'c': 3,
        });
      });
    });
  });
}

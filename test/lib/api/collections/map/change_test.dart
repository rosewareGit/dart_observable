import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableMapChange', () {
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

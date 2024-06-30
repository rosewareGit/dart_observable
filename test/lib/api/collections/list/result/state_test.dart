import 'dart:collection';

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group(('ObservableListResultChange'), () {
    group('when', () {
      test('Should call undefined function when set', () {
        final ObservableListResultChangeUndefined<int, int> change = ObservableListResultChangeUndefined<int, int>();
        bool called = false;
        change.when(
          onUndefined: (final _) {
            called = true;
          },
        );
        expect(called, true);
      });

      test('Should do nothing when undefined function is not set', () {
        final ObservableListResultChangeUndefined<int, int> change = ObservableListResultChangeUndefined<int, int>();
        change.when();
      });

      test('Should call failure function when set', () {
        final ObservableListResultChangeFailure<int, int> change =
            ObservableListResultChangeFailure<int, int>(failure: 1);
        bool called = false;
        change.when(
          onFailure: (final _, final __) {
            called = true;
          },
        );
        expect(called, true);
      });

      test('Should do nothing when failure function is not set', () {
        final ObservableListResultChangeFailure<int, int> change =
            ObservableListResultChangeFailure<int, int>(failure: 1);
        change.when();
      });

      test('Should call success function when set', () {
        final ObservableListResultChangeData<int, int> change = ObservableListResultChangeData<int, int>(
          change: ObservableListChange<int>(),
          data: UnmodifiableListView<int>(<int>[]),
        );
        bool called = false;
        change.when(
          onSuccess: (final _, final __) {
            called = true;
          },
        );
        expect(called, true);
      });

      test('Should do nothing when success function is not set', () {
        final ObservableListResultChangeData<int, int> change = ObservableListResultChangeData<int, int>(
          change: ObservableListChange<int>(),
          data: UnmodifiableListView<int>(<int>[]),
        );
        change.when();
      });
    });
  });
}

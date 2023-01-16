import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxSetResult', () {
    group('set value', () {
      group('data -> data', () {
        test('Should calculate the diff', () {
          final RxSetResult<int, String> result = RxSetResult<int, String>(
            initial: <int>{1, 2},
          );
          int updateCount = 0;
          result.listen(
            onChange: (final Observable<ObservableSetResultState<int, String>> source) {
              updateCount++;
            },
          );

          result.value = ObservableSetResultState<int, String>.data(
            data: <int>{2, 3, 4},
            change: ObservableSetChange<int>(
              added: <int>{2, 3, 4},
            ),
          );

          expect(result.value is ObservableSetResultStateData, true);
          final ObservableSetResultStateData<int, String> state =
              result.value as ObservableSetResultStateData<int, String>;
          expect(state.data, <int>{2, 3, 4});
          expect(state.change.added, <int>{3, 4});
          expect(state.change.removed, <int>{1});
          expect(updateCount, 1);
        });
      });
    });

    group('set data', () {
      test('Should calculate the diff', () {
        final RxSetResult<int, String> result = RxSetResult<int, String>(
          initial: <int>{1, 2},
        );
        int updateCount = 0;
        result.listen(
          onChange: (final Observable<ObservableSetResultState<int, String>> source) {
            updateCount++;
          },
        );

        result.data = <int>{2, 3, 4};

        expect(result.value is ObservableSetResultStateData, true);
        expect((result.value as ObservableSetResultStateData<int, String>).data, <int>{2, 3, 4});
        expect((result.value as ObservableSetResultStateData<int, String>).change.added, <int>{3, 4});
        expect((result.value as ObservableSetResultStateData<int, String>).change.removed, <int>{1});
        expect(updateCount, 1);
      });
    });
  });

  group('custom factory', () {
    test('Should create custom data', () {
      final RxSetResult<int, String> rxNumbers = RxSetResult<int, String>.splayTreeSet(
        initial: <int>{5, 4, 2},
        compare: (final int a, final int b) => a.compareTo(b),
      );
      expect((rxNumbers.value as ObservableSetResultStateData<int, String>).data.toList(), <int>[2, 4, 5]);

      rxNumbers.add(3);
      expect((rxNumbers.value as ObservableSetResultStateData<int, String>).data.toList(), <int>[2, 3, 4, 5]);

      rxNumbers.remove(4);
      expect((rxNumbers.value as ObservableSetResultStateData<int, String>).data.toList(), <int>[2, 3, 5]);

      rxNumbers.addAll(<int>{1, 6});

      expect((rxNumbers.value as ObservableSetResultStateData<int, String>).data.toList(), <int>[1, 2, 3, 5, 6]);
    });
  });

  group('applyAction', () {
    test('Undefined -> undefined: no change', () {
      final RxSetResult<int, String> result = RxSetResult<int, String>.undefined();
      int updateCount = 0;
      result.listen(
        onChange: (final Observable<ObservableSetResultState<int, String>> source) {
          updateCount++;
        },
      );

      result.applyAction(
        ObservableSetResultUpdateActionUndefined<int, String>(),
      );

      expect(result.value is ObservableSetResultStateUndefined, true);
      expect(updateCount, 0);
    });

    test('Undefined -> failure: change', () {
      final RxSetResult<int, String> result = RxSetResult<int, String>.undefined();
      int updateCount = 0;
      result.listen(
        onChange: (final Observable<ObservableSetResultState<int, String>> source) {
          updateCount++;
        },
      );

      result.applyAction(
        ObservableSetResultUpdateActionFailure<int, String>(
          failure: 'failure',
        ),
      );

      expect(result.value is ObservableSetResultStateFailure, true);
      expect((result.value as ObservableSetResultStateFailure<int, String>).failure, 'failure');
      expect(updateCount, 1);
    });

    test('Undefined -> data: change', () {
      final RxSetResult<int, String> result = RxSetResult<int, String>.undefined();
      int updateCount = 0;
      result.listen(
        onChange: (final Observable<ObservableSetResultState<int, String>> source) {
          updateCount++;
        },
      );

      result.applyAction(
        ObservableSetResultUpdateActionData<int, String>(
          addItems: <int>{1, 2},
          removeItems: <int>{3, 4},
        ),
      );

      expect(result.value is ObservableSetResultStateData, true);
      expect(updateCount, 1);
    });

    test('Failure -> undefined: change', () {
      final RxSetResult<int, String> result = RxSetResult<int, String>.failure(failure: 'failure');
      int updateCount = 0;
      result.listen(
        onChange: (final Observable<ObservableSetResultState<int, String>> source) {
          updateCount++;
        },
      );

      result.applyAction(
        ObservableSetResultUpdateActionUndefined<int, String>(),
      );

      expect(result.value is ObservableSetResultStateUndefined, true);
      expect(updateCount, 1);
    });

    test('Failure -> failure: to same failure', () {
      final RxSetResult<int, String> result = RxSetResult<int, String>.failure(failure: 'failure');
      int updateCount = 0;
      result.listen(
        onChange: (final Observable<ObservableSetResultState<int, String>> source) {
          updateCount++;
        },
      );

      result.applyAction(
        ObservableSetResultUpdateActionFailure<int, String>(
          failure: 'failure',
        ),
      );

      expect(result.value is ObservableSetResultStateFailure, true);
      expect((result.value as ObservableSetResultStateFailure<int, String>).failure, 'failure');
      expect(updateCount, 0);
    });

    test('Failure -> failure: different failure', () {
      final RxSetResult<int, String> result = RxSetResult<int, String>.failure(failure: 'failure');
      int updateCount = 0;
      result.listen(
        onChange: (final Observable<ObservableSetResultState<int, String>> source) {
          updateCount++;
        },
      );

      result.applyAction(
        ObservableSetResultUpdateActionFailure<int, String>(
          failure: 'failure2',
        ),
      );

      expect(result.value is ObservableSetResultStateFailure, true);
      expect((result.value as ObservableSetResultStateFailure<int, String>).failure, 'failure2');
      expect(updateCount, 1);
    });

    test('Failure -> data: change', () {
      final RxSetResult<int, String> result = RxSetResult<int, String>.failure(failure: 'failure');
      int updateCount = 0;
      result.listen(
        onChange: (final Observable<ObservableSetResultState<int, String>> source) {
          updateCount++;
        },
      );

      result.applyAction(
        ObservableSetResultUpdateActionData<int, String>(
          addItems: <int>{1, 2},
          removeItems: <int>{3, 4},
        ),
      );

      expect(result.value is ObservableSetResultStateData, true);
      expect(updateCount, 1);
    });

    test('Data -> undefined: change', () {
      final RxSetResult<int, String> result = RxSetResult<int, String>(
        initial: <int>{1, 2},
      );
      int updateCount = 0;
      result.listen(
        onChange: (final Observable<ObservableSetResultState<int, String>> source) {
          updateCount++;
        },
      );

      result.applyAction(
        ObservableSetResultUpdateActionUndefined<int, String>(),
      );

      expect(result.value is ObservableSetResultStateUndefined, true);
      expect((result.value as ObservableSetResultStateUndefined<int, String>).removedItems, <int>{1, 2});
      expect(updateCount, 1);
    });

    test('Data -> failure: change', () {
      final RxSetResult<int, String> result = RxSetResult<int, String>(
        initial: <int>{1, 2},
      );
      int updateCount = 0;
      result.listen(
        onChange: (final Observable<ObservableSetResultState<int, String>> source) {
          updateCount++;
        },
      );

      result.applyAction(
        ObservableSetResultUpdateActionFailure<int, String>(
          failure: 'failure',
        ),
      );

      expect(result.value is ObservableSetResultStateFailure, true);
      expect((result.value as ObservableSetResultStateFailure<int, String>).failure, 'failure');
      expect((result.value as ObservableSetResultStateFailure<int, String>).removedItems, <int>{1, 2});
      expect(updateCount, 1);
    });

    test('Data -> data: change', () {
      final RxSetResult<int, String> result = RxSetResult<int, String>(
        initial: <int>{1, 2},
      );
      int updateCount = 0;
      result.listen(
        onChange: (final Observable<ObservableSetResultState<int, String>> source) {
          updateCount++;
        },
      );

      result.applyAction(
        ObservableSetResultUpdateActionData<int, String>(
          addItems: <int>{3, 4},
          removeItems: <int>{1, 5},
        ),
      );

      final ObservableSetResultStateData<int, String> stateData =
          result.value as ObservableSetResultStateData<int, String>;
      expect(stateData.data, <int>{2, 3, 4});
      expect(stateData.change.added, <int>{3, 4});
      expect(stateData.change.removed, <int>{1});
      expect(updateCount, 1);
    });
  });
}

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxSetUndefinedFailure', () {
    group('failure', () {
      test('Should set failure', () {
        final RxSetUndefinedFailure<int, String> rxSetFailure = RxSetUndefinedFailure<int, String>();
        rxSetFailure.failure = 'failure';
        expect(rxSetFailure.value.custom, UndefinedFailure<String>.failure('failure'));
      });
    });

    group('applyAction', () {
      test('Should apply data action', () {
        final RxSetUndefinedFailure<int, String> rxSetFailure =
            RxSetUndefinedFailure<int, String>(initial: <int>[1, 2, 3]);
        final StateOf<ObservableSetUpdateAction<int>, UndefinedFailure<String>> action =
            StateOf<ObservableSetUpdateAction<int>, UndefinedFailure<String>>.data(
          ObservableSetUpdateAction<int>(
            removeItems: <int>{1},
            addItems: <int>{1000},
          ),
        );

        final StateOf<ObservableSetChange<int>, UndefinedFailure<String>>? result = rxSetFailure.applyAction(action);
        expect(result!.data!.added, <int>{1000});
        expect(result.data!.removed, <int>{1});
      });

      test('Should apply failure action', () {
        final RxSetUndefinedFailure<int, String> rxSetFailure =
            RxSetUndefinedFailure<int, String>(initial: <int>[1, 2, 3]);
        final StateOf<ObservableSetUpdateAction<int>, UndefinedFailure<String>> action =
            StateOf<ObservableSetUpdateAction<int>, UndefinedFailure<String>>.custom(
                UndefinedFailure<String>.failure('failure'));

        final StateOf<ObservableSetChange<int>, UndefinedFailure<String>>? result = rxSetFailure.applyAction(action);
        expect(result!.custom, UndefinedFailure<String>.failure('failure'));
      });
    });

    group('applySetUpdateAction', () {
      test('Should apply data action', () {
        final RxSetUndefinedFailure<int, String> rxSetFailure =
            RxSetUndefinedFailure<int, String>(initial: <int>[1, 2, 3]);
        final ObservableSetUpdateAction<int> action = ObservableSetUpdateAction<int>(
          removeItems: <int>{1},
          addItems: <int>{1000},
        );

        final ObservableSetChange<int>? change = rxSetFailure.applySetUpdateAction(action);
        expect(change!.added, <int>{1000});
        expect(change.removed, <int>{1});
      });
    });

    group('setState', () {
      test('Should set state', () {
        final RxSetUndefinedFailure<int, String> rxSetFailure =
            RxSetUndefinedFailure<int, String>(initial: <int>[1, 2, 3]);
        final StateOf<ObservableSetChange<int>, UndefinedFailure<String>>? result =
            rxSetFailure.setState(UndefinedFailure<String>.failure('state'));
        expect(rxSetFailure.value.custom, UndefinedFailure<String>.failure('state'));
        expect(result!.custom, UndefinedFailure<String>.failure('state'));

        final StateOf<ObservableSetChange<int>, UndefinedFailure<String>>? result2 =
            rxSetFailure.setState(UndefinedFailure<String>.failure('state2'));
        expect(rxSetFailure.value.custom, UndefinedFailure<String>.failure('state2'));
        expect(result2!.custom, UndefinedFailure<String>.failure('state2'));
      });
    });

    group('asObservable', () {
      test('Should return the same instance but with observable type', () {
        final RxSetUndefinedFailure<int, String> rxSetFailure =
            RxSetUndefinedFailure<int, String>(initial: <int>[1, 2, 3]);
        final ObservableSetUndefinedFailure<int, String> observableSet = rxSetFailure.asObservable();
        expect(observableSet, rxSetFailure);
      });
    });

    group('add', () {
      test('Should add value', () {
        final RxSetUndefinedFailure<int, String> rxSetFailure =
            RxSetUndefinedFailure<int, String>(initial: <int>[1, 2, 3]);
        rxSetFailure.add(100);
        expect(rxSetFailure.value.data!.setView, <int>[1, 2, 3, 100]);

        rxSetFailure.failure = 'failure';
        rxSetFailure.add(1000);

        expect(rxSetFailure.value.data!.setView, <int>[1000]);
      });
    });

    group('addAll', () {
      test('Should add all values', () {
        final RxSetUndefinedFailure<int, String> rxSetFailure =
            RxSetUndefinedFailure<int, String>(initial: <int>[1, 2, 3]);
        rxSetFailure.addAll(<int>[100, 101]);
        expect(rxSetFailure.value.data!.setView, <int>[1, 2, 3, 100, 101]);

        rxSetFailure.failure = 'failure';
        rxSetFailure.addAll(<int>[1000, 1001]);

        expect(rxSetFailure.value.data!.setView, <int>[1000, 1001]);
      });
    });

    group('clear', () {
      test('Should clear values', () {
        final RxSetUndefinedFailure<int, String> rxSetFailure =
            RxSetUndefinedFailure<int, String>(initial: <int>[1, 2, 3]);
        rxSetFailure.clear();
        expect(rxSetFailure.value.data!.setView, <int>[]);

        rxSetFailure.failure = 'failure';
        rxSetFailure.clear();

        expect(rxSetFailure.value.data!.setView, <int>[]);
      });
    });

    group('remove', () {
      test('Should remove value', () {
        final RxSetUndefinedFailure<int, String> rxSetFailure =
            RxSetUndefinedFailure<int, String>(initial: <int>[1, 2, 3]);
        rxSetFailure.remove(2);
        expect(rxSetFailure.value.data!.setView, <int>[1, 3]);

        rxSetFailure.failure = 'failure';
        rxSetFailure.remove(3);

        expect(rxSetFailure.value.data!.setView, <int>[]);
      });
    });

    group('removeWhere', () {
      test('Should remove values where predicate is true', () {
        final RxSetUndefinedFailure<int, String> rxSetFailure =
            RxSetUndefinedFailure<int, String>(initial: <int>[1, 2, 3]);
        rxSetFailure.removeWhere((final int item) => item == 2);
        expect(rxSetFailure.value.data!.setView, <int>[1, 3]);

        rxSetFailure.failure = 'failure';
        rxSetFailure.removeWhere((final int item) => item == 3);

        expect(rxSetFailure.value.data!.setView, <int>[]);
      });
    });

    group('setData', () {
      test('Should set data', () {
        final RxSetUndefinedFailure<int, String> rxSetFailure =
            RxSetUndefinedFailure<int, String>(initial: <int>[1, 2, 3]);
        final ObservableSetChange<int>? change = rxSetFailure.setData(<int>{100, 101});
        expect(rxSetFailure.value.data!.setView, <int>{100, 101});
        expect(change!.added, <int>{100, 101});
        expect(change.removed, <int>{1, 2, 3});

        rxSetFailure.failure = 'failure';
        expect(rxSetFailure.value.data, null);

        rxSetFailure.setData(<int>{1000, 1001});
        expect(rxSetFailure.value.data!.setView, <int>{1000, 1001});

        final ObservableSetChange<int>? change2 = rxSetFailure.setData(<int>{1001, 1002, 1003});
        expect(rxSetFailure.value.data!.setView, <int>{1001, 1002, 1003});
        expect(change2!.added, <int>{1002, 1003});
        expect(change2.removed, <int>{1000});
      });
    });
  });
}

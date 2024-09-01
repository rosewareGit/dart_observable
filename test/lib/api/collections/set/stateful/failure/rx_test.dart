import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxSetFailure', () {
    group('factory', (){
      test('Should create with initial failure', (){
        final RxSetFailure<int, String> set = RxSetFailure<int, String>.failure(failure: 'failure');
        expect(set.value.custom, 'failure');
      });
    });

    group('failure', () {
      test('Should set failure', () {
        final RxSetFailure<int, String> rxSetFailure = RxSetFailure<int, String>();
        rxSetFailure.failure = 'failure';
        expect(rxSetFailure.value.custom, 'failure');
      });
    });

    group('applyAction', () {
      test('Should apply data action', () {
        final RxSetFailure<int, String> rxSetFailure = RxSetFailure<int, String>(initial: <int>[1, 2, 3]);
        final StateOf<ObservableSetUpdateAction<int>, String> action =
            StateOf<ObservableSetUpdateAction<int>, String>.data(
          ObservableSetUpdateAction<int>(
            removeItems: <int>{1},
            addItems: <int>{1000},
          ),
        );

        final StateOf<ObservableSetChange<int>, String>? result = rxSetFailure.applyAction(action);
        expect(result!.data!.added, <int>{1000});
        expect(result.data!.removed, <int>{1});
      });

      test('Should apply failure action', () {
        final RxSetFailure<int, String> rxSetFailure = RxSetFailure<int, String>(initial: <int>[1, 2, 3]);
        final StateOf<ObservableSetUpdateAction<int>, String> action =
            StateOf<ObservableSetUpdateAction<int>, String>.custom('failure');

        final StateOf<ObservableSetChange<int>, String>? result = rxSetFailure.applyAction(action);
        expect(result!.custom, 'failure');
      });
    });

    group('applySetUpdateAction', () {
      test('Should apply data action', () {
        final RxSetFailure<int, String> rxSetFailure = RxSetFailure<int, String>(initial: <int>[1, 2, 3]);
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
        final RxSetFailure<int, String> rxSetFailure = RxSetFailure<int, String>(initial: <int>[1, 2, 3]);
        final StateOf<ObservableSetChange<int>, String>? result = rxSetFailure.setState('state');
        expect(rxSetFailure.value.custom, 'state');
        expect(result!.custom, 'state');

        final StateOf<ObservableSetChange<int>, String>? result2 = rxSetFailure.setState('state2');
        expect(rxSetFailure.value.custom, 'state2');
        expect(result2!.custom, 'state2');
      });
    });

    group('asObservable', () {
      test('Should return the same instance but with observable type', () {
        final RxSetFailure<int, String> rxSetFailure = RxSetFailure<int, String>(initial: <int>[1, 2, 3]);
        final ObservableSetFailure<int, String> observableSet = rxSetFailure.asObservable();
        expect(observableSet, rxSetFailure);
      });
    });

    group('add', () {
      test('Should add value', () {
        final RxSetFailure<int, String> rxSetFailure = RxSetFailure<int, String>(initial: <int>[1, 2, 3]);
        rxSetFailure.add(100);
        expect(rxSetFailure.value.data!.setView, <int>[1, 2, 3, 100]);

        rxSetFailure.failure = 'failure';
        rxSetFailure.add(1000);

        expect(rxSetFailure.value.data!.setView, <int>[1000]);
      });
    });

    group('addAll', () {
      test('Should add all values', () {
        final RxSetFailure<int, String> rxSetFailure = RxSetFailure<int, String>(initial: <int>[1, 2, 3]);
        rxSetFailure.addAll(<int>[100, 101]);
        expect(rxSetFailure.value.data!.setView, <int>[1, 2, 3, 100, 101]);

        rxSetFailure.failure = 'failure';
        rxSetFailure.addAll(<int>[1000, 1001]);

        expect(rxSetFailure.value.data!.setView, <int>[1000, 1001]);
      });
    });

    group('clear', () {
      test('Should clear values', () {
        final RxSetFailure<int, String> rxSetFailure = RxSetFailure<int, String>(initial: <int>[1, 2, 3]);
        rxSetFailure.clear();
        expect(rxSetFailure.value.data!.setView, <int>[]);

        rxSetFailure.failure = 'failure';
        rxSetFailure.clear();

        expect(rxSetFailure.value.data!.setView, <int>[]);
      });
    });

    group('remove', () {
      test('Should remove value', () {
        final RxSetFailure<int, String> rxSetFailure = RxSetFailure<int, String>(initial: <int>[1, 2, 3]);
        rxSetFailure.remove(2);
        expect(rxSetFailure.value.data!.setView, <int>[1, 3]);

        rxSetFailure.failure = 'failure';
        rxSetFailure.remove(3);

        expect(rxSetFailure.value.data!.setView, <int>[]);
      });
    });

    group('removeWhere', () {
      test('Should remove values where predicate is true', () {
        final RxSetFailure<int, String> rxSetFailure = RxSetFailure<int, String>(initial: <int>[1, 2, 3]);
        rxSetFailure.removeWhere((final int item) => item == 2);
        expect(rxSetFailure.value.data!.setView, <int>[1, 3]);

        rxSetFailure.failure = 'failure';
        rxSetFailure.removeWhere((final int item) => item == 3);

        expect(rxSetFailure.value.data!.setView, <int>[]);
      });
    });

    group('setData', () {
      test('Should set data', () {
        final RxSetFailure<int, String> rxSetFailure = RxSetFailure<int, String>(initial: <int>[1, 2, 3]);
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

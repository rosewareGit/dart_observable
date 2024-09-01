import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxMapFailure', () {
    group('factory-failure', () {
      test('Should create RxMapFailure with failure', () {
        final RxMapFailure<int, String, String> rxMapFailure =
            RxMapFailure<int, String, String>.failure(failure: 'failure');
        expect(rxMapFailure.value.custom, 'failure');
      });
    });

    group('set failure', () {
      test('Should set failure', () {
        final RxMapFailure<int, String, String> rxMapFailure = RxMapFailure<int, String, String>();
        rxMapFailure.failure = 'failure';
        expect(rxMapFailure.value.custom, 'failure');
      });
    });

    // From RxMapStateful
    group('applyAction', () {
      test('Should apply data action', () {
        final RxMapFailure<int, String, String> rxMapFailure = RxMapFailure<int, String, String>(
          initial: <int, String>{1: 'a', 2: 'b', 3: 'c'},
        );
        final StateOf<ObservableMapUpdateAction<int, String>, String> action =
            StateOf<ObservableMapUpdateAction<int, String>, String>.data(
          ObservableMapUpdateAction<int, String>(
            removeItems: <int>{1},
            addItems: <int, String>{
              2: 'e',
              4: 'd',
            },
          ),
        );

        final StateOf<ObservableMapChange<int, String>, String>? result = rxMapFailure.applyAction(action);
        expect(result!.data!.added, <int, String>{4: 'd'});
        expect(result.data!.removed, <int, String>{1: 'a'});
        expect(
          result.data!.updated,
          <int, ObservableItemChange<String>>{2: ObservableItemChange<String>(oldValue: 'b', newValue: 'e')},
        );
      });

      test('Should apply failure action', () {
        final RxMapFailure<int, String, String> rxMapFailure =
            RxMapFailure<int, String, String>(initial: <int, String>{1: 'a', 2: 'b', 3: 'c'});
        final StateOf<ObservableMapUpdateAction<int, String>, String> action =
            StateOf<ObservableMapUpdateAction<int, String>, String>.custom('failure');

        final StateOf<ObservableMapChange<int, String>, String>? result = rxMapFailure.applyAction(action);
        expect(result!.custom, 'failure');
      });
    });

    group('applyMapUpdateAction', () {
      test('Should apply data action', () {
        final RxMapFailure<int, String, String> rxMapFailure = RxMapFailure<int, String, String>(
          initial: <int, String>{1: 'a', 2: 'b', 3: 'c'},
        );
        final ObservableMapUpdateAction<int, String> action = ObservableMapUpdateAction<int, String>(
          removeItems: <int>{1},
          addItems: <int, String>{
            2: 'e',
            4: 'd',
          },
        );

        final ObservableMapChange<int, String>? change = rxMapFailure.applyMapUpdateAction(action);
        expect(change!.added, <int, String>{4: 'd'});
        expect(change.removed, <int, String>{1: 'a'});
        expect(
          change.updated,
          <int, ObservableItemChange<String>>{2: ObservableItemChange<String>(oldValue: 'b', newValue: 'e')},
        );
      });
    });

    group('setState', () {
      test('Should set state', () {
        final RxMapFailure<int, String, String> rxMapFailure = RxMapFailure<int, String, String>();
        rxMapFailure.setState('failure');
        expect(rxMapFailure.value.custom, 'failure');
      });
    });

    group('asObservable', () {
      test('Should return self', () {
        final RxMapFailure<int, String, String> rxMapFailure = RxMapFailure<int, String, String>();
        expect(rxMapFailure.asObservable(), rxMapFailure);
      });
    });

    // from RxMapActions
    group('[]=', () {
      test('Should set value', () {
        final RxMapFailure<int, String, String> rxMapFailure = RxMapFailure<int, String, String>();
        rxMapFailure[1] = 'value';
        expect(rxMapFailure[1], 'value');
      });
    });

    group('add', () {
      test('Should add value', () {
        final RxMapFailure<int, String, String> rxMapFailure = RxMapFailure<int, String, String>();
        rxMapFailure.add(1, 'value');
        expect(rxMapFailure[1], 'value');
      });
    });

    group('addAll', () {
      test('Should add all values', () {
        final RxMapFailure<int, String, String> rxMapFailure = RxMapFailure<int, String, String>();
        rxMapFailure.addAll(<int, String>{1: 'a', 2: 'b', 3: 'c'});
        expect(rxMapFailure[1], 'a');
        expect(rxMapFailure[2], 'b');
        expect(rxMapFailure[3], 'c');
      });
    });

    group('clear', () {
      test('Should clear all values', () {
        final RxMapFailure<int, String, String> rxMapFailure = RxMapFailure<int, String, String>(
          initial: <int, String>{1: 'a', 2: 'b', 3: 'c'},
        );
        rxMapFailure.clear();
        expect(rxMapFailure.lengthOrNull, 0);
      });
    });

    group('remove', () {
      test('Should remove value', () {
        final RxMapFailure<int, String, String> rxMapFailure = RxMapFailure<int, String, String>(
          initial: <int, String>{1: 'a', 2: 'b', 3: 'c'},
        );
        rxMapFailure.remove(1);
        expect(rxMapFailure[1], null);
      });
    });

    group('removeWhere', () {
      test('Should remove values', () {
        final RxMapFailure<int, String, String> rxMapFailure = RxMapFailure<int, String, String>(
          initial: <int, String>{1: 'a', 2: 'b', 3: 'c'},
        );
        rxMapFailure.removeWhere((final int key, final String value) => value.contains('a'));
        expect(rxMapFailure[1], null);
      });
    });

    group('setData', () {
      test('Should set data', () {
        final RxMapFailure<int, String, String> rxMapFailure = RxMapFailure<int, String, String>();
        final ObservableMapChange<int, String> change = rxMapFailure.setData(<int, String>{1: 'a', 2: 'b', 3: 'c'})!;
        expect(rxMapFailure[1], 'a');
        expect(rxMapFailure[2], 'b');
        expect(rxMapFailure[3], 'c');
        expect(change.added, <int, String>{1: 'a', 2: 'b', 3: 'c'});

        final ObservableMapChange<int, String>? change2 = rxMapFailure.setData(<int, String>{2: 'a', 3: 'c', 4: 'd'});
        expect(rxMapFailure[1], null);
        expect(rxMapFailure[2], 'a');
        expect(rxMapFailure[3], 'c');
        expect(rxMapFailure[4], 'd');
        expect(change2!.added, <int, String>{4: 'd'});
        expect(change2.removed, <int, String>{1: 'a'});
        expect(
          change2.updated,
          <int, ObservableItemChange<String>>{2: ObservableItemChange<String>(oldValue: 'b', newValue: 'a')},
        );
      });
    });
  });
}

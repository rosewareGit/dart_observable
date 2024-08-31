import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxSetUndefined', () {
    group('undefined', () {
      test('Should set to undefined', () {
        final RxSetUndefined<int> rxSet = RxSetUndefined<int>();
        rxSet.setUndefined();
        expect(rxSet.value.custom, Undefined());
      });
    });

    group('applyAction', () {
      test('Should apply data action', () {
        final RxSetUndefined<int> rxSet = RxSetUndefined<int>(initial: <int>[1, 2, 3]);
        final StateOf<ObservableSetUpdateAction<int>, Undefined> action =
            StateOf<ObservableSetUpdateAction<int>, Undefined>.data(
          ObservableSetUpdateAction<int>(
            removeItems: <int>{1},
            addItems: <int>{1000},
          ),
        );

        final StateOf<ObservableSetChange<int>, Undefined>? result = rxSet.applyAction(action);
        expect(result!.data!.added, <int>{1000});
        expect(result.data!.removed, <int>{1});
      });

      test('Should apply undefined action', () {
        final RxSetUndefined<int> rxSet = RxSetUndefined<int>(initial: <int>[1, 2, 3]);
        final StateOf<ObservableSetUpdateAction<int>, Undefined> action =
            StateOf<ObservableSetUpdateAction<int>, Undefined>.custom(Undefined());

        final StateOf<ObservableSetChange<int>, Undefined>? result = rxSet.applyAction(action);
        expect(result!.custom, Undefined());
      });
    });

    group('applySetUpdateAction', () {
      test('Should apply data action', () {
        final RxSetUndefined<int> rxSet = RxSetUndefined<int>(initial: <int>[1, 2, 3]);
        final ObservableSetUpdateAction<int> action = ObservableSetUpdateAction<int>(
          removeItems: <int>{1},
          addItems: <int>{1000},
        );

        final ObservableSetChange<int>? change = rxSet.applySetUpdateAction(action);
        expect(change!.added, <int>{1000});
        expect(change.removed, <int>{1});
      });
    });

    group('setState', () {
      test('Should set state', () {
        final RxSetUndefined<int> rxSet = RxSetUndefined<int>(initial: <int>[1, 2, 3]);
        final StateOf<ObservableSetChange<int>, Undefined>? result = rxSet.setState(Undefined());
        expect(rxSet.value.custom, Undefined());
        expect(result!.custom, Undefined());
      });
    });

    group('asObservable', () {
      test('Should return the same instance but with observable type', () {
        final RxSetUndefined<int> rxSet = RxSetUndefined<int>(initial: <int>[1, 2, 3]);
        final ObservableSetUndefined<int> observableSet = rxSet.asObservable();
        expect(observableSet, rxSet);
      });
    });

    group('add', () {
      test('Should add value', () {
        final RxSetUndefined<int> rxSet = RxSetUndefined<int>(initial: <int>[1, 2, 3]);
        rxSet.add(100);
        expect(rxSet.value.data!.setView, <int>[1, 2, 3, 100]);

        rxSet.setUndefined();
        rxSet.add(1000);

        expect(rxSet.value.data!.setView, <int>[1000]);
      });
    });

    group('addAll', () {
      test('Should add all values', () {
        final RxSetUndefined<int> rxSet = RxSetUndefined<int>(initial: <int>[1, 2, 3]);
        rxSet.addAll(<int>[100, 101]);
        expect(rxSet.value.data!.setView, <int>[1, 2, 3, 100, 101]);

        rxSet.setUndefined();
        rxSet.addAll(<int>[1000, 1001]);

        expect(rxSet.value.data!.setView, <int>[1000, 1001]);
      });
    });

    group('clear', () {
      test('Should clear values', () {
        final RxSetUndefined<int> rxSet = RxSetUndefined<int>(initial: <int>[1, 2, 3]);
        rxSet.clear();
        expect(rxSet.value.data!.setView, <int>[]);

        rxSet.setUndefined();
        rxSet.clear();

        expect(rxSet.value.data!.setView, <int>[]);
      });
    });

    group('remove', () {
      test('Should remove value', () {
        final RxSetUndefined<int> rxSet = RxSetUndefined<int>(initial: <int>[1, 2, 3]);
        rxSet.remove(2);
        expect(rxSet.value.data!.setView, <int>[1, 3]);

        rxSet.setUndefined();
        rxSet.remove(3);

        expect(rxSet.value.data!.setView, <int>[]);
      });
    });

    group('removeWhere', () {
      test('Should remove values where predicate is true', () {
        final RxSetUndefined<int> rxSet = RxSetUndefined<int>(initial: <int>[1, 2, 3]);
        rxSet.removeWhere((final int item) => item == 2);
        expect(rxSet.value.data!.setView, <int>[1, 3]);

        rxSet.setUndefined();
        rxSet.removeWhere((final int item) => item == 3);

        expect(rxSet.value.data!.setView, <int>[]);
      });
    });

    group('setData', () {
      test('Should set data', () {
        final RxSetUndefined<int> rxUndefined = RxSetUndefined<int>(initial: <int>[1, 2, 3]);
        final ObservableSetChange<int>? change = rxUndefined.setData(<int>{100, 101});
        expect(rxUndefined.value.data!.setView, <int>{100, 101});
        expect(change!.added, <int>{100, 101});
        expect(change.removed, <int>{1, 2, 3});

        rxUndefined.setUndefined();
        expect(rxUndefined.value.data, null);
        expect(rxUndefined.value.custom, Undefined());

        rxUndefined.setData(<int>{1000, 1001});
        expect(rxUndefined.value.data!.setView, <int>{1000, 1001});

        final ObservableSetChange<int>? change2 = rxUndefined.setData(<int>{1001, 1002, 1003});
        expect(rxUndefined.value.data!.setView, <int>{1001, 1002, 1003});
        expect(change2!.added, <int>{1002, 1003});
        expect(change2.removed, <int>{1000});
      });
    });
  });
}

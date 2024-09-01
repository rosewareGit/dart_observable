import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxMapUndefined', () {
    group('factory-undefined', () {
      test('Should create RxMapUndefined with undefined', () {
        final RxMapUndefined<int, String> rxMapUndefined = RxMapUndefined<int, String>.undefined();
        expect(rxMapUndefined.value.custom, Undefined());
      });
    });

    group('setUndefined', () {
      test('Should set undefined', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>();
        rxMap.setUndefined();
        expect(rxMap.value.custom, Undefined());
      });
    });

    // From RxMapStateful
    group('applyAction', () {
      test('Should apply data action', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>(
          initial: <int, String>{1: 'a', 2: 'b', 3: 'c'},
        );
        final StateOf<ObservableMapUpdateAction<int, String>, Undefined> action =
            StateOf<ObservableMapUpdateAction<int, String>, Undefined>.data(
          ObservableMapUpdateAction<int, String>(
            removeItems: <int>{1},
            addItems: <int, String>{
              2: 'e',
              4: 'd',
            },
          ),
        );

        final StateOf<ObservableMapChange<int, String>, Undefined>? result = rxMap.applyAction(action);
        expect(result!.data!.added, <int, String>{4: 'd'});
        expect(result.data!.removed, <int, String>{1: 'a'});
        expect(
          result.data!.updated,
          <int, ObservableItemChange<String>>{2: ObservableItemChange<String>(oldValue: 'b', newValue: 'e')},
        );
      });

      test('Should apply undefined action', () {
        final RxMapUndefined<int, String> rxMap =
            RxMapUndefined<int, String>(initial: <int, String>{1: 'a', 2: 'b', 3: 'c'});
        final StateOf<ObservableMapUpdateAction<int, String>, Undefined> action =
            StateOf<ObservableMapUpdateAction<int, String>, Undefined>.custom(Undefined());

        final StateOf<ObservableMapChange<int, String>, Undefined>? result = rxMap.applyAction(action);
        expect(result!.custom, Undefined());
      });
    });

    group('applyMapUpdateAction', () {
      test('Should apply data action', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>(
          initial: <int, String>{1: 'a', 2: 'b', 3: 'c'},
        );
        final ObservableMapUpdateAction<int, String> action = ObservableMapUpdateAction<int, String>(
          removeItems: <int>{1},
          addItems: <int, String>{
            2: 'e',
            4: 'd',
          },
        );

        final ObservableMapChange<int, String>? change = rxMap.applyMapUpdateAction(action);
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
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>();
        rxMap.setUndefined();
        expect(rxMap.value.custom, Undefined());
      });
    });

    group('asObservable', () {
      test('Should return self', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>();
        expect(rxMap.asObservable(), rxMap);
      });
    });

    // from RxMapActions
    group('[]=', () {
      test('Should set value', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>();
        rxMap[1] = 'value';
        expect(rxMap[1], 'value');
      });
    });

    group('add', () {
      test('Should add value', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>();
        rxMap.add(1, 'value');
        expect(rxMap[1], 'value');
      });
    });

    group('addAll', () {
      test('Should add all values', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>();
        rxMap.addAll(<int, String>{1: 'a', 2: 'b', 3: 'c'});
        expect(rxMap[1], 'a');
        expect(rxMap[2], 'b');
        expect(rxMap[3], 'c');
      });
    });

    group('clear', () {
      test('Should clear all values', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>(
          initial: <int, String>{1: 'a', 2: 'b', 3: 'c'},
        );
        rxMap.clear();
        expect(rxMap.lengthOrNull, 0);
      });
    });

    group('remove', () {
      test('Should remove value', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>(
          initial: <int, String>{1: 'a', 2: 'b', 3: 'c'},
        );
        rxMap.remove(1);
        expect(rxMap[1], null);
      });
    });

    group('removeWhere', () {
      test('Should remove values', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>(
          initial: <int, String>{1: 'a', 2: 'b', 3: 'c'},
        );
        rxMap.removeWhere((final int key, final String value) => value.contains('a'));
        expect(rxMap[1], null);
      });
    });

    group('setData', () {
      test('Should set data', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>();
        final ObservableMapChange<int, String> change = rxMap.setData(<int, String>{1: 'a', 2: 'b', 3: 'c'})!;
        expect(rxMap[1], 'a');
        expect(rxMap[2], 'b');
        expect(rxMap[3], 'c');
        expect(change.added, <int, String>{1: 'a', 2: 'b', 3: 'c'});

        final ObservableMapChange<int, String>? change2 = rxMap.setData(<int, String>{2: 'a', 3: 'c', 4: 'd'});
        expect(rxMap[1], null);
        expect(rxMap[2], 'a');
        expect(rxMap[3], 'c');
        expect(rxMap[4], 'd');
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

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxStatefulMap', () {
    test('Should create RxStatefulMap with custom', () {
      final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>.custom('custom');
      expect(rxMap.value.rightOrNull, 'custom');
    });
    group('set custom', () {
      test('Should set custom', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>();
        rxMap.setState('custom');
        expect(rxMap.value.rightOrNull, 'custom');
      });
    });

    // From RxMapStateful
    group('applyAction', () {
      test('Should apply data action', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>(
          initial: <int, String>{1: 'a', 2: 'b', 3: 'c'},
        );
        final Either<ObservableMapUpdateAction<int, String>, String> action =
            Either<ObservableMapUpdateAction<int, String>, String>.left(
          ObservableMapUpdateAction<int, String>(
            removeItems: <int>{1},
            addItems: <int, String>{
              2: 'e',
              4: 'd',
            },
          ),
        );

        final Either<ObservableMapChange<int, String>, String>? result = rxMap.applyAction(action);
        expect(result!.leftOrThrow.added, <int, String>{4: 'd'});
        expect(result.leftOrThrow.removed, <int, String>{1: 'a'});
        expect(
          result.leftOrThrow.updated,
          <int, ObservableItemChange<String>>{2: ObservableItemChange<String>(oldValue: 'b', newValue: 'e')},
        );
      });

      test('Should apply custom action', () {
        final RxStatefulMap<int, String, String> rxMap =
            RxStatefulMap<int, String, String>(initial: <int, String>{1: 'a', 2: 'b', 3: 'c'});
        final Either<ObservableMapUpdateAction<int, String>, String> action =
            Either<ObservableMapUpdateAction<int, String>, String>.right(
          'custom',
        );

        final Either<ObservableMapChange<int, String>, String>? result = rxMap.applyAction(action);
        expect(result!.rightOrNull, 'custom');
      });
    });

    group('applyMapUpdateAction', () {
      test('Should apply data action', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>(
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
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>();
        rxMap.setState('custom');
        expect(rxMap.value.rightOrNull, 'custom');

        rxMap.setState('custom2');
        expect(rxMap.value.rightOrNull, 'custom2');
      });
    });

    // from RxMapActions
    group('[]=', () {
      test('Should set value', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>();
        rxMap[1] = 'value';
        expect(rxMap[1], 'value');
      });
    });

    group('add', () {
      test('Should add value', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>();
        rxMap.add(1, 'value');
        expect(rxMap[1], 'value');
      });
    });

    group('addAll', () {
      test('Should add all values', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>();
        rxMap.addAll(<int, String>{1: 'a', 2: 'b', 3: 'c'});
        expect(rxMap[1], 'a');
        expect(rxMap[2], 'b');
        expect(rxMap[3], 'c');
      });
    });

    group('clear', () {
      test('Should clear all values', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>(
          initial: <int, String>{1: 'a', 2: 'b', 3: 'c'},
        );
        rxMap.clear();
        expect(rxMap.length, 0);
        expect(rxMap.value.leftOrThrow.mapView.isEmpty, true);

      });
    });

    group('remove', () {
      test('Should remove value', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>(
          initial: <int, String>{1: 'a', 2: 'b', 3: 'c'},
        );
        rxMap.remove(1);
        expect(rxMap[1], null);
      });
    });

    group('removeWhere', () {
      test('Should remove values', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>(
          initial: <int, String>{1: 'a', 2: 'b', 3: 'c'},
        );
        rxMap.removeWhere((final int key, final String value) => value.contains('a'));
        expect(rxMap[1], null);
      });
    });

    group('setData', () {
      test('Should set data', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>();
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

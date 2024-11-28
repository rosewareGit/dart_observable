import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxStatefulMap', () {
    group('value', () {
      test('should return the unmodifiable view of the map', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>();
        expect(() => rxMap.value.leftOrThrow[0] = 'value', throwsUnsupportedError);
      });

      test('Should set a new custom state', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>();
        rxMap.value = Either<Map<int, String>, String>.right('custom');
        expect(rxMap.value.rightOrNull, 'custom');
        expect(rxMap.change.rightOrNull, 'custom');
      });

      test('Should set a new map', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>();
        rxMap.value = Either<Map<int, String>, String>.left(<int, String>{1: 'a', 2: 'b', 3: 'c'});
        expect(rxMap.value.leftOrThrow, <int, String>{1: 'a', 2: 'b', 3: 'c'});
        expect(rxMap.change.leftOrThrow.added, <int, String>{1: 'a', 2: 'b', 3: 'c'});
        expect(rxMap.change.leftOrThrow.removed.length, 0);
        expect(rxMap.change.leftOrThrow.updated.length, 0);

        rxMap.value = Either<Map<int, String>, String>.left(<int, String>{2: 'a', 3: 'c', 4: 'd'});
        expect(rxMap.value.leftOrThrow, <int, String>{2: 'a', 3: 'c', 4: 'd'});
        expect(rxMap.change.leftOrThrow.added, <int, String>{4: 'd'});
        expect(rxMap.change.leftOrThrow.removed, <int, String>{1: 'a'});
        expect(rxMap.change.leftOrThrow.updated, <int, ObservableItemChange<String>>{
          2: ObservableItemChange<String>(oldValue: 'b', newValue: 'a'),
        });

        rxMap.value = Either<Map<int, String>, String>.left(<int, String>{});
        expect(rxMap.value.leftOrThrow, <int, String>{});
        expect(rxMap.change.leftOrThrow.removed, <int, String>{2: 'a', 3: 'c', 4: 'd'});
        expect(rxMap.change.leftOrThrow.added.length, 0);
        expect(rxMap.change.leftOrThrow.updated.length, 0);
      });
    });

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
        expect(rxMap.value.leftOrThrow.isEmpty, true);
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

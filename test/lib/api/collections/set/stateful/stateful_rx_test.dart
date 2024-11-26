import 'dart:collection';

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxStatefulSet', () {
    group('value', () {
      test('Should return an unmodifiable view of the set', () {
        final RxStatefulSet<int, String> set = RxStatefulSet<int, String>(initial: <int>{1, 2, 3});
        final UnmodifiableSetView<int> value = set.value.leftOrThrow;

        expect(() => value.add(4), throwsUnsupportedError);
      });
    });

    group('factory', () {
      test('Should create instance with initial data', () {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3]);
        expect(rxSet.value.leftOrThrow, <int>[1, 2, 3]);
      });

      test('Should create instance with failure', () {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(custom: 'custom');
        expect(rxSet.value.rightOrThrow, 'custom');
      });
    });

    group('custom', () {
      test('Should set failure', () {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>();
        rxSet.setState('custom');
        expect(rxSet.value.rightOrThrow, 'custom');
      });
    });

    group('applyAction', () {
      test('Should apply data action', () {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3]);
        final Either<ObservableSetUpdateAction<int>, String> action =
            Either<ObservableSetUpdateAction<int>, String>.left(
          ObservableSetUpdateAction<int>(
            removeItems: <int>{1},
            addItems: <int>{1000},
          ),
        );

        final Either<ObservableSetChange<int>, String>? result = rxSet.applyAction(action);
        expect(result!.leftOrThrow.added, <int>{1000});
        expect(result.leftOrThrow.removed, <int>{1});
      });

      test('Should apply failure action', () {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3]);
        final Either<ObservableSetUpdateAction<int>, String> action =
            Either<ObservableSetUpdateAction<int>, String>.right('custom');

        final Either<ObservableSetChange<int>, String>? result = rxSet.applyAction(action);
        expect(result!.rightOrThrow, 'custom');
      });
    });

    group('applySetUpdateAction', () {
      test('Should apply data action', () {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3]);
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
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3]);
        final Either<ObservableSetChange<int>, String>? result = rxSet.setState('state');
        expect(rxSet.value.rightOrThrow, 'state');
        expect(result!.rightOrThrow, 'state');

        final Either<ObservableSetChange<int>, String>? result2 = rxSet.setState('state2');
        expect(rxSet.value.rightOrThrow, 'state2');
        expect(result2!.rightOrThrow, 'state2');
      });
    });

    group('add', () {
      test('Should add value', () {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3]);
        rxSet.add(100);
        expect(rxSet.value.leftOrThrow, <int>[1, 2, 3, 100]);

        rxSet.setState('custom');
        rxSet.add(1000);

        expect(rxSet.value.leftOrThrow, <int>[1000]);
      });
    });

    group('addAll', () {
      test('Should add all values', () {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3]);
        rxSet.addAll(<int>[100, 101]);
        expect(rxSet.value.leftOrThrow, <int>[1, 2, 3, 100, 101]);

        rxSet.setState('custom');
        rxSet.addAll(<int>[1000, 1001]);

        expect(rxSet.value.leftOrThrow, <int>[1000, 1001]);
      });
    });

    group('clear', () {
      test('Should clear values', () {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3]);
        rxSet.clear();
        expect(rxSet.value.leftOrThrow, <int>[]);

        rxSet.setState('custom');
        rxSet.clear();

        expect(rxSet.value.leftOrThrow, <int>[]);
      });
    });

    group('remove', () {
      test('Should remove value', () {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3]);
        rxSet.remove(2);
        expect(rxSet.value.leftOrThrow, <int>[1, 3]);

        rxSet.setState('custom');
        rxSet.remove(3);

        expect(rxSet.value.leftOrThrow, <int>[]);
      });
    });

    group('removeWhere', () {
      test('Should remove values where predicate is true', () {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3]);
        rxSet.removeWhere((final int item) => item == 2);
        expect(rxSet.value.leftOrThrow, <int>[1, 3]);

        rxSet.setState('custom');
        rxSet.removeWhere((final int item) => item == 3);

        expect(rxSet.value.leftOrThrow, <int>[]);
      });
    });

    group('setData', () {
      test('Should set data', () {
        final RxStatefulSet<int, String> rxSet = RxStatefulSet<int, String>(initial: <int>[1, 2, 3]);
        final ObservableSetChange<int>? change = rxSet.setData(<int>{100, 101});
        expect(rxSet.value.leftOrThrow, <int>{100, 101});
        expect(change!.added, <int>{100, 101});
        expect(change.removed, <int>{1, 2, 3});

        rxSet.setState('custom');
        expect(rxSet.value.leftOrNull, null);

        rxSet.setData(<int>{1000, 1001});
        expect(rxSet.value.leftOrThrow, <int>{1000, 1001});

        final ObservableSetChange<int>? change2 = rxSet.setData(<int>{1001, 1002, 1003});
        expect(rxSet.value.leftOrThrow, <int>{1001, 1002, 1003});
        expect(change2!.added, <int>{1002, 1003});
        expect(change2.removed, <int>{1000});
      });
    });
  });
}

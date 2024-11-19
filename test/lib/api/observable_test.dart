import 'dart:async';

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('observable', () {
    group('combineLatest', () {
      test('Should combine latest values', () {
        final Rx<int> rxInt1 = Rx<int>(0);
        final Rx<int> rxInt2 = Rx<int>(0);
        final Rx<int> rxInt3 = Rx<int>(0);

        final Observable<int> rxInt = Observable<int>.combineLatest(
          observables: <Observable<dynamic>>[rxInt1, rxInt2, rxInt3],
          combiner: () {
            return rxInt1.value + rxInt2.value + rxInt3.value;
          },
        );

        rxInt.listen();
        expect(rxInt.value, 0);

        rxInt1.value = 1;
        expect(rxInt.value, 1);

        rxInt2.value = 2;
        expect(rxInt.value, 3);

        rxInt3.value = 3;
        expect(rxInt.value, 6);
      });
    });

    group('fromFuture', () {
      test('Should get value from future', () async {
        final Future<int> future = Future<int>.value(10);
        final Observable<int> rxInt = Observable<int>.fromFuture(
          initial: 0,
          future: future,
        );

        expect(rxInt.value, 0);
        rxInt.listen();
        expect(rxInt.value, 0);

        await future;
        expect(rxInt.value, 10);
      });

      test('Should get value from future provider', () async {
        final Observable<int> rxInt = Observable<int>.fromFuture(
          initial: 0,
          futureProvider: () async {
            return 10;
          },
        );

        expect(rxInt.value, 0);
        rxInt.listen();
        expect(rxInt.value, 0);

        await Future<void>.delayed(const Duration(milliseconds: 1));
        expect(rxInt.value, 10);
      });

      group('fromStream', () {
        test('Should get value from stream', () {
          final StreamController<int> controller = StreamController<int>(sync: true);
          final Observable<int> rxInt = Observable<int>.fromStream(
            stream: controller.stream,
            initial: 0,
          );

          expect(rxInt.value, 0);
          rxInt.listen();
          expect(rxInt.value, 0);

          controller.add(10);
          expect(rxInt.value, 10);
        });
      });
    });

    group('disposed', () {
      test('Should be false by default', () {
        final Observable<int> rxInt = Rx<int>(0);
        expect(rxInt.disposed, false);
      });

      test('Should be true after dispose', () async {
        final Observable<int> rxInt = Rx<int>(0);
        await rxInt.dispose();
        expect(rxInt.disposed, true);
      });
    });

    group('previous', () {
      test('Should be null by default', () {
        final Observable<int> rxInt = Rx<int>(0);
        expect(rxInt.previous, null);
      });

      test('Should be null after value change', () {
        final Rx<int> rxInt = Rx<int>(0);
        rxInt.value = 1;
        expect(rxInt.previous, 0);
      });

      test('Should be previous value after value change', () {
        final Rx<int> rxInt = Rx<int>(0);
        rxInt.value = 1;
        rxInt.value = 2;
        expect(rxInt.previous, 1);
      });
    });

    group('value', () {
      test('Should be initial value', () {
        final Observable<int> rxInt = Rx<int>(0);
        expect(rxInt.value, 0);
      });

      test('Should be changed value', () {
        final Rx<int> rxInt = Rx<int>(0);
        rxInt.value = 1;
        expect(rxInt.value, 1);
      });
    });

    group('dispose', () {
      test('Should dispose', () async {
        final Rx<int> rxInt = Rx<int>(0);
        await rxInt.dispose();
        expect(rxInt.disposed, true);
      });

      test('Should call workers', () async {
        final Rx<int> rxInt = Rx<int>(0);
        bool disposed = false;
        rxInt.addDisposeWorker(() async {
          disposed = true;
        });
        await rxInt.dispose();
        expect(disposed, true);
      });
    });

    group('listen', () {
      test('Should call listener', () {
        final Rx<int> rxInt = Rx<int>(0);
        bool called = false;
        rxInt.listen(
          onChange: (final int value) {
            called = true;
          },
        );
        rxInt.value = 1;
        expect(called, true);
      });
    });

    group('transformAs', () {
      group('list', () {
        test('Transform from Observable, create a history of items', () async {
          final RxInt source = RxInt(0);
          final ObservableList<String> rxList = source.transformAs.list<String>(
            transform: (
              final ObservableList<String> state,
              final int value,
              final Emitter<List<String>> emitter,
            ) {
              emitter(
                <String>[...state.value.listView, value.toString()],
              );
            },
          );

          expect(rxList.length, 0);
          final Disposable listener = rxList.listen();

          expect(rxList.length, 1);
          expect(rxList[0], '0');

          source.value = 3;

          expect(rxList.length, 2);
          expect(rxList.value.listView, <String>['0', '3']);
          expect(rxList[1], '3');

          listener.dispose();

          source.value = 6;
          source.value = 7;

          expect(rxList.length, 2);

          rxList.listen();

          expect(rxList.length, 4);
          expect(rxList.value.listView, <String>['0', '3', '6', '7']);
          expect(rxList[2], '6');
          expect(rxList[3], '7');

          await source.dispose();

          expect(rxList.disposed, true);
        });
      });

      group('set', () {
        test('Transform from Observable, create history of items', () async {
          final RxInt source = RxInt(0);
          final ObservableSet<String> rxSet = source.transformAs.set<String>(
            transform: (
              final ObservableSet<String> state,
              final int value,
              final Emitter<Set<String>> emitter,
            ) {
              emitter(
                <String>{...state.value.setView, value.toString()},
              );
            },
          );

          expect(rxSet.length, 0);
          final Disposable listener = rxSet.listen();

          expect(rxSet.length, 1);
          expect(rxSet.contains('0'), true);

          source.value = 3;

          expect(rxSet.length, 2);
          expect(rxSet.contains('3'), true);

          listener.dispose();

          source.value = 6;
          source.value = 7;

          expect(rxSet.length, 2);

          rxSet.listen();

          expect(rxSet.length, 4);
          expect(rxSet.contains('6'), true);
          expect(rxSet.contains('7'), true);

          await source.dispose();

          expect(rxSet.disposed, true);
        });
      });

      group('map', () {
        test('Transform from Observable, create history of items', () async {
          final RxInt source = RxInt(0);
          final ObservableMap<int, String> rxMap = source.transformAs.map<int, String>(
            transform: (
              final ObservableMap<int, String> state,
              final int value,
              final Emitter<Map<int, String>> emitter,
            ) {
              emitter(
                <int, String>{...state.value.mapView, value: value.toString()},
              );
            },
          );

          expect(rxMap.length, 0);
          rxMap.listen();

          expect(rxMap.length, 1);
          expect(rxMap[0], '0');

          source.value = 3;
          expect(rxMap.length, 2);
          expect(rxMap[3], '3');

          source.value = 6;
          expect(rxMap.length, 3);
          expect(rxMap[6], '6');

          await source.dispose();

          expect(rxMap.disposed, true);
        });
      });

      group('statefulList', () {
        test('Transform from Observable, create history of items', () async {
          final RxInt source = RxInt(0);
          final ObservableStatefulList<String, String> rxList = source.transformAs.statefulList<String, String>(
            transform: (
              final ObservableStatefulList<String, String> state,
              final int value,
              final Emitter<Either<List<String>, String>> emitter,
            ) {
              emitter(
                Either<List<String>, String>.left(
                  <String>[...?state.value.leftOrNull?.listView, value.toString()],
                ),
              );
            },
          );

          expect(rxList.value.leftOrThrow.listView, <String>[]);
          final Disposable listener = rxList.listen();

          expect(rxList.value.leftOrThrow.listView, <String>['0']);

          source.value = 3;

          expect(rxList.value.leftOrThrow.listView, <String>['0', '3']);

          listener.dispose();

          source.value = 6;
          source.value = 7;

          expect(rxList.value.leftOrThrow.listView, <String>['0', '3']);

          rxList.listen();

          expect(rxList.value.leftOrThrow.listView, <String>['0', '3', '6', '7']);

          await source.dispose();

          expect(rxList.disposed, true);
        });
      });

      group('statefulMap', () {
        test('Transform from Observable, create history from items', () async {
          final RxInt source = RxInt(0);
          final ObservableStatefulMap<int, String, String> rxMap = source.transformAs.statefulMap<int, String, String>(
            transform: (
              final ObservableStatefulMap<int, String, String> state,
              final int value,
              final Emitter<Either<Map<int, String>, String>> emitter,
            ) {
              emitter(
                Either<Map<int, String>, String>.left(
                  <int, String>{...?state.value.leftOrNull?.mapView, value: value.toString()},
                ),
              );
            },
          );

          expect(rxMap.value.leftOrThrow.mapView, <int, String>{});
          rxMap.listen();

          expect(rxMap.value.leftOrThrow.mapView, <int, String>{0: '0'});

          source.value = 3;
          expect(rxMap.value.leftOrThrow.mapView, <int, String>{0: '0', 3: '3'});

          source.value = 6;
          expect(rxMap.value.leftOrThrow.mapView, <int, String>{0: '0', 3: '3', 6: '6'});

          await source.dispose();

          expect(rxMap.disposed, true);
        });
      });

      group('statefulSet', () {
        test('Transform from Observable, create history of items', () async {
          final RxInt source = RxInt(0);
          final ObservableStatefulSet<String, String> rxSet = source.transformAs.statefulSet<String, String>(
            transform: (
              final ObservableStatefulSet<String, String> state,
              final int value,
              final Emitter<Either<Set<String>, String>> emitter,
            ) {
              emitter(
                Either<Set<String>, String>.left(
                  <String>{...?state.value.leftOrNull?.setView, value.toString()},
                ),
              );
            },
          );

          expect(rxSet.value.leftOrThrow.setView, <String>{});
          rxSet.listen();

          expect(rxSet.value.leftOrThrow.setView, <String>{'0'});

          source.value = 3;
          expect(rxSet.value.leftOrThrow.setView, <String>{'0', '3'});

          source.value = 6;
          expect(rxSet.value.leftOrThrow.setView, <String>{'0', '3', '6'});

          await source.dispose();

          expect(rxSet.disposed, true);
        });
      });
    });

    group('switchMapAs', () {
      group('set', () {
        test('Should switch and listen to observables', () async {
          final RxSet<String> rxOdd = RxSet<String>();
          final RxSet<String> rxEven = RxSet<String>();

          final RxInt rxSource = RxInt(0);

          final ObservableSet<String> result = rxSource.switchMapAs.set<String>(
            mapper: (final int value) {
              return value % 2 == 0 ? rxEven : rxOdd;
            },
          );

          expect(result.length, 0);

          rxSource.value = 1;
          expect(result.length, 0);
          rxOdd.addAll(<String>['a', 'b', 'c']);

          expect(result.length, 0, reason: 'Should not be updated as we are not listening');
          result.listen();
          expect(result.length, 3, reason: 'Should be updated as we are listening');

          rxOdd.addAll(<String>['d', 'e', 'f']);
          expect(result.length, 6);

          rxSource.value = 2;
          expect(result.length, 0);

          rxEven.addAll(<String>['g', 'h', 'i']);
          expect(result.length, 3);

          rxSource.value = 1;
          expect(result.length, 6);
          expect(result.contains('a'), true);

          rxOdd.remove('a');
          expect(result.length, 5);
          expect(result.contains('a'), false);

          await rxSource.dispose();
          expect(result.disposed, true);
        });
      });

      group('map', () {
        test('Should listen on changes from maps', () async {
          final RxMap<String, int> rxEven = RxMap<String, int>();
          final RxMap<String, int> rxOdd = RxMap<String, int>();

          final RxInt rxSource = RxInt(0);

          final ObservableMap<String, int> result = rxSource.switchMapAs.map<String, int>(
            mapper: (final int value) {
              return value % 2 == 0 ? rxEven : rxOdd;
            },
          );

          expect(result.length, 0);
          rxEven.addAll(<String, int>{'a': 1, 'b': 2, 'c': 3});

          expect(result.length, 0, reason: 'Should not be updated as we are not listening');
          result.listen();
          expect(result.length, 3, reason: 'Should be updated as we are listening');
          expect(result['a'], 1);
          expect(result['b'], 2);
          expect(result['c'], 3);

          rxEven.addAll(<String, int>{'d': 4, 'e': 5, 'f': 6});
          expect(result.length, 6);
          expect(result['d'], 4);
          expect(result['e'], 5);
          expect(result['f'], 6);

          rxSource.value = 1;
          expect(result.length, 0);

          rxOdd.addAll(<String, int>{'g': 7, 'h': 8, 'i': 9});
          expect(result.length, 3);
          expect(result['g'], 7);

          rxSource.value = 2;
          expect(result.length, 6);
          expect(result['a'], 1);

          rxEven.remove('a');
          expect(result.length, 5);
          expect(result['a'], null);

          await rxSource.dispose();
          expect(result.disposed, true);
        });
      });

      group('list', () {
        test('Should have initial items when listening', () {
          final RxList<int> rxEven = RxList<int>(<int>[0]);
          final RxList<int> rxOdd = RxList<int>();

          final RxInt rxSource = RxInt(0);
          final ObservableList<int> result = rxSource.switchMapAs.list<int>(
            mapper: (final int state) {
              return state % 2 == 0 ? rxEven : rxOdd;
            },
          );

          expect(result.length, 0);

          rxSource.value = 0;
          expect(result.length, 0, reason: 'Should not be updated as we are not listening');
          result.listen();
          expect(result.length, 1, reason: 'Should be updated as we are listening');
        });

        test('Should add items when items added to the base', () {
          final RxList<int> rxEven = RxList<int>(<int>[0]);
          final RxList<int> rxOdd = RxList<int>();

          final RxInt rxSource = RxInt(0);
          final ObservableList<int> result = rxSource.switchMapAs.list<int>(
            mapper: (final int state) {
              return state % 2 == 0 ? rxEven : rxOdd;
            },
          );

          expect(result.length, 0);

          expect(result.length, 0);
          rxEven.addAll(<int>[10, 20, 30]);

          expect(result.length, 0, reason: 'Should not be updated as we are not listening');
          result.listen();
          expect(result.length, 4, reason: 'Should be updated as we are listening');
          expect(result[0], 0);
          expect(result[1], 10);
          expect(result[2], 20);
          expect(result[3], 30);

          rxOdd.addAll(<int>[11, 21, 31]);

          expect(result.length, 4, reason: 'source2 is not set yet');

          rxSource.value = 1;

          expect(result.length, 3);
          expect(result[0], 11);
          expect(result[1], 21);
          expect(result[2], 31);
        });

        test('Should remove items when the item is removed from base', () {
          final RxList<int> rxEven = RxList<int>();
          final RxList<int> rxOdd = RxList<int>();

          final RxInt rxSource = RxInt(0);
          final ObservableList<int> result = rxSource.switchMapAs.list<int>(
            mapper: (final int state) {
              return state % 2 == 0 ? rxEven : rxOdd;
            },
          );

          result.listen();
          rxEven.addAll(<int>[1, 1, 2, 2, 1]);
          expect(result.length, 5);

          rxEven.removeAt(0);
          expect(result.length, 4);
          expect(result[0], 1);
          expect(result[1], 2);
        });

        test('Should remove items from the result list when removed from the source', () {
          final RxList<int> rxEven = RxList<int>();
          final RxList<int> rxOdd = RxList<int>();

          final RxInt rxSource = RxInt(0);
          final ObservableList<int> result = rxSource.switchMapAs.list<int>(
            mapper: (final int state) {
              return state % 2 == 0 ? rxEven : rxOdd;
            },
          );

          result.listen();

          rxEven.addAll(<int>[1, 1, 2, 2, 1]);
          expect(result.length, 5);

          rxEven.removeWhere((final int item) => item == 2);

          expect(result.length, 3);
          expect(result[0], 1);
          expect(result[1], 1);
          expect(result[2], 1);
        });

        test('Should dispose when base disposed', () async {
          final RxList<int> rxEven = RxList<int>();
          final RxList<int> rxOdd = RxList<int>();

          final RxInt rxSource = RxInt(0);
          final ObservableList<int> result = rxSource.switchMapAs.list<int>(
            mapper: (final int state) {
              return state % 2 == 0 ? rxEven : rxOdd;
            },
          );

          result.listen();

          expect(result.disposed, false);

          await rxSource.dispose();

          expect(result.disposed, true);
        });
      });

      group('statefulList', () {
        test('Should switch and listen', () {
          final RxStatefulList<String, String> rxEven = RxStatefulList<String, String>(
            initial: <String>['0', '2', '4'],
          );
          final RxStatefulList<String, String> rxOdd = RxStatefulList<String, String>();

          final Rx<int> rxSource = Rx<int>(0);
          final ObservableStatefulList<String, String> rxList = rxSource.switchMapAs.statefulList(
            mapper: (final int value) {
              if (value % 2 == 0) {
                return rxEven;
              }
              return rxOdd;
            },
          );

          rxList.listen();

          expect(rxList.value.leftOrThrow.listView, <String>['0', '2', '4']);
          rxSource.value = 1;
          expect(rxList.value.leftOrThrow.listView, <String>[]);

          rxSource.value = 2;
          expect(rxList.value.leftOrThrow.listView, <String>['0', '2', '4']);

          rxEven.addAll(<String>['6', '8']);
          expect(rxList.value.leftOrThrow.listView, <String>['0', '2', '4', '6', '8']);
          rxEven.remove('2');
          rxEven.remove('4');
          rxEven.remove('6');
          rxOdd.add('3');
          rxOdd.add('5');

          expect(rxList.value.leftOrThrow.listView, <String>['0', '8']);

          rxSource.value = 3;
          expect(rxList.value.leftOrThrow.listView, <String>['3', '5']);
          rxSource.value = 4;
          expect(rxList.value.leftOrThrow.listView, <String>['0', '8']);
        });
      });

      group('statefulMap', () {
        test('Should switch and listen', () async {
          final RxStatefulMap<String, int, String> rxEven = RxStatefulMap<String, int, String>(
            initial: <String, int>{'a': 1, 'b': 2, 'c': 3},
          );
          final RxStatefulMap<String, int, String> rxOdd = RxStatefulMap<String, int, String>();

          final RxInt rxSource = RxInt(0);
          final ObservableStatefulMap<String, int, String> rxMap = rxSource.switchMapAs.statefulMap(
            mapper: (final int value) {
              if (value % 2 == 0) {
                return rxEven;
              }
              return rxOdd;
            },
          );

          rxMap.listen();

          expect(rxMap.value.leftOrThrow.mapView, <String, int>{'a': 1, 'b': 2, 'c': 3});
          rxSource.value = 1;

          expect(rxMap.value.leftOrThrow.mapView, <String, int>{});

          rxSource.value = 2;
          expect(rxMap.value.leftOrThrow.mapView, <String, int>{'a': 1, 'b': 2, 'c': 3});

          rxSource.value = 1;
          expect(rxMap.value.leftOrThrow.mapView, <String, int>{});

          rxOdd.addAll(<String, int>{'d': 4, 'e': 5});
          expect(rxMap.value.leftOrThrow.mapView, <String, int>{'d': 4, 'e': 5});

          rxSource.value = 4;
          expect(rxMap.value.leftOrThrow.mapView, <String, int>{'a': 1, 'b': 2, 'c': 3});

          await rxSource.dispose();
          expect(rxMap.disposed, true);
        });
      });
    });
  });
}

import 'package:dart_observable/dart_observable.dart';
import 'package:dart_observable/src/core/collections/list/list_sync_helper.dart';
import 'package:test/test.dart';

void main() {
  group('ListSyncHelper', () {
    group('handleListChange', () {
      test('Handle added change', () {
        final RxList<String> target = RxList<String>(<String>[
          'A',
          'B',
        ]);
        final ObservableListSyncHelper<String> helper = ObservableListSyncHelper<String>(
          applyAction: target.applyAction,
        );
        helper.handleListChange(
          sourceChange: ObservableListChange<String>(
            added: <int, String>{
              0: 'C',
              1: 'D',
            },
          ),
        );

        expect(helper.$indexMapper[0], 2);
        expect(helper.$indexMapper[1], 3);

        target.addAll(<String>['E1', 'E2']);

        helper.handleListChange(
          sourceChange: ObservableListChange<String>(
            added: <int, String>{
              14: 'A1',
              15: 'A2',
            },
          ),
        );

        expect(helper.$indexMapper[14], 6);
        expect(helper.$indexMapper[15], 7);
      });

      test('Handle update change', () {
        final RxList<String> target = RxList<String>(<String>['A', 'B']);
        final ObservableListSyncHelper<String> helper = ObservableListSyncHelper<String>(
          applyAction: target.applyAction,
        );
        // Add initial data
        helper.handleListChange(
          sourceChange: ObservableListChange<String>(
            added: <int, String>{
              0: 'A',
              1: 'B',
            },
          ),
        );

        expect(helper.$indexMapper[0], 2);
        expect(helper.$indexMapper[1], 3);

        helper.handleListChange(
          sourceChange: ObservableListChange<String>(
            updated: <int, ObservableItemChange<String>>{
              0: ObservableItemChange<String>(
                oldValue: 'A',
                newValue: 'C',
              ),
            },
          ),
        );

        expect(helper.$indexMapper[0], 2);
        expect(helper.$indexMapper[1], 3);

        expect(target[2], 'C');
      });

      test('Handle removed change', () {
        final RxList<String> target = RxList<String>(<String>['E1', 'E2']);
        final ObservableListSyncHelper<String> helper = ObservableListSyncHelper<String>(
          applyAction: target.applyAction,
        );
        // Add initial data
        helper.handleListChange(
          sourceChange: ObservableListChange<String>(
            added: <int, String>{
              0: 'A',
              1: 'B',
              2: 'C',
              3: 'D',
            },
          ),
        );

        /// E1, E2, A, B, C, D
        expect(helper.$indexMapper[0], 2);
        expect(helper.$indexMapper[1], 3);
        expect(helper.$indexMapper[2], 4);
        expect(helper.$indexMapper[3], 5);

        /// E1, E2, B, C, D
        helper.handleListChange(
          sourceChange: ObservableListChange<String>(
            removed: <int, String>{
              1: 'B',
            },
          ),
        );

        expect(helper.$indexMapper[0], 2);
        expect(helper.$indexMapper[1], 3);
        expect(helper.$indexMapper[2], 4);
        expect(helper.$indexMapper[3], null);
      });

      test('Handle multiple changes', () {
        final RxList<String> target = RxList<String>(<String>['A', 'B']);
        final ObservableListSyncHelper<String> helper = ObservableListSyncHelper<String>(
          applyAction: target.applyAction,
        );
        // Add initial data
        helper.handleListChange(
          sourceChange: ObservableListChange<String>(
            added: <int, String>{
              0: 'U1',
              1: 'U2',
            },
          ),
        );

        // A, B, U1, U2
        expect(target.length, 4);

        expect(helper.$indexMapper[0], 2);
        expect(helper.$indexMapper[1], 3);

        // A, B, U1, U2
        // A, B, U1, U2
        // A, B, A2, U2
        // A, B, A2, C, D
        helper.handleListChange(
          sourceChange: ObservableListChange<String>(
            added: <int, String>{
              2: 'C',
              3: 'D',
            },
            updated: <int, ObservableItemChange<String>>{
              0: ObservableItemChange<String>(
                oldValue: 'U1',
                newValue: 'A2',
              ),
            },
            removed: <int, String>{
              1: 'U2',
            },
          ),
        );

        expect(helper.$indexMapper[0], 2);
        expect(helper.$indexMapper[1], 3);
        expect(helper.$indexMapper[2], 4);
        expect(helper.$indexMapper[3], null);

        expect(target.value.listView, <String>['A', 'B', 'A2', 'C', 'D']);
      });
    });
  });
}

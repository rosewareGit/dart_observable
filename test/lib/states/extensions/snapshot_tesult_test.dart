import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ExtensionSnapshotResult', () {
    group('combineWith', () {
      test('Should call onUndefined when any are undefined', () {
        final SnapshotResult<int, dynamic> snapshotResult = SnapshotResult<int, dynamic>.undefined();
        final SnapshotResult<String, dynamic> other = SnapshotResult<String, dynamic>.success('1');

        snapshotResult.combineWith(
          other: other,
          onData: (final int data1, final String data2) => fail('Should not be called'),
          onFailure: () => fail('Should not be called'),
          onUndefined: () => expect(true, true),
        );
      });

      test('Should call onFailure when any are failure', () {
        final SnapshotResult<int, dynamic> snapshotResult = SnapshotResult<int, dynamic>.failure('error');
        final SnapshotResult<String, dynamic> other = SnapshotResult<String, dynamic>.success('1');

        snapshotResult.combineWith(
          other: other,
          onData: (final int data1, final String data2) => fail('Should not be called'),
          onFailure: () => expect(true, true),
          onUndefined: () => fail('Should not be called'),
        );
      });

      test('Should call onData when both are success', () {
        final SnapshotResult<int, dynamic> snapshotResult = SnapshotResult<int, dynamic>.success(1);
        final SnapshotResult<String?, dynamic> other = SnapshotResult<String?, dynamic>.success(null);

        snapshotResult.combineWith(
          other: other,
          onData: (final int data1, final String? data2) {
            expect(data1, 1);
            expect(data2, null);
          },
          onFailure: () => fail('Should not be called'),
          onUndefined: () => fail('Should not be called'),
        );
      });
    });
  });
}

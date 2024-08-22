import 'package:test/test.dart';

void main() {
  group('ObservableMapResult', () {
    // group(
    //   'Performance',
    //   () {
    //     test('Updating large map with 1 item', () async {
    //       // 1 million initial items
    //       final RxMapFailure<int, String, dynamic> rxMap = RxMapFailure<int, String, dynamic>(
    //         initial: <int, String>{
    //           for (int i = 0; i < 10000000; i++) i: 'value$i',
    //         },
    //       );
    //       final ObservableMapResult<int, String, dynamic> mapped = rxMap.mapObservableMapAsMapResult(
    //         valueMapper: (final String value) {
    //           return 'mapped$value';
    //         },
    //       );
    //
    //       await mapped.next();
    //
    //       final Completer<DateTime> completerReceivedAt = Completer<DateTime>();
    //       final Disposable listener = mapped.listen(
    //         onChange: (final Observable<ObservableMapResultState<int, String, dynamic>> source) {
    //           final ObservableMapResultChange<int, String, dynamic> change = source.value.change;
    //           if (change is ObservableMapResultChangeData<int, String, dynamic> && change.change.updated.length == 1) {
    //             completerReceivedAt.complete(DateTime.now());
    //           }
    //         },
    //       );
    //
    //       final DateTime start = DateTime.now();
    //       // 1 item to update
    //       rxMap[0] = 'newValue';
    //       expect(mapped[0], 'mappednewValue');
    //
    //       // Wait for the listener to receive the update
    //       final DateTime receivedAt = await completerReceivedAt.future;
    //       final Duration duration = receivedAt.difference(start);
    //       await listener.dispose();
    //       expect(duration.inMilliseconds < 100, true);
    //     });
    //   },
    //   skip: true,
    // );
  });
}

import '../../../../dart_observable.dart';
import '../_impl.dart';

class ObservableCombineLatestN<T> extends RxImpl<T> {
  ObservableCombineLatestN({
    required this.observables,
    required this.combiner,
    final bool distinct = true,
  }) : super(
          combiner(),
          distinct: distinct,
        );

  final Iterable<Observable<dynamic>> observables;
  final T Function() combiner;

  final List<Disposable> _listeners = <Disposable>[];

  @override
  void onActive() {
    super.onActive();
    _startCollect();
  }

  @override
  void onInit() {
    super.onInit();
    // When all disposed, dispose this
    int disposeCount = 0;
    for (final Observable<dynamic> observable in observables) {
      observable.addDisposeWorker(() {
        disposeCount++;
        if (disposeCount == observables.length) {
          dispose();
        }
      });
    }
  }

  void _startCollect() {
    if (_listeners.isNotEmpty) {
      return;
    }

    value = combiner();

    for (final Observable<dynamic> observable in observables) {
      _listeners.add(
        observable.listen(
          onChange: (final _) {
            value = combiner();
          },
          onError: (final dynamic error, final StackTrace stack) {
            dispatchError(error: error, stack: stack);
          },
        ),
      );
    }

    addDisposeWorker(() async {
      for (final Disposable listener in _listeners) {
        await listener.dispose();
      }
      _listeners.clear();
    });
  }
}

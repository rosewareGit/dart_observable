import '../../../../dart_observable.dart';
import '../../../api/change_tracking_observable.dart';
import '../_impl.dart';

class ObservableCombineWith2<R, T1, T2> extends RxImpl<R> {
  final ChangeTrackingObservable<dynamic, T1, dynamic> observable1;
  final ChangeTrackingObservable<dynamic, T2, dynamic> observable2;
  final R Function(T1 value1, T2 value2) combiner;
  final List<Disposable> _listeners = <Disposable>[];

  ObservableCombineWith2({
    required this.observable1,
    required this.observable2,
    required this.combiner,
    final bool distinct = true,
  }) : super(
          combiner(observable1.value, observable2.value),
          distinct: distinct,
        );

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
    for (final ChangeTrackingObservable<dynamic, Object?, dynamic> observable
        in <ChangeTrackingObservable<dynamic, Object?, dynamic>>[
      observable1,
      observable2,
    ]) {
      observable.addDisposeWorker(() {
        disposeCount++;
        if (disposeCount == 2) {
          dispose();
        }
      });
    }
  }

  void _initListener<T>(final ChangeTrackingObservable<dynamic, T, dynamic> observable) {
    _listeners.add(
      observable.listen(
        onChange: (final _) {
          value = combiner(observable1.value, observable2.value);
        },
        onError: (final dynamic error, final StackTrace stack) {
          dispatchError(error: error, stack: stack);
        },
      ),
    );
  }

  void _startCollect() {
    if (_listeners.isNotEmpty) {
      return;
    }

    value = combiner(observable1.value, observable2.value);

    _initListener(observable1);
    _initListener(observable2);

    addDisposeWorker(() async {
      for (final Disposable listener in _listeners) {
        await listener.dispose();
      }
    });
  }
}

import '../../../../dart_observable.dart';
import '../../../api/change_tracking_observable.dart';
import '../_impl.dart';

class ObservableCombineWith5<R, T1, T2, T3, T4, T5> extends RxImpl<R> {
  final ChangeTrackingObservable<dynamic, T1, dynamic> observable1;
  final ChangeTrackingObservable<dynamic, T2, dynamic> observable2;
  final ChangeTrackingObservable<dynamic, T3, dynamic> observable3;
  final ChangeTrackingObservable<dynamic, T4, dynamic> observable4;
  final ChangeTrackingObservable<dynamic, T5, dynamic> observable5;
  final R Function(T1 value1, T2 value2, T3 value3, T4 value4, T5 value5) combiner;
  final List<Disposable> _listeners = <Disposable>[];

  ObservableCombineWith5({
    required this.observable1,
    required this.observable2,
    required this.observable3,
    required this.observable4,
    required this.observable5,
    required this.combiner,
    final bool distinct = true,
  }) : super(
          combiner(observable1.value, observable2.value, observable3.value, observable4.value, observable5.value),
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
      observable3,
      observable4,
      observable5,
    ]) {
      observable.addDisposeWorker(() {
        disposeCount++;
        if (disposeCount == 5) {
          dispose();
        }
      });
    }
  }

  void _initListener<T>(final ChangeTrackingObservable<dynamic, T, dynamic> observable) {
    _listeners.add(
      observable.listen(
        onChange: (final _) {
          value =
              combiner(observable1.value, observable2.value, observable3.value, observable4.value, observable5.value);
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

    value = combiner(observable1.value, observable2.value, observable3.value, observable4.value, observable5.value);

    _initListener(observable1);
    _initListener(observable2);
    _initListener(observable3);
    _initListener(observable4);
    _initListener(observable5);

    addDisposeWorker(() async {
      for (final Disposable listener in _listeners) {
        await listener.dispose();
      }
    });
  }
}

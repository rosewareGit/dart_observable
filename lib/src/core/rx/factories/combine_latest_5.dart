import '../../../../dart_observable.dart';
import '../_impl.dart';

class ObservableCombineWith5<R, T1, T2, T3, T4, T5> extends RxImpl<R> {
  final Observable<T1> observable1;
  final Observable<T2> observable2;
  final Observable<T3> observable3;
  final Observable<T4> observable4;
  final Observable<T5> observable5;
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
    for (final Observable<dynamic> observable in <Observable<dynamic>>[
      observable1,
      observable2,
      observable3,
      observable4,
      observable5
    ]) {
      observable.addDisposeWorker(() {
        disposeCount++;
        if (disposeCount == 5) {
          dispose();
        }
      });
    }
  }

  void _initListener<T>(final Observable<T> observable) {
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

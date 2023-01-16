import '../../../../dart_observable.dart';
import '../_impl.dart';

class ObservableCombineWith3<R, T1, T2, T3> extends RxImpl<R> {
  ObservableCombineWith3({
    required this.observable1,
    required this.observable2,
    required this.observable3,
    required this.combiner,
    final bool distinct = true,
  }) : super(
    combiner(observable1.value, observable2.value, observable3.value),
    distinct: distinct,
  );

  final Observable<T1> observable1;
  final Observable<T2> observable2;
  final Observable<T3> observable3;
  final R Function(T1 value1, T2 value2, T3 value3) combiner;

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
    for (final Observable<dynamic> observable in <Observable<dynamic>>[observable1, observable2, observable3]) {
      observable.addDisposeWorker(() {
        disposeCount++;
        if (disposeCount == 3) {
          dispose();
        }
      });
    }
  }

  void _startCollect() {
    if (_listeners.isNotEmpty) {
      return;
    }

    value = combiner(observable1.value, observable2.value, observable3.value);

    _initListener(observable1);
    _initListener(observable2);
    _initListener(observable3);

    addDisposeWorker(() async {
      for (final Disposable listener in _listeners) {
        await listener.dispose();
      }
    });
  }

  void _initListener<T>(final Observable<T> observable) {
    _listeners.add(
      observable.listen(
        onChange: (final _) {
          value = combiner(observable1.value, observable2.value, observable3.value);
        },
        onError: (final dynamic error, final StackTrace stack) {
          dispatchError(error: error, stack: stack);
        },
      ),
    );
  }
}
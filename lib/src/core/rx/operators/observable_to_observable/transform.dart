import '../../../../../dart_observable.dart';
import '../../_impl.dart';

class OperatorTransform<T, T2> extends RxImpl<T2> {
  final Observable<T> source;
  final void Function(
    T value,
    Emitter<T2> emit,
  ) handler;
  Disposable? _listener;

  OperatorTransform(
    super.value, {
    required this.source,
    required this.handler,
  });

  @override
  void onActive() {
    super.onActive();
    _initListener();
  }

  @override
  Future<void> onInactive() async {
    await super.onInactive();
    _stopListener();
  }

  @override
  void onInit() {
    super.onInit();
    source.addDisposeWorker(() => dispose());
  }

  void _initListener() {
    if (_listener != null) {
      return;
    }

    handler(source.value, (final T2 change) {
      value = change;
    });

    _listener = source.listen(
      onChange: (final T value) {
        handler(value, (final T2 change) {
          this.value = change;
        });
      },
      onError: (final dynamic error, final StackTrace stack) {
        dispatchError(error: error, stack: stack);
      },
    );
  }

  void _stopListener() {
    _listener?.dispose();
    _listener = null;
  }
}

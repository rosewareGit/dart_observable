import '../../../../../dart_observable.dart';
import '../../_impl.dart';

class OperatorTransform<T, T2> extends RxImpl<T2> {
  OperatorTransform(
    super.value, {
    required this.source,
    required this.handler,
  });

  final Observable<T> source;
  final void Function(
    Observable<T> source,
    Emitter<T2> emit,
  ) handler;

  Disposable? _listener;

  @override
  void onInit() {
    super.onInit();
    source.addDisposeWorker(() => dispose());
  }

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

  void _stopListener() {
    _listener?.dispose();
    _listener = null;
  }

  void _initListener() {
    if (_listener != null) {
      return;
    }

    handler(source, (final T2 change) {
      value = change;
    });

    _listener = source.listen(
      onChange: (final Observable<T> source) {
        handler(source, (final T2 change) {
          value = change;
        });
      },
      onError: (final dynamic error, final StackTrace stack) {
        dispatchError(error: error, stack: stack);
      },
    );
  }
}

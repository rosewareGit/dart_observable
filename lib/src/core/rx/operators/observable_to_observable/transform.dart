import '../../../../../dart_observable.dart';
import '../../../../api/change_tracking_observable.dart';
import '../../_impl.dart';

class OperatorTransform<Self extends ChangeTrackingObservable<Self, T, C>, T, C, T2> extends RxImpl<T2> {
  final Self source;
  final void Function(
    Self source,
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

    handler(source, (final T2 change) {
      value = change;
    });

    _listener = source.listen(
      onChange: (final Self source) {
        handler(source, (final T2 change) {
          value = change;
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

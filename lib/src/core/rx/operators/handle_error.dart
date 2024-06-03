import '../../../../dart_observable.dart';
import '../_impl.dart';

mixin OperatorHandleError<T> implements Observable<T> {
  @override
  Observable<T> handleError(
    final void Function(dynamic error, Emitter<T> emitter) handler, {
    final bool Function(dynamic error)? predicate,
  }) {
    return _HandleErrorOperator<T>(
      source: this,
      handler: handler,
      initial: value,
      predicate: predicate,
    );
  }
}

class _HandleErrorOperator<T> extends RxImpl<T> {
  final Observable<T> source;

  final void Function(dynamic error, Emitter<T> emitter) handler;
  final bool Function(dynamic error)? predicate;
  Disposable? _listener;

  _HandleErrorOperator({
    required this.source,
    required this.handler,
    required final T initial,
    this.predicate,
  }) : super(
          initial,
          distinct: source.distinct,
        );

  @override
  void onActive() {
    super.onActive();
    _initListener();
  }

  @override
  Future<void> onInactive() async {
    await super.onInactive();
    _cancelListener();
  }

  @override
  void onInit() {
    super.onInit();

    source.addDisposeWorker(() {
      return dispose();
    });
  }

  void _cancelListener() {
    _listener?.dispose();
    _listener = null;
  }

  void _handleError(final dynamic error, final StackTrace stack) {
    final bool Function(dynamic error)? predicate = this.predicate;
    if (predicate != null && predicate(error) == false) {
      dispatchError(error: error, stack: stack);
      return;
    }

    handler(error, (final T value) {
      this.value = value;
    });
  }

  void _initListener() {
    if (_listener != null) {
      return;
    }

    _listener = source.listen(
      onChange: (final Observable<T> source) {
        value = source.value;
      },
      onError: _handleError,
    );
  }
}

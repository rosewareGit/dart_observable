import '../../../../dart_observable.dart';

mixin BaseTransformOperator<
    T, // Collection state for this
    T2, // Collection state for the transformed
    U> on RxBase<T2> {
  Disposable? _listener;

  late final List<T> _buffer = <T>[];

  Observable<T> get source;

  void handleUpdate(final U action);

  @override
  void onInit() {
    _init();
    super.onInit();
  }

  void transformChange(
    final T value,
    final Emitter<U> updater,
  );

  void _init() {
    final Disposable activeListener = onActivityChanged(
      onActive: (final _) {
        _initListener();
      },
    );

    source.addDisposeWorker(() async {
      await activeListener.dispose();
      final Disposable? changeListener = _listener;
      if (changeListener != null) {
        await changeListener.dispose();
        _listener = null;
      }
      return dispose();
    });
  }

  void _initListener() {
    if (_listener != null) {
      // apply buffered changes
      for (final T change in _buffer) {
        transformChange(change, handleUpdate);
      }
      _buffer.clear();
      return;
    }

    transformChange(source.value, handleUpdate);

    _listener = source.listen(
      onChange: (final T value) {
        if (state == ObservableState.inactive) {
          // store changes to apply when active
          _buffer.add(value);
          return;
        }

        transformChange(value, handleUpdate);
      },
    );
  }
}

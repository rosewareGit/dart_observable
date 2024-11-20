import '../../../../dart_observable.dart';

mixin BaseCollectionTransformOperator<
    T, // Collection state for this
    T2, // Collection state for the transformed
    C,
    C2> on RxBase<T2> {
  Disposable? _listener;

  late final List<C> _buffer = <C>[];

  ObservableCollection<T, C> get source;

  void handleChange(final C change);

  @override
  void onActive() {
    _initListener();
    super.onActive();
  }

  @override
  void onInit() {
    _init();
    super.onInit();
  }

  void _init() {
    source.addDisposeWorker(() async {
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
      for (final C change in _buffer) {
        handleChange(change);
      }
      _buffer.clear();
      return;
    }

    handleChange(source.currentStateAsChange);

    _listener = source.onChange(
      onChange: (final C change) {
        if (state == ObservableState.inactive) {
          // store changes to apply when active
          _buffer.add(change);
          return;
        }

        handleChange(change);
      },
    );
  }
}

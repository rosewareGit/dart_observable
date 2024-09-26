import '../../../../dart_observable.dart';

mixin BaseCollectionTransformOperator<
    CS extends CollectionState<C>, // Collection state for this
    CS2 extends CollectionState<C2>, // Collection state for the transformed
    C,
    C2> on RxBase<CS2> {
  Disposable? _listener;

  late final List<C> _buffer = <C>[];

  Observable<CS> get source;

  void handleChange(final C change);

  @override
  void onInit() {
    _init();
    super.onInit();
  }

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
      for (final C change in _buffer) {
        handleChange(change);
      }
      _buffer.clear();
      return;
    }

    handleChange(source.value.asChange());

    _listener = source.listen(
      onChange: (final CS value) {
        final C change = value.lastChange;
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

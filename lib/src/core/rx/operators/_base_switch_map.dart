import '../../../../dart_observable.dart';

mixin BaseSwitchMapOperator<
    Result extends Observable<T2>,
    T, // Collection state for this
    T2 // Collection state for the transformed
    > on RxBase<T2> {
  Disposable? _sourceListener;
  Disposable? _intermediateListener;
  Result? _intermediate;

  Result? Function(T value) get mapper;

  // The observable that dictates which observables to listen to
  Observable<T> get source;

  @override
  void onActive() {
    super.onActive();
    _initListener();
  }

  @override
  Future<void> onInactive() async {
    await super.onInactive();
    await _cancelListener();
  }

  @override
  void onInit() {
    super.onInit();
    source.addDisposeWorker(() async {
      await _cancelListener();
      return dispose();
    });
  }

  Future<void> _cancelListener() async {
    await _sourceListener?.dispose();
    await _intermediateListener?.dispose();
    _sourceListener = null;
    _intermediateListener = null;
    _intermediate = null;
  }

  void _handleValue(final T value) {
    final Result? newIntermediate = mapper(value);
    if (newIntermediate == null || _intermediate == newIntermediate) {
      return;
    }

    _intermediate = newIntermediate;

    this.value = newIntermediate.value;

    _intermediateListener?.dispose();
    _intermediateListener = newIntermediate.listen(
      onChange: (final T2 value) {
        this.value = value;
      },
    );
  }

  void _initListener() {
    final T value = source.value;
    _handleValue(value);

    _sourceListener = source.listen(
      onChange: (final T value) {
        _handleValue(value);
      },
    );
  }
}

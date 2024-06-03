part of '../map/result.dart';

class OperatorCollectionsTransformAsMapResult<E, C, T extends CollectionState<E, C>, K, V, F>
    extends RxMapResultImpl<K, V, F> {
  final ObservableCollection<E, C, T> source;
  final void Function(
    C change,
    Emitter<ObservableMapResultUpdateAction<K, V, F>> updater,
  ) transformFn;

  Disposable? _listener;

  OperatorCollectionsTransformAsMapResult({
    required this.source,
    required this.transformFn,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) : super(factory: factory);

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
    source.addDisposeWorker(() {
      return dispose();
    });
    super.onInit();
  }

  void _cancelListener() {
    _listener?.dispose();
    _listener = null;
  }

  void _initListener() {
    if (_listener != null) {
      return;
    }

    transformFn(
      source.value.asChange(),
      (final ObservableMapResultUpdateAction<K, V, F> action) {
        applyAction(action);
      },
    );

    _listener = source.listen(
      onChange: (final Observable<T> source) {
        final T state = source.value;
        transformFn(
          state.lastChange,
          (final ObservableMapResultUpdateAction<K, V, F> action) {
            applyAction(action);
          },
        );
      },
    );
  }
}

part of '../map/map.dart';

class OperatorCollectionsTransformAsMap<E, C, T extends CollectionState<E, C>, K, V> extends RxMapImpl<K, V> {
  final ObservableCollection<E, C, T> source;
  final void Function(
    C change,
    Emitter<ObservableMapUpdateAction<K, V>> updater,
  ) transformFn;

  Disposable? _listener;

  late final List<C> _bufferedChanges = <C>[];

  OperatorCollectionsTransformAsMap({
    required this.source,
    required this.transformFn,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  void onActive() {
    super.onActive();
    _initListener();
  }

  @override
  void onInit() {
    source.addDisposeWorker(() async {
      await _cancelListener();
      return dispose();
    });
    super.onInit();
  }

  Future<void> _cancelListener() async {
    await _listener?.dispose();
    _listener = null;
  }

  void _initListener() {
    if (_listener != null) {
      // apply buffered changes
      for (final C change in _bufferedChanges) {
        transformFn(
          change,
          (final ObservableMapUpdateAction<K, V> action) {
            applyAction(action);
          },
        );
      }
      _bufferedChanges.clear();
      return;
    }

    transformFn(
      source.value.asChange(),
      (final ObservableMapUpdateAction<K, V> action) {
        applyAction(action);
      },
    );

    _listener = source.listen(
      onChange: (final Observable<T> source) {
        final T value = source.value;
        final C change = value.lastChange;
        if (state == ObservableState.inactive) {
          // store changes to apply when active
          _bufferedChanges.add(change);
          return;
        }
        transformFn(
          value.lastChange,
          (final ObservableMapUpdateAction<K, V> action) {
            applyAction(action);
          },
        );
      },
    );
  }
}

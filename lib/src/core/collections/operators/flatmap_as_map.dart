import '../../../../dart_observable.dart';
import '../map/map.dart';

class OperatorCollectionsFlatMapAsMap<E, K, V, C, T extends CollectionState<E, C>> extends RxMapImpl<K, V> {
  final ObservableCollection<E, C, T> source;
  final ObservableCollectionFlatMapUpdate<E, K, ObservableMap<K, V>> Function(C change) sourceProvider;

  Disposable? _listener;

  final Map<E, ObservableMap<K, V>> _activeObservables = <E, ObservableMap<K, V>>{};
  final Map<E, Disposable> _activeObservablesDisposables = <E, Disposable>{};

  OperatorCollectionsFlatMapAsMap({
    required this.source,
    required this.sourceProvider,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  void onActive() {
    super.onActive();
    _initListener();
  }

  @override
  void onInit() {
    super.onInit();
    source.addDisposeWorker(() {
      return Future.wait([
        ..._activeObservablesDisposables.values.map((final Disposable value) async {
          value.dispose();
        }),
        dispose(),
      ]).then((_) {
        _activeObservablesDisposables.clear();
        _activeObservables.clear();
      });
    });
  }

  void _handleChange(final C change) {
    final ObservableCollectionFlatMapUpdate<E, K, ObservableMap<K, V>> sourceByValue = sourceProvider(change);
    final Map<E, ObservableMap<K, V>> registerObservables = sourceByValue.newObservables;
    final Set<E> unregisterObservablesKeys = sourceByValue.removedObservables;

    final Map<K, V> addItems = <K, V>{};
    final Set<K> removeItems = <K>{};

    for (final E key in unregisterObservablesKeys) {
      if (_activeObservables.containsKey(key)) {
        removeItems.addAll(_activeObservables[key]!.value.mapView.keys);
        _activeObservables.remove(key);
        _activeObservablesDisposables[key]?.dispose();
      }
    }

    registerObservables.forEach((final E key, final ObservableMap<K, V> value) {
      addItems.addAll(value.value.mapView);
      _activeObservables[key] = value;
      _activeObservablesDisposables[key] = value.listen(
        onChange: (final Observable<ObservableMapState<K, V>> source) {
          final ObservableMapState<K, V> value = source.value;
          final ObservableMapChange<K, V> change = value.lastChange;
          applyAction(
            ObservableMapUpdateAction<K, V>(
              addItems: <K, V>{
                ...change.added,
                ...change.updated.map(
                  (final K key, final ObservableItemChange<V> value) => MapEntry<K, V>(key, value.newValue),
                ),
              },
              removeItems: change.removed.keys,
            ),
          );
        },
      );
    });

    applyAction(
      ObservableMapUpdateAction<K, V>(
        addItems: addItems,
        removeItems: removeItems,
      ),
    );
  }

  void _initListener() {
    if (_listener != null) {
      // TODO buffer
      return;
    }

    final C initial = source.value.asChange();
    _handleChange(initial);

    _listener = source.listen(
      onChange: (final Observable<T> source) {
        final T value = source.value;
        final C change = value.lastChange;
        _handleChange(change);
      },
    );
  }
}

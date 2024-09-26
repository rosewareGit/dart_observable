import '../../../../../../dart_observable.dart';
import '../rx_impl.dart';

class ObservableMapMerged<K, V> extends RxMapImpl<K, V> {
  final List<ObservableMap<K, V>> collections;
  final V? Function(K key, V current, V conflict)? conflictResolver;

  late final List<Disposable> _subscriptions = <Disposable>[];

  late final Map<ObservableMap<K, V>, List<ObservableMapChange<K, V>>> _bufferedChanges =
      <ObservableMap<K, V>, List<ObservableMapChange<K, V>>>{};

  ObservableMapMerged({
    required this.collections,
    required this.conflictResolver,
    required super.factory,
  });

  @override
  void onActive() {
    super.onActive();
    _startCollect();
  }

  @override
  void onInit() {
    addDisposeWorker(() async {
      for (final Disposable e in _subscriptions) {
        await e.dispose();
      }
      await dispose();
    });
    super.onInit();
  }

  void _startCollect() {
    if (_subscriptions.isNotEmpty) {
      // apply buffered actions
      for (final MapEntry<ObservableMap<K, V>, List<ObservableMapChange<K, V>>> entry in _bufferedChanges.entries) {
        final ObservableMap<K, V> collection = entry.key;
        final List<ObservableMapChange<K, V>> changes = entry.value;

        for (final ObservableMapChange<K, V> change in changes) {
          _handleChange(collection: collection, change: change);
        }
      }
      _bufferedChanges.clear();
      return;
    }

    for (final ObservableMap<K, V> collection in collections) {
      _handleChange(collection: collection, change: collection.value.asChange());

      _subscriptions.add(
        collection.listen(
          onChange: (final ObservableMapState<K, V> value) {
            final ObservableMapChange<K, V> change = value.lastChange;
            if (state == ObservableState.inactive) {
              _bufferedChanges.putIfAbsent(collection, () {
                return <ObservableMapChange<K, V>>[];
              }).add(change);
              return;
            }

            _handleChange(collection: collection, change: change);
          },
        ),
      );
    }
  }

  static void handleChange<K, V>({
    required final ObservableMapChange<K, V> change,
    required final V? Function(K, V, V)? conflictResolver,
    required final V? Function(K key) currentValueProvider,
    required final V? Function(K key) getOtherValueOnRemove,
    required final void Function(ObservableMapUpdateAction<K, V> action) applyMapUpdateAction,
  }) {
    final Map<K, V> added = change.added;
    final Map<K, ObservableItemChange<V>> updated = change.updated;
    final Map<K, V> removed = change.removed;

    final Set<K> removedKeys = <K>{};

    if (conflictResolver != null) {
      for (final MapEntry<K, V> entry in added.entries) {
        final K key = entry.key;
        final V value = entry.value;
        final V? currentValue = currentValueProvider(key);
        if (currentValue != null) {
          final V? newValue = conflictResolver(key, currentValue, value);
          if (newValue != null) {
            added[key] = newValue;
          }
        }
      }
    }

    for (final MapEntry<K, ObservableItemChange<V>> entry in updated.entries) {
      final K key = entry.key;
      final V newValue = entry.value.newValue;
      final V? value = currentValueProvider(key);
      if (newValue != value) {
        added[key] = newValue;
      }
    }

    for (final K key in removed.keys) {
      // If the key exists in an other collection, then it is not removed
      final V? valueInOtherCollection = getOtherValueOnRemove(key);
      if (valueInOtherCollection == null) {
        removedKeys.add(key);
      } else {
        added[key] = valueInOtherCollection;
      }
    }

    applyMapUpdateAction(
      ObservableMapUpdateAction<K, V>(
        addItems: added,
        removeItems: removedKeys,
      ),
    );
  }

  void _handleChange({
    required final ObservableMap<K, V> collection,
    required final ObservableMapChange<K, V> change,
  }) {
    handleChange(
      change: change,
      conflictResolver: conflictResolver,
      currentValueProvider: (final K key) => this[key],
      applyMapUpdateAction: applyMapUpdateAction,
      getOtherValueOnRemove: (final K key) {
        for (final ObservableMap<K, V> otherCollection in collections) {
          if (otherCollection != collection && otherCollection.containsKey(key)) {
            return otherCollection[key];
          }
        }
        return null;
      },
    );
  }
}

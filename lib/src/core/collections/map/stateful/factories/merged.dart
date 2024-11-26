import '../../../../../../dart_observable.dart';
import '../../factories/merged.dart';
import '../rx_stateful.dart';

class ObservableStatefulMapMerged<K, V, S> extends RxStatefulMapImpl<K, V, S> {
  final Iterable<ObservableStatefulMap<K, V, S>> collections;
  final MergeConflictResolver<K, V>? conflictResolver;
  final Either<Map<K, V>, S>? Function(
    S state,
    Iterable<ObservableStatefulMap<K, V, S>> collections,
  )? stateResolver;

  late final List<Disposable> _subscriptions = <Disposable>[];

  late final Map<ObservableStatefulMap<K, V, S>, List<Either<ObservableMapChange<K, V>, S>>> _bufferedChanges =
      <ObservableStatefulMap<K, V, S>, List<Either<ObservableMapChange<K, V>, S>>>{};

  ObservableStatefulMapMerged({
    required this.collections,
    required this.conflictResolver,
    required this.stateResolver,
    required super.factory,
  }) : super(<K, V>{});

  void handleChange({
    required final ObservableStatefulMap<K, V, S> collection,
    required final Either<ObservableMapChange<K, V>, S> change,
  }) {
    change.fold(
      onLeft: (final ObservableMapChange<K, V> change) {
        ObservableMapMerged.handleChange(
          change: change,
          conflictResolver: this.conflictResolver,
          currentValueProvider: (final K key) => this[key],
          applyMapUpdateAction: applyMapUpdateAction,
          getOtherValueOnRemove: (final K key) {
            for (final ObservableStatefulMap<K, V, S> otherCollection in collections) {
              if (otherCollection != collection && otherCollection.containsKey(key)) {
                return otherCollection[key];
              }
            }
            return null;
          },
        );
      },
      onRight: (final S state) {
        _handleCustomState(state, collection);
      },
    );
  }

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

  void _handleCustomState(
    final S state,
    final ObservableStatefulMap<K, V, S> collection,
  ) {
    final Either<Map<K, V>, S>? Function(
      S state,
      Iterable<ObservableStatefulMap<K, V, S>> collections,
    )? stateResolver = this.stateResolver;

    if (stateResolver != null) {
      final Either<Map<K, V>, S>? newState = stateResolver(state, collections);
      if (newState != null) {
        newState.fold(
          onLeft: (final Map<K, V> newState) {
            setData(newState);
          },
          onRight: (final S newState) {
            setState(newState);
          },
        );
      }
    } else {
      final Either<Map<K, V>, S>? previous = collection.previous;
      if (previous != null) {
        previous.when(
          onLeft: (final  Map<K, V> data) {
            handleChange(
              collection: collection,
              change: Either<ObservableMapChange<K, V>, S>.left(
                ObservableMapChange<K, V>(removed: data),
              ),
            );
          },
        );
      }
    }
  }

  void _startCollect() {
    if (_subscriptions.isNotEmpty) {
      // apply buffered actions
      for (final MapEntry<ObservableStatefulMap<K, V, S>, List<Either<ObservableMapChange<K, V>, S>>> entry
          in _bufferedChanges.entries) {
        final ObservableStatefulMap<K, V, S> collection = entry.key;
        final List<Either<ObservableMapChange<K, V>, S>> changes = entry.value;

        for (final Either<ObservableMapChange<K, V>, S> change in changes) {
          handleChange(collection: collection, change: change);
        }
      }
      _bufferedChanges.clear();
      return;
    }

    for (final ObservableStatefulMap<K, V, S> collection in collections) {
      handleChange(collection: collection, change: collection.currentStateAsChange);

      _subscriptions.add(
        collection.onChange(
          onChange: (final Either<ObservableMapChange<K, V>, S> change) {
            if (state == ObservableState.inactive) {
              _bufferedChanges.putIfAbsent(collection, () {
                return <Either<ObservableMapChange<K, V>, S>>[];
              }).add(change);
              return;
            }

            handleChange(collection: collection, change: change);
          },
        ),
      );
    }
  }
}

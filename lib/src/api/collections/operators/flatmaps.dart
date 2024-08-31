import '../../../../dart_observable.dart';

/// Transforms [this] collection values into a new [ObservableList] of type [E2].
/// Listens on the changes of the added ObservableList and updates the resulting ObservableList accordingly.
/// Can remove observables when a value is removed from [this] collection.
/// Example:
/// The result of this transformation is a list of all items in the collection for the selected types.
/// Given type of vehicles. When a new type is added, the result list will be updated with the new items.
/// When a new item is added to the source collection, the result list will be updated with the new item as well.
/// When a type is removed, the items of that type will be removed from the result list.
abstract interface class ObservableCollectionFlatMaps<C> {
  ObservableList<E2> list<E2>({
    required final ObservableCollectionFlatMapUpdate<ObservableList<E2>>? Function(C change) sourceProvider,
    final FactoryList<E2>? factory,
  });

  ObservableMap<K, V> map<K, V>({
    required final ObservableCollectionFlatMapUpdate<ObservableMap<K, V>> Function(C change) sourceProvider,
    final FactoryMap<K, V>? factory,
  });

  ObservableSet<E2> set<E2>({
    required final ObservableCollectionFlatMapUpdate<ObservableSet<E2>> Function(C change) sourceProvider,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  });
}

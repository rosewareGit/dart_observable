import '../../../../dart_observable.dart';
import 'flatmaps/list.dart';
import 'flatmaps/map.dart';
import 'flatmaps/set.dart';

class ObservableCollectionFlatMapsImpl<Self extends Observable<T>, T extends CollectionState<C>, C>
    implements ObservableFlatMaps<C> {
  final Self source;

  ObservableCollectionFlatMapsImpl(this.source);

  @override
  ObservableList<E2> list<E2>({
    required final ObservableCollectionFlatMapUpdate<ObservableList<E2>>? Function(C change) sourceProvider,
    final FactoryList<E2>? factory,
  }) {
    return OperatorCollectionsFlatMapAsList<E2, C, T>(
      source: source,
      sourceProvider: sourceProvider,
      factory: factory,
    );
  }

  @override
  ObservableMap<K, V> map<K, V>({
    required final ObservableCollectionFlatMapUpdate<ObservableMap<K, V>> Function(C change) sourceProvider,
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorCollectionsFlatMapAsMap<K, K, V, C, T>(
      source: source,
      sourceProvider: sourceProvider,
      factory: factory,
    );
  }

  @override
  ObservableSet<E2> set<E2>({
    required final ObservableCollectionFlatMapUpdate<ObservableSet<E2>> Function(C change) sourceProvider,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  }) {
    return OperatorCollectionsFlatMapAsSet<E2, C, T>(
      source: source,
      sourceProvider: sourceProvider,
      factory: factory,
    );
  }
}

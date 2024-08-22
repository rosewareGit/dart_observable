import '../../../../dart_observable.dart';
import '../../../api/change_tracking_observable.dart';
import 'flatmaps/list.dart';
import 'flatmaps/map.dart';
import 'flatmaps/set.dart';

class ObservableCollectionFlatMapsImpl<Self extends ChangeTrackingObservable<Self, T, C>, T, C>
    implements ObservableCollectionFlatMaps<C> {
  final Self source;

  ObservableCollectionFlatMapsImpl(this.source);

  @override
  ObservableList<E2> list<E, E2>({
    required final ObservableCollectionFlatMapUpdate<E, E2, ObservableList<E2>>? Function(C change) sourceProvider,
    final FactoryList<E2>? factory,
  }) {
    return OperatorCollectionsFlatMapAsList<Self, E, E2, C, T>(
      source: source,
      sourceProvider: sourceProvider,
      factory: factory,
    );
  }

  @override
  ObservableMap<K, V> map<K, V>({
    required final ObservableCollectionFlatMapUpdate<K, K, ObservableMap<K, V>> Function(C change) sourceProvider,
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorCollectionsFlatMapAsMap<Self, K, K, V, C, T>(
      source: source,
      sourceProvider: sourceProvider,
      factory: factory,
    );
  }

  @override
  ObservableSet<E2> set<E, E2>({
    required final ObservableCollectionFlatMapUpdate<E, E2, ObservableSet<E2>> Function(C change) sourceProvider,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  }) {
    return OperatorCollectionsFlatMapAsSet<Self, E, E2, C, T>(
      source: source,
      sourceProvider: sourceProvider,
      factory: factory,
    );
  }
}

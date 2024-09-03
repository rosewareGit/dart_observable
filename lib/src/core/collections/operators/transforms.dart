import '../../../../dart_observable.dart';
import 'transforms/list.dart';
import 'transforms/lists/_lists.dart';
import 'transforms/map.dart';
import 'transforms/maps/_maps.dart';
import 'transforms/set.dart';
import 'transforms/sets/_sets.dart';

class ObservableTransformsImpl<CS extends CollectionState<C>, C> implements ObservableTransforms<C> {
  final Observable<CS> source;

  ObservableTransformsImpl(this.source);

  @override
  OperatorsTransformLists<C> get lists => OperatorsCollectionTransformListsImpl<CS, C>(source);

  @override
  OperatorsTransformMaps<C> get maps => OperatorsCollectTransformMapsImpl<CS, C>(source);

  @override
  OperatorsTransformSets<C> get sets => OperatorsCollectionTransformSetsImpl<CS, C>(source);

  @override
  ObservableList<E> list<E>({
    required final ListUpdater<E, C> transform,
    final FactoryList<E>? factory,
  }) {
    return OperatorCollectionTransformAsListArg<E, C, CS>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableMap<K, V> map<K, V>({
    required final MapUpdater<K, V, C> transform,
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorCollectionTransformAsMapArg<C, CS, K, V>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableSet<E> set<E>({
    required final SetUpdater<E, C> transform,
    final Set<E> Function(Iterable<E>? items)? factory,
  }) {
    return OperatorCollectionTransformAsSetArg<E, C, CS>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}

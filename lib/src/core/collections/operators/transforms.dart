import '../../../../dart_observable.dart';
import '../../../api/change_tracking_observable.dart';
import '../../../api/collections/operators/transforms/maps.dart';
import '../../../api/collections/operators/transforms/sets.dart';
import '../map/map.dart';
import 'transforms/list.dart';
import 'transforms/lists/_lists.dart';
import 'transforms/set.dart';

class ObservableCollectionTransformsImpl<Self extends ChangeTrackingObservable<Self, CS, C>, CS, C>
    implements ObservableCollectionTransforms<C> {
  final Self source;

  ObservableCollectionTransformsImpl(this.source);

  @override
  OperatorsTransformLists<C> get lists => OperatorsTransformListsImpl<Self, C, CS>(source);

  @override
  OperatorsTransformMaps<C> get maps => throw UnimplementedError();

  @override
  OperatorsTransformSets<C> get sets => throw UnimplementedError();

  @override
  ObservableList<E2> list<E2>({
    required final void Function(
      ObservableList<E2> state,
      C change,
      Emitter<ObservableListUpdateAction<E2>> updater,
    ) transform,
    final FactoryList<E2>? factory,
  }) {
    return OperatorTransformAsListArg<Self, E2, C, CS>(
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
    return OperatorTransformAsMapArg<Self, C, CS, K, V>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableSet<E2> set<E2>({
    required final void Function(
      ObservableSet<E2> state,
      C change,
      Emitter<ObservableSetUpdateAction<E2>> updater,
    ) transform,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  }) {
    return OperatorCollectionsTransformAsSet<Self, E2, C, CS>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}

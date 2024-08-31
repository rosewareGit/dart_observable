import '../../../../dart_observable.dart';
import '../../../api/change_tracking_observable.dart';
import '../map/rx_impl.dart';
import 'transforms/list.dart';
import 'transforms/lists/_lists.dart';
import 'transforms/maps/_maps.dart';
import 'transforms/set.dart';
import 'transforms/sets/_sets.dart';

class ObservableCollectionTransformsImpl<Self extends ChangeTrackingObservable<Self, CS, C>, CS, C>
    implements ObservableCollectionTransforms<C> {
  final Self source;

  ObservableCollectionTransformsImpl(this.source);

  @override
  OperatorsTransformLists<C> get lists => OperatorsTransformListsImpl<Self, C, CS>(source);

  @override
  OperatorsTransformMaps<C> get maps => OperatorsTransformMapsImpl<Self, C, CS>(source);

  @override
  OperatorsTransformSets<C> get sets => OperatorsTransformSetsImpl<Self, C, CS>(source);

  @override
  ObservableList<E> list<E>({
    required final ListUpdater<E, C> transform,
    final FactoryList<E>? factory,
  }) {
    return OperatorTransformAsListArg<Self, E, C, CS>(
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
  ObservableSet<E> set<E>({
    required final SetUpdater<E, C> transform,
    final Set<E> Function(Iterable<E>? items)? factory,
  }) {
    return OperatorTransformAsSetArg<Self, E, C, CS>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}

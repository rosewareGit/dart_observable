import '../../../../dart_observable.dart';
import '../../collections/map/rx_impl.dart';
import 'transforms/lists/_lists.dart';
import 'transforms/maps/_maps.dart';
import 'transforms/sets/_sets.dart';
import 'transforms/list.dart';
import 'transforms/set.dart';

class ObservableTransformsImpl<T> implements ObservableTransforms<T> {
  final Observable<T> source;

  ObservableTransformsImpl(this.source);

  @override
  OperatorsTransformLists<T> get lists => OperatorsTransformListsImpl<T>(source);

  @override
  OperatorsTransformMaps<T> get maps => OperatorsTransformMapsImpl<T>(source);

  @override
  OperatorsTransformSets<T> get sets => OperatorsTransformSetsImpl<T>(source);

  @override
  ObservableList<E> list<E>({
    required final ListUpdater<E, T> transform,
    final FactoryList<E>? factory,
  }) {
    return OperatorTransformAsListArg<T, E>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableMap<K, V> map<K, V>({
    required final MapUpdater<K, V, T> transform,
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorTransformAsMapArg<T, K, V>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableSet<E> set<E>({
    required final SetUpdater<E, T> transform,
    final Set<E> Function(Iterable<E>? items)? factory,
  }) {
    return OperatorTransformAsSetArg<T, E>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}

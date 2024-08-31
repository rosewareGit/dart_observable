import '../../../../../../dart_observable.dart';
import '../../map_state.dart';
import '../../rx_impl.dart';
import '../operators/map_item.dart';
import '../rx_stateful.dart';
import '../state.dart';

class RxMapFailureImpl<K, V, F> extends RxMapStatefulImpl<RxMapFailure<K, V, F>, ObservableMapFailure<K, V, F>, K, V, F>
    implements RxMapFailure<K, V, F> {
  RxMapFailureImpl({
    final Map<K, V>? initial,
    final FactoryMap<K, V>? factory,
  }) : this._(
          state: () {
            final FactoryMap<K, V> $factory = factory ?? defaultMapFactory();
            final Map<K, V> list = $factory(initial ?? <K, V>{});
            return RxMapStatefulState<K, V, F>.data(RxMapState<K, V>.initial(list));
          }(),
          factory: factory,
        );

  factory RxMapFailureImpl.failure({
    required final F failure,
    final FactoryMap<K, V>? factory,
  }) {
    return RxMapFailureImpl<K, V, F>._(
      state: RxMapStatefulState<K, V, F>.custom(failure),
      factory: factory,
    );
  }

  RxMapFailureImpl._({
    required final ObservableMapStatefulState<K, V, F> state,
    final FactoryMap<K, V>? factory,
  }) : super(state, factory: factory);

  @override
  set failure(final F failure) {
    setState(failure);
  }

  @override
  ObservableMapFailure<K, V, F> get self => this;

  @override
  RxMapFailure<K, V, F> builder({
    final Map<K, V>? items,
    final FactoryMap<K, V>? factory,
  }) {
    return RxMapFailureImpl<K, V, F>(
      initial: items,
      factory: factory,
    );
  }

  @override
  ObservableMapFailure<K, V2, F> mapItem<V2>(
    final V2 Function(K key, V value) valueMapper, {
    final FactoryMap<K, V2>? factory,
  }) {
    final RxMapFailure<K, V2, F> instance = RxMapFailure<K, V2, F>(factory: factory);
    OperatorStatefulMapMapItem<RxMapFailure<K, V2, F>, ObservableMapFailure<K, V2, F>, ObservableMapFailure<K, V, F>, K,
        V, V2, F>(
      source: self,
      mapper: valueMapper,
      instanceBuilder: () => instance,
    );
    return instance.asObservable();
  }
}

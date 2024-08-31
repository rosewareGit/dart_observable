import '../../../../../../dart_observable.dart';
import '../../map_state.dart';
import '../../rx_impl.dart';
import '../operators/map_item.dart';
import '../rx_stateful.dart';
import '../state.dart';

class RxMapUndefinedImpl<K, V>
    extends RxMapStatefulImpl<RxMapUndefined<K, V>, ObservableMapUndefined<K, V>, K, V, Undefined>
    implements RxMapUndefined<K, V> {
  RxMapUndefinedImpl({
    final Map<K, V>? initial,
    final FactoryMap<K, V>? factory,
  }) : this._(
          state: () {
            if (initial == null) {
              RxMapStatefulState<K, V, Undefined>.custom(Undefined());
            }
            final FactoryMap<K, V> $factory = factory ?? defaultMapFactory();
            final Map<K, V> list = $factory(initial);
            return RxMapStatefulState<K, V, Undefined>.data(RxMapState<K, V>.initial(list));
          }(),
          factory: factory,
        );

  factory RxMapUndefinedImpl.undefined({
    final FactoryMap<K, V>? factory,
  }) {
    return RxMapUndefinedImpl<K, V>._(
      state: RxMapStatefulState<K, V, Undefined>.custom(Undefined()),
      factory: factory,
    );
  }

  RxMapUndefinedImpl._({
    required final ObservableMapStatefulState<K, V, Undefined> state,
    final FactoryMap<K, V>? factory,
  }) : super(state, factory: factory);

  @override
  ObservableMapUndefined<K, V> get self => this;

  @override
  RxMapUndefined<K, V> builder({
    final Map<K, V>? items,
    final FactoryMap<K, V>? factory,
  }) {
    return RxMapUndefinedImpl<K, V>(
      initial: items,
      factory: factory,
    );
  }

  @override
  ObservableMapUndefined<K, V2> mapItem<V2>(
    final V2 Function(K key, V value) valueMapper, {
    final FactoryMap<K, V2>? factory,
  }) {
    final RxMapUndefined<K, V2> instance = RxMapUndefinedImpl<K, V2>(factory: factory);
    OperatorStatefulMapMapItem<RxMapUndefined<K, V2>, ObservableMapUndefined<K, V2>, ObservableMapUndefined<K, V>, K, V,
        V2, Undefined>(
      source: self,
      mapper: valueMapper,
      instanceBuilder: () => instance,
    );
    return instance.asObservable();
  }

  @override
  void setUndefined() {
    setState(Undefined());
  }
}

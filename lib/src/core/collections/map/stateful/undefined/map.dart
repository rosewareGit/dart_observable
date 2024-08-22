import '../../../../../../dart_observable.dart';
import '../../map.dart';
import '../../map_state.dart';
import '../map.dart';
import '../state.dart';

class RxMapUndefinedImpl<K, V> extends RxMapStatefulImpl<ObservableMapUndefined<K, V>, K, V, Undefined>
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
}

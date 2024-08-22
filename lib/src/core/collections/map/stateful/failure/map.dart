import '../../../../../../dart_observable.dart';
import '../../map.dart';
import '../../map_state.dart';
import '../map.dart';
import '../state.dart';

class RxMapFailureImpl<K, V, F> extends RxMapStatefulImpl<ObservableMapFailure<K, V, F>, K, V, F>
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
  ObservableMapFailure<K, V, F> get self => this;
}

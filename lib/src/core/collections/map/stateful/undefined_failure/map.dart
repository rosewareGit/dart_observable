import '../../../../../../dart_observable.dart';
import '../../map.dart';
import '../map.dart';
import 'state.dart';

RxMapUndefinedFailureState<K, V, F> _initialState<K, V, F>({
  required final Map<K, V>? initial,
  required final FactoryMap<K, V>? factory,
}) {
  if (initial == null) {
    return RxMapUndefinedFailureState<K, V, F>.undefined();
  }

  final FactoryMap<K, V> $factory = factory ?? defaultMapFactory();
  return RxMapUndefinedFailureState<K, V, F>.data($factory(initial));
}

class RxMapUndefinedFailureImpl<K, V, F>
    extends RxMapStatefulImpl<ObservableMapUndefinedFailure<K, V, F>, K, V, UndefinedFailure<F>>
    implements RxMapUndefinedFailure<K, V, F> {
  RxMapUndefinedFailureImpl({
    final FactoryMap<K, V>? factory,
  }) : super(
          RxMapUndefinedFailureState<K, V, F>.undefined(),
          factory: factory,
        );

  factory RxMapUndefinedFailureImpl.custom({
    final FactoryMap<K, V>? factory,
    final Map<K, V>? initial,
  }) {
    return RxMapUndefinedFailureImpl<K, V, F>._(
      state: _initialState<K, V, F>(
        initial: initial,
        factory: factory,
      ),
      factory: factory,
    );
  }

  factory RxMapUndefinedFailureImpl.failure({
    required final F failure,
    final FactoryMap<K, V>? factory,
  }) {
    return RxMapUndefinedFailureImpl<K, V, F>._(
      state: RxMapUndefinedFailureState<K, V, F>.failure(failure),
      factory: factory,
    );
  }

  RxMapUndefinedFailureImpl._({
    required final RxMapUndefinedFailureState<K, V, F> state,
    final FactoryMap<K, V>? factory,
  }) : super(state, factory: factory);

  @override
  ObservableMapUndefinedFailure<K, V, F> get self => this;
}

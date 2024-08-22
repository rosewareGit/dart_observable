import '../../../../../../dart_observable.dart';
import '../../set.dart';
import '../../set_state.dart';
import '../set.dart';
import '../state.dart';

class RxSetFailureImpl<E, F> extends RxSetStatefulImpl<ObservableSetFailure<E, F>, E, F> implements RxSetResult<E, F> {
  RxSetFailureImpl({
    final Iterable<E>? initial,
    final FactorySet<E>? factory,
  }) : this._(
          state: () {
            final FactorySet<E> $factory = factory ?? defaultSetFactory();
            final Set<E> set = $factory(initial ?? <E>[]);
            return RxSetStatefulState<E, F>.data(RxSetState<E>.initial(set));
          }(),
          factory: factory,
        );

  factory RxSetFailureImpl.failure({
    required final F failure,
    final FactorySet<E>? factory,
  }) {
    return RxSetFailureImpl<E, F>._(
      state: RxSetStatefulState<E, F>.custom(failure),
      factory: factory,
    );
  }

  RxSetFailureImpl._({
    required final ObservableSetStatefulState<E, F> state,
    final FactorySet<E>? factory,
  }) : super(state, factory: factory);

  @override
  ObservableSetFailure<E, F> get self => this;
}

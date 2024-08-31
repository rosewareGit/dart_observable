import '../../../../../../dart_observable.dart';
import '../../rx_impl.dart';
import '../../set_state.dart';
import '../operators/map_item.dart';
import '../rx_stateful_impl.dart';
import '../state.dart';

class RxSetFailureImpl<E, F> extends RxSetStatefulImpl<RxSetFailure<E, F>, ObservableSetFailure<E, F>, E, F>
    implements RxSetFailure<E, F> {
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

  @override
  RxSetFailure<E, F> builder({
    final Iterable<E>? items,
    final FactorySet<E>? factory,
  }) {
    return RxSetFailureImpl<E, F>(
      initial: items,
      factory: factory,
    );
  }

  @override
  ObservableSetFailure<E2, F> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactorySet<E2>? factory,
  }) {
    final RxSetFailure<E2, F> instance = RxSetFailureImpl<E2, F>(factory: factory);
    OperatorStatefulSetMapItem<RxSetFailure<E2, F>, ObservableSetFailure<E2, F>, ObservableSetFailure<E, F>, E, E2, F>(
      source: self,
      mapper: mapper,
      instanceBuilder: () => instance,
    );
    return instance.asObservable();
  }
}

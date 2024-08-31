import '../../../../../../dart_observable.dart';
import '../../list_state.dart';
import '../../rx_impl.dart';
import '../operators/map_item.dart';
import '../rx_stateful.dart';
import '../state.dart';

class RxListFailureImpl<E, F> extends RxListStatefulImpl<RxListFailure<E, F>, ObservableListFailure<E, F>, E, F>
    implements RxListFailure<E, F> {
  RxListFailureImpl({
    final Iterable<E>? initial,
    final FactoryList<E>? factory,
  }) : this._(
          state: () {
            final FactoryList<E> $factory = factory ?? defaultListFactory();
            final List<E> list = $factory(initial ?? <E>[]);
            return RxListStatefulState<E, F>.data(RxListState<E>.initial(list));
          }(),
          factory: factory,
        );

  factory RxListFailureImpl.failure({
    required final F failure,
    final FactoryList<E>? factory,
  }) {
    return RxListFailureImpl<E, F>._(
      state: RxListStatefulState<E, F>.custom(failure),
      factory: factory,
    );
  }

  RxListFailureImpl._({
    required final ObservableListStatefulState<E, F> state,
    final FactoryList<E>? factory,
  }) : super(state, factory: factory);

  @override
  set failure(final F failure) {
    setState(failure);
  }

  @override
  RxListFailure<E, F> get self => this;

  @override
  RxListFailure<E, F> builder({
    final List<E>? items,
    final FactoryList<E>? factory,
  }) {
    return RxListFailure<E, F>(initial: items, factory: factory);
  }

  @override
  ObservableListFailure<E2, F> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactoryList<E2>? factory,
  }) {
    final RxListFailure<E2, F> instance = RxListFailureImpl<E2, F>(factory: factory);
    OperatorStatefulListMapItem<RxListFailure<E2, F>, ObservableListFailure<E2, F>, ObservableListFailure<E, F>, E, E2,
        F>(
      source: self,
      mapper: mapper,
      instanceBuilder: () => instance,
    );
    return instance.asObservable();
  }
}

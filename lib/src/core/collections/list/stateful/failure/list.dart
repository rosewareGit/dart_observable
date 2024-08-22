import '../../../../../../dart_observable.dart';
import '../../list.dart';
import '../../list_state.dart';
import '../list.dart';
import '../state.dart';

class RxListFailureImpl<E, F> extends RxListStatefulImpl<ObservableListFailure<E, F>, E, F>
    implements RxListResult<E, F> {
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
  ObservableListFailure<E, F> get self => this;
}

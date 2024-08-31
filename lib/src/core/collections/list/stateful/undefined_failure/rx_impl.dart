import '../../../../../../dart_observable.dart';
import '../../rx_impl.dart';
import '../operators/map_item.dart';
import '../rx_stateful.dart';
import 'state.dart';

RxListUndefinedFailureState<E, F> _initialState<E, F>({
  required final Iterable<E>? initial,
  required final FactoryList<E>? factory,
}) {
  if (initial == null) {
    return RxListUndefinedFailureState<E, F>.undefined();
  }

  final List<E> data = initial.toList();
  final FactoryList<E> $factory = factory ?? defaultListFactory();
  return RxListUndefinedFailureState<E, F>.data($factory(data));
}

class RxListUndefinedFailureImpl<E, F> extends RxListStatefulImpl<RxListUndefinedFailure<E, F>,
    ObservableListUndefinedFailure<E, F>, E, UndefinedFailure<F>> implements RxListUndefinedFailure<E, F> {
  RxListUndefinedFailureImpl({
    final FactoryList<E>? factory,
  }) : super(
          RxListUndefinedFailureState<E, F>.undefined(),
          factory: factory,
        );

  factory RxListUndefinedFailureImpl.custom({
    final FactoryList<E>? factory,
    final Iterable<E>? initial,
  }) {
    return RxListUndefinedFailureImpl<E, F>._(
      state: _initialState<E, F>(
        initial: initial,
        factory: factory,
      ),
      factory: factory,
    );
  }

  factory RxListUndefinedFailureImpl.failure({
    required final F failure,
    final FactoryList<E>? factory,
  }) {
    return RxListUndefinedFailureImpl<E, F>._(
      state: RxListUndefinedFailureState<E, F>.failure(failure),
      factory: factory,
    );
  }

  RxListUndefinedFailureImpl._({
    required final RxListUndefinedFailureState<E, F> state,
    final FactoryList<E>? factory,
  }) : super(state, factory: factory);

  @override
  set failure(final F failure) {
    setState(UndefinedFailure<F>.failure(failure));
  }

  @override
  ObservableListUndefinedFailure<E, F> get self => this;

  @override
  RxListUndefinedFailure<E, F> builder({final List<E>? items, final FactoryList<E>? factory}) {
    return RxListUndefinedFailure<E, F>(
      factory: factory,
      initial: items,
    );
  }

  @override
  ObservableListUndefinedFailure<E2, F> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactoryList<E2>? factory,
  }) {
    final RxListUndefinedFailure<E2, F> instance = RxListUndefinedFailureImpl<E2, F>(factory: factory);
    OperatorStatefulListMapItem<RxListUndefinedFailure<E2, F>, ObservableListUndefinedFailure<E2, F>,
        ObservableListUndefinedFailure<E, F>, E, E2, UndefinedFailure<F>>(
      source: self,
      mapper: mapper,
      instanceBuilder: () => instance,
    );
    return instance.asObservable();
  }

  @override
  void setUndefined() {
    setState(UndefinedFailure<F>.undefined());
  }
}

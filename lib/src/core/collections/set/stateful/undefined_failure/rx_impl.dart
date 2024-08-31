import '../../../../../../dart_observable.dart';
import '../../rx_impl.dart';
import '../operators/map_item.dart';
import '../rx_stateful_impl.dart';
import 'state.dart';

RxSetUndefinedFailureState<E, F> _initialState<E, F>({
  required final Iterable<E>? initial,
  required final FactorySet<E>? factory,
}) {
  if (initial == null) {
    return RxSetUndefinedFailureState<E, F>.undefined();
  }

  final Set<E> data = initial.toSet();
  final FactorySet<E> $factory = factory ?? defaultSetFactory();
  return RxSetUndefinedFailureState<E, F>.data($factory(data));
}

class RxSetUndefinedFailureImpl<E, F>
    extends RxSetStatefulImpl<RxSetUndefinedFailure<E, F>, ObservableSetUndefinedFailure<E, F>, E, UndefinedFailure<F>>
    implements RxSetUndefinedFailure<E, F> {
  RxSetUndefinedFailureImpl({
    final FactorySet<E>? factory,
  }) : super(
          RxSetUndefinedFailureState<E, F>.undefined(),
          factory: factory,
        );

  factory RxSetUndefinedFailureImpl.custom({
    final FactorySet<E>? factory,
    final Iterable<E>? initial,
  }) {
    return RxSetUndefinedFailureImpl<E, F>._(
      state: _initialState<E, F>(
        initial: initial,
        factory: factory,
      ),
      factory: factory,
    );
  }

  factory RxSetUndefinedFailureImpl.failure({
    required final F failure,
    final FactorySet<E>? factory,
  }) {
    return RxSetUndefinedFailureImpl<E, F>._(
      state: RxSetUndefinedFailureState<E, F>.failure(failure),
      factory: factory,
    );
  }

  RxSetUndefinedFailureImpl._({
    required final RxSetUndefinedFailureState<E, F> state,
    final FactorySet<E>? factory,
  }) : super(state, factory: factory);

  @override
  ObservableSetUndefinedFailure<E, F> get self => this;

  @override
  RxSetUndefinedFailure<E, F> builder({
    final Iterable<E>? items,
    final FactorySet<E>? factory,
  }) {
    return RxSetUndefinedFailureImpl<E, F>.custom(
      factory: factory,
      initial: items,
    );
  }

  @override
  ObservableSetUndefinedFailure<E2, F> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactorySet<E2>? factory,
  }) {
    final RxSetUndefinedFailure<E2, F> instance = RxSetUndefinedFailureImpl<E2, F>.custom(
      factory: factory,
    );
    OperatorStatefulSetMapItem<RxSetUndefinedFailure<E2, F>, ObservableSetUndefinedFailure<E2, F>,
        ObservableSetUndefinedFailure<E, F>, E, E2, UndefinedFailure<F>>(
      source: self,
      mapper: mapper,
      instanceBuilder: () => instance,
    );
    return instance.asObservable();
  }

  @override
  set failure(final F failure) {
    setState(UndefinedFailure<F>.failure(failure));
  }

  @override
  void setUndefined() {
    setState(UndefinedFailure<F>.undefined());
  }
}

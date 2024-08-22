import '../../../../../../dart_observable.dart';
import '../../list.dart';
import '../list.dart';
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

class RxListUndefinedFailureImpl<E, F>
    extends RxListStatefulImpl<ObservableListUndefinedFailure<E, F>, E, UndefinedFailure<F>>
    implements RxListUndefinedFailure<E, F> {
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
  ObservableListUndefinedFailure<E, F> get self => this;
}

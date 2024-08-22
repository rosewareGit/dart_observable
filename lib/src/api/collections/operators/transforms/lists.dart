import '../../../../../dart_observable.dart';

abstract interface class OperatorsTransformLists<C> {
  ObservableListFailure<E2, F> failure<E2, F>({
    required final void Function(
      ObservableListFailure<E2, F> state,
      C change,
      Emitter<StateOf<ObservableListUpdateAction<E2>, F>> updater,
    ) transform,
    final FactoryList<E2>? factory,
  });

  ObservableListUndefined<E2> undefined<E2>({
    required final void Function(
      ObservableListUndefined<E2> state,
      C change,
      Emitter<StateOf<ObservableListUpdateAction<E2>, Undefined>> updater,
    ) transform,
    final FactoryList<E2>? factory,
  });

  ObservableListUndefinedFailure<E2, F> undefinedFailure<E2, F>({
    required final void Function(
      ObservableListUndefinedFailure<E2, F> state,
      C change,
      Emitter<StateOf<ObservableListUpdateAction<E2>, UndefinedFailure<F>>> updater,
    ) transform,
    final FactoryList<E2>? factory,
  });
}

import '../../../../../dart_observable.dart';

abstract interface class OperatorsTransformSets<C> {
  ObservableSetFailure<E2, F> failure<E2, F>({
    required final void Function(
      ObservableSetFailure<E2, F> state,
      C change,
      Emitter<StateOf<ObservableSetUpdateAction<E2>, F>> updater,
    ) transform,
    final FactorySet<E2>? factory,
  });

  ObservableSetUndefined<E2> undefined<E2>({
    required final void Function(
      ObservableSetUndefined<E2> state,
      C change,
      Emitter<StateOf<ObservableSetUpdateAction<E2>, Undefined>> updater,
    ) transform,
    final FactorySet<E2>? factory,
  });

  ObservableSetUndefinedFailure<E2, F> undefinedFailure<E2, F>({
    required final void Function(
      ObservableSetUndefinedFailure<E2, F> state,
      C change,
      Emitter<StateOf<ObservableSetUpdateAction<E2>, UndefinedFailure<F>>> updater,
    ) transform,
    final FactorySet<E2>? factory,
  });
}

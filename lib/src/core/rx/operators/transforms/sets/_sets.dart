import '../../../../../../dart_observable.dart';
import 'failure.dart';
import 'undefined.dart';
import 'undefined_failure.dart';

class OperatorsTransformSetsImpl<T> implements OperatorsTransformSets<T> {
  final Observable<T> source;

  OperatorsTransformSetsImpl(this.source);

  @override
  ObservableSetFailure<E2, F> failure<E2, F>({
    required final void Function(
      ObservableSetFailure<E2, F> state,
      T value,
      Emitter<StateOf<ObservableSetUpdateAction<E2>, F>> updater,
    ) transform,
    final FactorySet<E2>? factory,
  }) {
    return TransformSetFailureImpl<F, E2, T>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableSetUndefined<E2> undefined<E2>({
    required final void Function(
      ObservableSetUndefined<E2> state,
      T value,
      Emitter<StateOf<ObservableSetUpdateAction<E2>, Undefined>> updater,
    ) transform,
    final FactorySet<E2>? factory,
  }) {
    return TransformSetUndefinedImpl<E2, T>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableSetUndefinedFailure<E2, F> undefinedFailure<E2, F>({
    required final void Function(
      ObservableSetUndefinedFailure<E2, F> state,
      T value,
      Emitter<StateOf<ObservableSetUpdateAction<E2>, UndefinedFailure<F>>> updater,
    ) transform,
    final FactorySet<E2>? factory,
  }) {
    return TransformSetUndefinedFailureImpl<E2, F, T>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}

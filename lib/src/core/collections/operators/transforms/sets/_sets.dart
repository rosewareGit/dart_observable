import '../../../../../../dart_observable.dart';
import 'failure.dart';
import 'undefined.dart';
import 'undefined_failure.dart';

class OperatorsCollectionTransformSetsImpl<CS extends CollectionState<C>, C> implements OperatorsTransformSets<C> {
  final Observable<CS> source;

  OperatorsCollectionTransformSetsImpl(this.source);

  @override
  ObservableSetFailure<E, F> failure<E, F>({
    required final void Function(
      ObservableSetFailure<E, F> state,
      C value,
      Emitter<StateOf<ObservableSetUpdateAction<E>, F>> updater,
    ) transform,
    final FactorySet<E>? factory,
  }) {
    return TransformCollectionSetFailureImpl<F, E, CS, C>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableSetUndefined<E> undefined<E>({
    required final void Function(
      ObservableSetUndefined<E> state,
      C value,
      Emitter<StateOf<ObservableSetUpdateAction<E>, Undefined>> updater,
    ) transform,
    final FactorySet<E>? factory,
  }) {
    return TransformCollectionSetUndefinedImpl<E, CS, C>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableSetUndefinedFailure<E, F> undefinedFailure<E, F>({
    required final void Function(
      ObservableSetUndefinedFailure<E, F> state,
      C value,
      Emitter<StateOf<ObservableSetUpdateAction<E>, UndefinedFailure<F>>> updater,
    ) transform,
    final FactorySet<E>? factory,
  }) {
    return TransformCollectionSetUndefinedFailureImpl<E, F, CS, C>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}

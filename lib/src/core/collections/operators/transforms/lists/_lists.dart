import '../../../../../../dart_observable.dart';
import 'failure.dart';
import 'undefined.dart';
import 'undefined_failure.dart';

class OperatorsCollectionTransformListsImpl<CS extends CollectionState<C>, C> implements OperatorsTransformLists<C> {
  final Observable<CS> source;

  OperatorsCollectionTransformListsImpl(this.source);

  @override
  ObservableListFailure<E2, F> failure<E2, F>({
    required final void Function(
      ObservableListFailure<E2, F> state,
      C change,
      Emitter<StateOf<ObservableListUpdateAction<E2>, F>> updater,
    ) transform,
    final FactoryList<E2>? factory,
  }) {
    return TransformCollectListFailureImpl<E2, F, CS, C>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableListUndefined<E2> undefined<E2>({
    required final void Function(
      ObservableListUndefined<E2> state,
      C change,
      Emitter<StateOf<ObservableListUpdateAction<E2>, Undefined>> updater,
    ) transform,
    final FactoryList<E2>? factory,
  }) {
    return TransformCollectListUndefinedImpl<E2, CS, C>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableListUndefinedFailure<E2, F> undefinedFailure<E2, F>({
    required final void Function(
      ObservableListUndefinedFailure<E2, F> state,
      C change,
      Emitter<StateOf<ObservableListUpdateAction<E2>, UndefinedFailure<F>>> updater,
    ) transform,
    final FactoryList<E2>? factory,
  }) {
    return TransformCollectListUndefinedFailureImpl<E2, F, CS, C>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}

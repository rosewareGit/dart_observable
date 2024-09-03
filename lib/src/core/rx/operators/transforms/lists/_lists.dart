import '../../../../../../dart_observable.dart';
import 'failure.dart';
import 'undefined.dart';
import 'undefined_failure.dart';

class OperatorsTransformListsImpl<T> implements OperatorsTransformLists<T> {
  final Observable<T> source;

  OperatorsTransformListsImpl(this.source);

  @override
  ObservableListFailure<E2, F> failure<E2, F>({
    required final void Function(
      ObservableListFailure<E2, F> state,
      T value,
      Emitter<StateOf<ObservableListUpdateAction<E2>, F>> updater,
    ) transform,
    final FactoryList<E2>? factory,
  }) {
    return TransformListFailureImpl<T, E2, F>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableListUndefined<E2> undefined<E2>({
    required final void Function(
      ObservableListUndefined<E2> state,
      T value,
      Emitter<StateOf<ObservableListUpdateAction<E2>, Undefined>> updater,
    ) transform,
    final FactoryList<E2>? factory,
  }) {
    return TransformListUndefinedImpl<T, E2>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableListUndefinedFailure<E2, F> undefinedFailure<E2, F>({
    required final void Function(
      ObservableListUndefinedFailure<E2, F> state,
      T value,
      Emitter<StateOf<ObservableListUpdateAction<E2>, UndefinedFailure<F>>> updater,
    ) transform,
    final FactoryList<E2>? factory,
  }) {
    return TransformListUndefinedFailureImpl<T, E2, F>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}

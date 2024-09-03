import '../../../../../../dart_observable.dart';
import 'failure.dart';
import 'undefined.dart';
import 'undefined_failure.dart';

class OperatorsTransformMapsImpl<T> implements OperatorsTransformMaps<T> {
  final Observable<T> source;

  OperatorsTransformMapsImpl(this.source);

  @override
  ObservableMapFailure<K, V, F> failure<K, V, F>({
    required final void Function(
      ObservableMapFailure<K, V, F> state,
      T value,
      Emitter<StateOf<ObservableMapUpdateAction<K, V>, F>> updater,
    ) transform,
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorMapFailureImpl<K, V, F, T>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableMapUndefined<K, V> undefined<K, V>({
    required final void Function(
      ObservableMapUndefined<K, V> state,
      T value,
      Emitter<StateOf<ObservableMapUpdateAction<K, V>, Undefined>> updater,
    ) transform,
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorMapUndefinedImpl<K, V, T>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableMapUndefinedFailure<K, V, F> undefinedFailure<K, V, F>({
    required final void Function(
      ObservableMapUndefinedFailure<K, V, F> state,
      T value,
      Emitter<StateOf<ObservableMapUpdateAction<K, V>, UndefinedFailure<F>>> updater,
    ) transform,
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorMapUndefinedFailureImpl<K, V, F, T>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}

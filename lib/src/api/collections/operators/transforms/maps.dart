import '../../../../../dart_observable.dart';

abstract interface class OperatorsTransformMaps<C> {
  ObservableMapFailure<K, V, F> failure<K, V, F>({
    required final void Function(
      ObservableMapFailure<K, V, F> state,
      C change,
      Emitter<StateOf<ObservableMapUpdateAction<K, V>, F>> updater,
    ) transform,
    final FactoryMap<K, V>? factory,
  });

  ObservableMapUndefined<K, V> undefined<K, V>({
    required final void Function(
      ObservableMapUndefined<K, V> state,
      C change,
      Emitter<StateOf<ObservableMapUpdateAction<K, V>, Undefined>> updater,
    ) transform,
    final FactoryMap<K, V>? factory,
  });

  ObservableMapUndefinedFailure<K, V, F> undefinedFailure<K, V, F>({
    required final void Function(
      ObservableMapUndefinedFailure<K, V, F> state,
      C change,
      Emitter<StateOf<ObservableMapUpdateAction<K, V>, UndefinedFailure<F>>> updater,
    ) transform,
    final FactoryMap<K, V>? factory,
  });
}
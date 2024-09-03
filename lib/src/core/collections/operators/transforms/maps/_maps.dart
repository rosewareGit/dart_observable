import '../../../../../../dart_observable.dart';
import 'failure.dart';
import 'undefined.dart';
import 'undefined_failure.dart';

class OperatorsCollectTransformMapsImpl<CS extends CollectionState<C>, C> implements OperatorsTransformMaps<C> {
  final Observable<CS> source;

  OperatorsCollectTransformMapsImpl(this.source);

  @override
  ObservableMapFailure<K, V, F> failure<K, V, F>({
    required final void Function(
      ObservableMapFailure<K, V, F> state,
      C change,
      Emitter<StateOf<ObservableMapUpdateAction<K, V>, F>> updater,
    ) transform,
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorCollectMapFailureImpl<K, V, F, CS, C>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableMapUndefined<K, V> undefined<K, V>({
    required final void Function(
      ObservableMapUndefined<K, V> state,
      C change,
      Emitter<StateOf<ObservableMapUpdateAction<K, V>, Undefined>> updater,
    ) transform,
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorCollectMapUndefinedImpl<K, V, CS, C>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableMapUndefinedFailure<K, V, F> undefinedFailure<K, V, F>({
    required final void Function(
      ObservableMapUndefinedFailure<K, V, F> state,
      C change,
      Emitter<StateOf<ObservableMapUpdateAction<K, V>, UndefinedFailure<F>>> updater,
    ) transform,
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorCollectionMapUndefinedFailureImpl<K, V, F, CS, C>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}

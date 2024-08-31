import '../../../../../../dart_observable.dart';
import '../../../../../api/change_tracking_observable.dart';
import 'failure.dart';
import 'undefined.dart';
import 'undefined_failure.dart';

class OperatorsTransformMapsImpl<Self extends ChangeTrackingObservable<Self, CS, C>, C, CS>
    implements OperatorsTransformMaps<C> {
  final Self source;

  OperatorsTransformMapsImpl(this.source);

  @override
  ObservableMapFailure<K, V, F> failure<K, V, F>({
    required final void Function(
      ObservableMapFailure<K, V, F> state,
      C change,
      Emitter<StateOf<ObservableMapUpdateAction<K, V>, F>> updater,
    ) transform,
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorMapFailureImpl<Self, K, V, F, C, CS>(
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
    return OperatorMapUndefinedImpl<Self, K, V, C, CS>(
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
    return OperatorMapUndefinedFailureImpl<Self, K, V, F, C, CS>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}

import '../../../../../../dart_observable.dart';
import '../../../../../api/change_tracking_observable.dart';
import 'failure.dart';
import 'undefined.dart';
import 'undefined_failure.dart';

class OperatorsTransformSetsImpl<Self extends ChangeTrackingObservable<Self, CS, C>, C, CS>
    implements OperatorsTransformSets<C> {
  final Self source;

  OperatorsTransformSetsImpl(this.source);

  @override
  ObservableSetFailure<E2, F> failure<E2, F>({
    required final void Function(
      ObservableSetFailure<E2, F> state,
      C change,
      Emitter<StateOf<ObservableSetUpdateAction<E2>, F>> updater,
    ) transform,
    final FactorySet<E2>? factory,
  }) {
    return SetFailureImpl<Self, F, E2, C, CS>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableSetUndefined<E2> undefined<E2>({
    required final void Function(
      ObservableSetUndefined<E2> state,
      C change,
      Emitter<StateOf<ObservableSetUpdateAction<E2>, Undefined>> updater,
    ) transform,
    final FactorySet<E2>? factory,
  }) {
    return SetUndefinedImpl<Self, E2, C, CS>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableSetUndefinedFailure<E2, F> undefinedFailure<E2, F>({
    required final void Function(
      ObservableSetUndefinedFailure<E2, F> state,
      C change,
      Emitter<StateOf<ObservableSetUpdateAction<E2>, UndefinedFailure<F>>> updater,
    ) transform,
    final FactorySet<E2>? factory,
  }) {
    return SetUndefinedFailureImpl<Self, E2, F, C, CS>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}

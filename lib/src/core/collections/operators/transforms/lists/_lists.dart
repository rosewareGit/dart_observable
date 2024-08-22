import '../../../../../../dart_observable.dart';
import '../../../../../api/change_tracking_observable.dart';
import 'failure.dart';
import 'undefined.dart';
import 'undefined_failure.dart';

class OperatorsTransformListsImpl<Self extends ChangeTrackingObservable<Self, CS, C>, C, CS>
    implements OperatorsTransformLists<C> {
  final Self source;

  OperatorsTransformListsImpl(this.source);

  @override
  ObservableListFailure<E2, F> failure<E2, F>({
    required final void Function(
      ObservableListFailure<E2, F> state,
      C change,
      Emitter<StateOf<ObservableListUpdateAction<E2>, F>> updater,
    ) transform,
    final FactoryList<E2>? factory,
  }) {
    return OperatorCollectionsTransformAsResult<Self, F, E2, C, CS>(
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
    return OperatorCollectionsTransformAsUndefined<Self, E2, C, CS>(
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
    return OperatorCollectionsTransformAsOptionalResult<Self, E2, F, C, CS>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}

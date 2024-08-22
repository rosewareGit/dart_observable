import '../../../../../dart_observable.dart';
import '../../../../api/change_tracking_observable.dart';
import '../../set/set.dart';
import '../_base_transform.dart';

class OperatorCollectionsTransformAsSet<Self extends ChangeTrackingObservable<Self, CS, C>, E2, C, CS>
    extends RxSetImpl<E2>
    with
        BaseCollectionTransformOperator<
            Self,
            ObservableSet<E2>,
            CS, //
            ObservableSetState<E2>,
            C,
            ObservableSetChange<E2>,
            ObservableSetUpdateAction<E2>> {
  @override
  final Self source;

  final void Function(
    ObservableSet<E2> state,
    C change,
    Emitter<ObservableSetUpdateAction<E2>> updater,
  ) transformFn;

  OperatorCollectionsTransformAsSet({
    required this.source,
    required this.transformFn,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  }) : super(factory: factory);

  @override
  ObservableSet<E2> get current => this;

  @override
  void transformChange(
    final ObservableSet<E2> state,
    final C change,
    final Emitter<ObservableSetUpdateAction<E2>> updater,
  ) {
    transformFn(state, change, updater);
  }
}

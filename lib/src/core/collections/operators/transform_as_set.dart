import '../../../../dart_observable.dart';
import '../set/set.dart';
import '_base_transform.dart';

class OperatorCollectionsTransformAsSet<E, E2, C, T extends CollectionState<E, C>> extends RxSetImpl<E2>
    with
        BaseCollectionTransformOperator<
            E, //
            E2,
            C,
            T,
            ObservableSetChange<E2>,
            ObservableSetState<E2>,
            ObservableSet<E2>,
            ObservableSetUpdateAction<E2>> {
  @override
  final ObservableCollection<E, C, T> source;

  @override
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
}

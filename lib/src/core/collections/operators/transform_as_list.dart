import '../../../../dart_observable.dart';
import '../list/list.dart';
import '_base_transform.dart';

class OperatorCollectionsTransformAsList<E, E2, C, T extends CollectionState<E, C>> extends RxListImpl<E2>
    with
        BaseCollectionTransformOperator<
            E, //
            E2,
            C,
            T,
            ObservableListChange<E2>,
            ObservableListState<E2>,
            ObservableList<E2>,
            ObservableListUpdateAction<E2>> {
  @override
  final ObservableCollection<E, C, T> source;

  @override
  final void Function(
    ObservableList<E2> state,
    C change,
    Emitter<ObservableListUpdateAction<E2>> updater,
  ) transformFn;

  OperatorCollectionsTransformAsList({
    required this.source,
    required this.transformFn,
    final FactoryList<E2>? factory,
  }) : super(factory: factory);

  @override
  ObservableList<E2> get current => this;
}

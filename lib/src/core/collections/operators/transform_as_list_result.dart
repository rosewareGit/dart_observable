import '../../../../dart_observable.dart';
import '../list/result.dart';
import '_base_transform.dart';

class OperatorCollectionsTransformAsListResult<E, E2, F, C, T extends CollectionState<E, C>>
    extends RxListResultImpl<E2, F>
    with
        BaseCollectionTransformOperator<
            E, //
            E2,
            C,
            T,
            ObservableListResultChange<E2, F>,
            ObservableListResultState<E2, F>,
            ObservableListResult<E2, F>,
            ObservableListResultUpdateAction<E2, F>> {
  @override
  final ObservableCollection<E, C, T> source;

  final void Function(
    ObservableListResult<E2, F> state,
    C change,
    Emitter<ObservableListResultUpdateAction<E2, F>> updater,
  ) transformFn;

  OperatorCollectionsTransformAsListResult({
    required this.source,
    required this.transformFn,
    final FactoryList<E2>? factory,
  }) : super(factory: factory);

  @override
  ObservableListResult<E2, F> get current => this;

  @override
  void transformChange(
    final ObservableListResult<E2, F> state,
    final C change,
    final Emitter<ObservableListResultUpdateAction<E2, F>> updater,
  ) {
    transformFn(state, change, updater);
  }
}

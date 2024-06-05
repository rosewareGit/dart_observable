import '../../../../dart_observable.dart';
import '../set/result.dart';
import '_base_transform.dart';

class OperatorCollectionsTransformAsSetResult<E, E2, F, C, T extends CollectionState<E, C>>
    extends RxSetResultImpl<E2, F>
    with
        BaseCollectionTransformOperator<
            E, //
            E2,
            C,
            T,
            ObservableSetResultChange<E2, F>,
            ObservableSetResultState<E2, F>,
            ObservableSetResult<E2, F>,
            ObservableSetResultUpdateAction<E2, F>> {
  @override
  final ObservableCollection<E, C, T> source;
  @override
  final void Function(
    ObservableSetResult<E2, F> state,
    C change,
    Emitter<ObservableSetResultUpdateAction<E2, F>> updater,
  ) transformFn;

  OperatorCollectionsTransformAsSetResult({
    required this.source,
    required this.transformFn,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  }) : super(factory: factory);

  @override
  ObservableSetResult<E2, F> get current => this;
}

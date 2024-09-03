import '../../../../../dart_observable.dart';
import '../../list/rx_impl.dart';
import '../_base_transform.dart';

abstract class OperatorCollectionTransformAsList<
        E2, //
        C,
        CS extends CollectionState<C>> extends RxListImpl<E2>
    with
        BaseCollectionTransformOperator<CS, ObservableListState<E2>, C, ObservableListChange<E2>,
            ObservableListUpdateAction<E2>> {
  @override
  final Observable<CS> source;

  OperatorCollectionTransformAsList({
    required this.source,
    super.factory,
  });
}

class OperatorCollectionTransformAsListArg<E, C, CS extends CollectionState<C>>
    extends OperatorCollectionTransformAsList<E, C, CS> {
  final void Function(
    ObservableList<E> state,
    C change,
    Emitter<ObservableListUpdateAction<E>> updater,
  ) transformFn;

  OperatorCollectionTransformAsListArg({
    required this.transformFn,
    required super.source,
    super.factory,
  });

  @override
  void transformChange(
    final C change,
    final Emitter<ObservableListUpdateAction<E>> updater,
  ) {
    transformFn(this, change, updater);
  }
}

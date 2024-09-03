import '../../../../../dart_observable.dart';
import '../../../collections/list/rx_impl.dart';
import '../_base_transform.dart';

abstract class OperatorTransformAsList<T, E> extends RxListImpl<E>
    with BaseTransformOperator<T, ObservableListState<E>, ObservableListUpdateAction<E>> {
  @override
  final Observable<T> source;

  OperatorTransformAsList({
    required this.source,
    super.factory,
  });

  @override
  void handleUpdate(final ObservableListUpdateAction<E> action) {
    applyAction(action);
  }
}

class OperatorTransformAsListArg<T, E2> extends OperatorTransformAsList<T, E2> {
  final void Function(
    ObservableList<E2> state,
    T change,
    Emitter<ObservableListUpdateAction<E2>> updater,
  ) transformFn;

  OperatorTransformAsListArg({
    required this.transformFn,
    required super.source,
    super.factory,
  });

  @override
  void transformChange(
    final T value,
    final Emitter<ObservableListUpdateAction<E2>> updater,
  ) {
    transformFn(this, value, updater);
  }
}

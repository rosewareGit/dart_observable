import '../../../../../dart_observable.dart';
import '../../../collections/set/rx_impl.dart';
import '../_base_transform.dart';

abstract class OperatorTransformAsSet<T, E2> extends RxSetImpl<E2>
    with BaseTransformOperator<T, ObservableSetState<E2>, ObservableSetUpdateAction<E2>> {
  @override
  final Observable<T> source;

  OperatorTransformAsSet({
    required this.source,
    super.factory,
  });

  @override
  void handleUpdate(final ObservableSetUpdateAction<E2> action) {
    applyAction(action);
  }
}

class OperatorTransformAsSetArg<T, E> extends OperatorTransformAsSet<T, E> {
  final void Function(
    ObservableSet<E> state,
    T value,
    Emitter<ObservableSetUpdateAction<E>> updater,
  ) transformFn;

  OperatorTransformAsSetArg({
    required super.source,
    required this.transformFn,
    super.factory,
  });

  @override
  void transformChange(
    final T value,
    final Emitter<ObservableSetUpdateAction<E>> updater,
  ) {
    transformFn(this, value, updater);
  }
}

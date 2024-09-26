import '../../../../../dart_observable.dart';
import '../../../collections/set/rx_impl.dart';
import '../_base_transform.dart';

class SetTransform<T, E> extends RxSetImpl<E> with BaseTransformOperator<T, ObservableSetState<E>, Set<E>> {
  @override
  final Observable<T> source;
  final SetUpdater<E, T>? transformFn;

  SetTransform({
    required this.source,
    required super.factory,
    this.transformFn,
  });

  @override
  void handleUpdate(final Set<E> action) {
    setData(action);
  }

  @override
  void transformChange(final T value, final Emitter<Set<E>> updater) {
    assert(transformFn != null, 'override transformChange or provide a transformFn');

    transformFn?.call(this, value, updater);
  }
}

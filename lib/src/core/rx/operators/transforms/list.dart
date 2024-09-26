import '../../../../../dart_observable.dart';
import '../../../collections/list/rx_impl.dart';
import '../_base_transform.dart';

class ListTransform<T, E> extends RxListImpl<E> with BaseTransformOperator<T, ObservableListState<E>, List<E>> {
  @override
  final Observable<T> source;
  final ListUpdater<E, T>? transformFn;

  ListTransform({
    required this.source,
    required super.factory,
    this.transformFn,
  });

  @override
  void handleUpdate(final List<E> action) {
    setData(action);
  }

  @override
  void transformChange(
    final T value,
    final Emitter<List<E>> updater,
  ) {
    assert(transformFn != null, 'override transformChange or provide a transformFn');

    transformFn?.call(this, value, updater);
  }
}

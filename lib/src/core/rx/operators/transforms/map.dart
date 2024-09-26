import '../../../../../dart_observable.dart';
import '../../../collections/map/rx_impl.dart';
import '../_base_transform.dart';

class MapTransform<T, K, V> extends RxMapImpl<K, V> with BaseTransformOperator<T, ObservableMapState<K, V>, Map<K, V>> {
  @override
  final Observable<T> source;
  final MapUpdater<K, V, T>? transformFn;

  MapTransform({
    required this.source,
    required super.factory,
    this.transformFn,
  });

  @override
  void handleUpdate(final Map<K, V> action) {
    setData(action);
  }

  @override
  void transformChange(
    final T value,
    final Emitter<Map<K, V>> updater,
  ) {
    assert(transformFn != null, 'override transformChange or provide a transformFn');
    transformFn?.call(this, value, updater);
  }
}

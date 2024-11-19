import '../../../../../dart_observable.dart';
import '../../../../api/collections/collection_transforms.dart';
import '../../map/rx_impl.dart';
import '../_base_transform.dart';

class MapChangeTransform<C, T, K, V> extends RxMapImpl<K, V>
    with
        BaseCollectionTransformOperator<
            T, //
            ObservableMapState<K, V>,
            C,
            ObservableMapChange<K, V>> {
  @override
  final ObservableCollection<T, C> source;
  final MapChangeUpdater<K, V, C>? transformFn;

  MapChangeTransform({
    required this.source,
    required super.factory,
    this.transformFn,
  });

  @override
  void handleChange(
    final C change,
  ) {
    assert(transformFn != null, 'override handleChange or provide a transformFn');

    transformFn?.call(this, change, applyAction);
  }
}

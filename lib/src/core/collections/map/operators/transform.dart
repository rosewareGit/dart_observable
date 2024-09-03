import '../../../../../dart_observable.dart';
import '../../operators/transforms/map.dart';

abstract class OperatorMapTransform<K, V, K2, V2>
    extends OperatorCollectionTransformAsMap<ObservableMapChange<K, V>, ObservableMapState<K, V>, K2, V2> {
  OperatorMapTransform({
    required super.source,
    super.factory,
  });
}

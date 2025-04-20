import '../../../../dart_observable.dart';
import '../../../../src/core/collections/map/rx_impl.dart';
import 'rx_actions.dart';

abstract interface class RxMap<K, V> implements ObservableMap<K, V>, Rx<Map<K, V>>, RxMapActions<K, V> {
  factory RxMap([
    final Map<K, V>? initial,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  ]) {
    return RxMapImpl<K, V>(
      initial: initial,
      factory: factory,
    );
  }

  factory RxMap.sorted({
    required final Comparator<V> comparator,
    final Map<K, V>? initial,
  }) {
    return RxMapImpl<K, V>.sorted(
      comparator: comparator,
      initial: initial,
    );
  }
}

import '../../../../../dart_observable.dart';
import '../../../rx/operators/_base_switch_map.dart';
import '../../map/rx_impl.dart';
import '../_base_switch_map.dart';

class MapChangeSwitchMap<K, V, C, T> extends RxMapImpl<K, V>
    with
        BaseSwitchMapOperator<ObservableMap<K, V>, T, Map<K, V>>,
        BaseSwitchMapChangeOperator<ObservableMap<K, V>, T, C, Map<K, V>, ObservableMapChange<K, V>> {
  @override
  final ObservableCollection<T, C> source;
  @override
  final ObservableMap<K, V>? Function(C value) mapChange;

  MapChangeSwitchMap({
    required this.source,
    required this.mapChange,
    super.factory,
  });
}

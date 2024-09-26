import '../../../../../dart_observable.dart';
import '../../../rx/operators/_base_switch_map.dart';
import '../../map/rx_impl.dart';
import '../_base_switch_map.dart';

class MapChangeSwitchMap<K, V, C, CS extends CollectionState<C>> extends RxMapImpl<K, V>
    with
        BaseSwitchMapOperator<ObservableMap<K, V>, CS, ObservableMapState<K, V>>,
        BaseSwitchMapChangeOperator<ObservableMap<K, V>, CS, C, ObservableMapState<K, V>, ObservableMapChange<K, V>> {
  @override
  final ObservableCollection<C, CS> source;
  @override
  final ObservableMap<K, V>? Function(C value) mapChange;

  MapChangeSwitchMap({
    required this.source,
    required this.mapChange,
    super.factory,
  });
}

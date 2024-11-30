import '../../../../../dart_observable.dart';
import '../../../collections/map/rx_impl.dart';
import '../_base_switch_map.dart';

class MapSwitchMap<K, V, T> extends RxMapImpl<K, V> with BaseSwitchMapOperator<ObservableMap<K, V>, T, Map<K, V>> {
  @override
  final Observable<T> source;
  @override
  final ObservableMap<K, V> Function(T change) mapper;

  MapSwitchMap({
    required this.source,
    required this.mapper,
    super.factory,
  });

  @override
  void onIntermediateUpdated(final ObservableMap<K, V> intermediate, final Map<K, V> value) {
    final ObservableMapChange<K, V> change = intermediate.change;
    applyAction(ObservableMapUpdateAction<K, V>.fromChange(change));
  }
}

import '../../../../../dart_observable.dart';
import '../../../rx/operators/_base_switch_map.dart';
import '../../map/stateful/rx_stateful.dart';
import '../_base_switch_map.dart';

class StatefulMapChangeSwitchMap<K, V, S, C, CS extends CollectionState<C>> extends RxStatefulMapImpl<K, V, S>
    with
        BaseSwitchMapOperator<ObservableStatefulMap<K, V, S>, CS, ObservableStatefulMapState<K, V, S>>,
        BaseSwitchMapChangeOperator<ObservableStatefulMap<K, V, S>, CS, C, ObservableStatefulMapState<K, V, S>,
            Either<ObservableMapChange<K, V>, S>> {
  @override
  final ObservableCollection<C, CS> source;
  @override
  final ObservableStatefulMap<K, V, S>? Function(C value) mapChange;

  StatefulMapChangeSwitchMap({
    required this.source,
    required this.mapChange,
    super.factory,
  }) : super(<K, V>{});
}

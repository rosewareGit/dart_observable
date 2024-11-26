import '../../../../../dart_observable.dart';
import '../../../rx/operators/_base_switch_map.dart';
import '../../map/stateful/rx_stateful.dart';
import '../_base_switch_map.dart';

class StatefulMapChangeSwitchMap<K, V, S, C, T> extends RxStatefulMapImpl<K, V, S>
    with
        BaseSwitchMapOperator<ObservableStatefulMap<K, V, S>, T, Either<Map<K, V>, S>>,
        BaseSwitchMapChangeOperator<ObservableStatefulMap<K, V, S>, T, C, Either<Map<K, V>, S>,
            Either<ObservableMapChange<K, V>, S>> {
  @override
  final ObservableCollection<T, C> source;
  @override
  final ObservableStatefulMap<K, V, S>? Function(C value) mapChange;

  StatefulMapChangeSwitchMap({
    required this.source,
    required this.mapChange,
    super.factory,
  }) : super(<K, V>{});
}

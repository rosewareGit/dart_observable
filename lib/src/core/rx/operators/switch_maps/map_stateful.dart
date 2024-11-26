import '../../../../../../dart_observable.dart';
import '../../../collections/map/stateful/rx_stateful.dart';
import '../_base_switch_map.dart';

class StatefulMapSwitchMap<K, V, S, T> extends RxStatefulMapImpl<K, V, S>
    with BaseSwitchMapOperator<ObservableStatefulMap<K, V, S>, T, Either<Map<K, V>, S>> {
  @override
  final Observable<T> source;
  @override
  final ObservableStatefulMap<K, V, S> Function(T value) mapper;

  StatefulMapSwitchMap({
    required this.source,
    required this.mapper,
    super.factory,
  }) : super(<K, V>{});
}

import '../../../../../../dart_observable.dart';
import '../../../collections/list/stateful/rx_stateful.dart';
import '../_base_switch_map.dart';

class StatefulListSwitchMap<E, S, T> extends RxStatefulListImpl<E, S>
    with BaseSwitchMapOperator<ObservableStatefulList<E, S>, T, ObservableStatefulListState<E, S>> {
  @override
  final Observable<T> source;
  @override
  final ObservableStatefulList<E, S> Function(T value) mapper;

  StatefulListSwitchMap({
    required this.source,
    required this.mapper,
    required super.factory,
  }) : super(<E>[]);
}

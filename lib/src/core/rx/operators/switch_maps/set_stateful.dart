import '../../../../../../dart_observable.dart';
import '../../../collections/set/stateful/rx_stateful.dart';
import '../_base_switch_map.dart';

class StatefulSetSwitchMap<E, S, T> extends RxStatefulSetImpl<E, S>
    with BaseSwitchMapOperator<ObservableStatefulSet<E, S>, T, Either<Set<E>, S>> {
  @override
  final Observable<T> source;
  @override
  final ObservableStatefulSet<E, S> Function(T value) mapper;

  StatefulSetSwitchMap({
    required this.source,
    required this.mapper,
    super.factory,
  }) : super(<E>{});
}

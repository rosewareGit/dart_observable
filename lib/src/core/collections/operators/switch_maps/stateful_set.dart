import '../../../../../dart_observable.dart';
import '../../../rx/operators/_base_switch_map.dart';
import '../../set/stateful/rx_stateful.dart';
import '../_base_switch_map.dart';

class StatefulSetChangeSwitchMap<E, S, C, T> extends RxStatefulSetImpl<E, S>
    with
        BaseSwitchMapOperator<ObservableStatefulSet<E, S>, T, ObservableStatefulSetState<E, S>>,
        BaseSwitchMapChangeOperator<ObservableStatefulSet<E, S>, T, C, ObservableStatefulSetState<E, S>,
            Either<ObservableSetChange<E>, S>> {
  @override
  final ObservableCollection<T,C> source;
  @override
  final ObservableStatefulSet<E, S>? Function(C value) mapChange;

  StatefulSetChangeSwitchMap({
    required this.source,
    required this.mapChange,
    super.factory,
  }) : super(<E>[]);
}

import '../../../../../dart_observable.dart';
import '../../../rx/operators/_base_switch_map.dart';
import '../../list/stateful/rx_stateful.dart';
import '../_base_switch_map.dart';

class StatefulListChangeSwitchMap<E, S, C, T> extends RxStatefulListImpl<E, S>
    with
        BaseSwitchMapOperator<ObservableStatefulList<E, S>, T, Either<List<E>, S>>,
        BaseSwitchMapChangeOperator<ObservableStatefulList<E, S>, T, C, Either<List<E>, S>,
            Either<ObservableListChange<E>, S>> {
  @override
  final ObservableCollection<T, C> source;
  @override
  final ObservableStatefulList<E, S>? Function(C value) mapChange;

  StatefulListChangeSwitchMap({
    required this.source,
    required this.mapChange,
  }) : super(<E>[]);
}

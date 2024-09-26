import '../../../../../dart_observable.dart';
import '../../../rx/operators/_base_switch_map.dart';
import '../../list/stateful/rx_stateful.dart';
import '../_base_switch_map.dart';

class StatefulListChangeSwitchMap<E, S, C, CS extends CollectionState<C>> extends RxStatefulListImpl<E, S>
    with
        BaseSwitchMapOperator<ObservableStatefulList<E, S>, CS, ObservableStatefulListState<E, S>>,
        BaseSwitchMapChangeOperator<ObservableStatefulList<E, S>, CS, C, ObservableStatefulListState<E, S>,
            Either<ObservableListChange<E>, S>> {
  @override
  final ObservableCollection<C, CS> source;
  @override
  final ObservableStatefulList<E, S>? Function(C value) mapChange;

  StatefulListChangeSwitchMap({
    required this.source,
    required this.mapChange,
    super.factory,
  }) : super(<E>[]);
}

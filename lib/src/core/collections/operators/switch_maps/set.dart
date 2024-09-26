import '../../../../../dart_observable.dart';
import '../../../rx/operators/_base_switch_map.dart';
import '../../set/rx_impl.dart';
import '../_base_switch_map.dart';

class SetChangeSwitchMap<E, C, CS extends CollectionState<C>> extends RxSetImpl<E>
    with
        BaseSwitchMapOperator<ObservableSet<E>, CS, ObservableSetState<E>>,
        BaseSwitchMapChangeOperator<ObservableSet<E>, CS, C, ObservableSetState<E>, ObservableSetChange<E>> {
  @override
  final ObservableCollection<C, CS> source;
  @override
  final ObservableSet<E>? Function(C value) mapChange;

  SetChangeSwitchMap({
    required this.source,
    required this.mapChange,
    super.factory,
  });
}

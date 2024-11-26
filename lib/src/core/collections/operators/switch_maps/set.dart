import '../../../../../dart_observable.dart';
import '../../../rx/operators/_base_switch_map.dart';
import '../../set/rx_impl.dart';
import '../_base_switch_map.dart';

class SetChangeSwitchMap<E, C, T> extends RxSetImpl<E>
    with
        BaseSwitchMapOperator<ObservableSet<E>, T, Set<E>>,
        BaseSwitchMapChangeOperator<ObservableSet<E>, T, C, Set<E>, ObservableSetChange<E>> {
  @override
  final ObservableCollection<T, C> source;
  @override
  final ObservableSet<E>? Function(C value) mapChange;

  SetChangeSwitchMap({
    required this.source,
    required this.mapChange,
    super.factory,
  });
}

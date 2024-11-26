import '../../../../../dart_observable.dart';
import '../../../rx/operators/_base_switch_map.dart';
import '../../list/rx_impl.dart';
import '../_base_switch_map.dart';

class ListChangeSwitchMap<E, C, T> extends RxListImpl<E>
    with
        BaseSwitchMapOperator<ObservableList<E>, T, List<E>>,
        BaseSwitchMapChangeOperator<ObservableList<E>, T, C, List<E>, ObservableListChange<E>> {
  @override
  final ObservableCollection<T, C> source;
  @override
  final ObservableList<E>? Function(C value) mapChange;

  ListChangeSwitchMap({
    required this.source,
    required this.mapChange,
  });
}

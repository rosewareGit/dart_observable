import '../../../../../dart_observable.dart';
import '../../../rx/operators/_base_switch_map.dart';
import '../../list/rx_impl.dart';
import '../_base_switch_map.dart';

class ListChangeSwitchMap<E, C, CS extends CollectionState<C>> extends RxListImpl<E>
    with
        BaseSwitchMapOperator<ObservableList<E>, CS, ObservableListState<E>>,
        BaseSwitchMapChangeOperator<ObservableList<E>, CS, C, ObservableListState<E>, ObservableListChange<E>> {
  @override
  final ObservableCollection<C, CS> source;
  @override
  final ObservableList<E>? Function(C value) mapChange;

  ListChangeSwitchMap({
    required this.source,
    required this.mapChange,
    super.factory,
  });
}

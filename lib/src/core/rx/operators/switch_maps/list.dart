import '../../../../../dart_observable.dart';
import '../../../collections/list/rx_impl.dart';
import '../_base_switch_map.dart';

class ListSwitchMap<E2, T> extends RxListImpl<E2>
    with BaseSwitchMapOperator<ObservableList<E2>, T, ObservableListState<E2>> {
  @override
  final Observable<T> source;

  @override
  final ObservableList<E2> Function(T value) mapper;

  ListSwitchMap({
    required this.source,
    required this.mapper,
    super.factory,
  });
}

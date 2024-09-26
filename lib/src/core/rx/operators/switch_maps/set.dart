import '../../../../../dart_observable.dart';
import '../../../collections/set/rx_impl.dart';
import '../_base_switch_map.dart';

class SetSwitchMap<E, T> extends RxSetImpl<E> with BaseSwitchMapOperator<ObservableSet<E>, T, ObservableSetState<E>> {
  @override
  final Observable<T> source;
  @override
  final ObservableSet<E> Function(T value) mapper;

  SetSwitchMap({
    required this.source,
    required this.mapper,
    super.factory,
  });
}

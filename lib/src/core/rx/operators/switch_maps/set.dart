import '../../../../../dart_observable.dart';
import '../../../collections/set/rx_impl.dart';
import '../_base_switch_map.dart';

class SetSwitchMap<E, T> extends RxSetImpl<E> with BaseSwitchMapOperator<ObservableSet<E>, T, Set<E>> {
  @override
  final Observable<T> source;
  @override
  final ObservableSet<E> Function(T value) mapper;

  SetSwitchMap({
    required this.source,
    required this.mapper,
    super.factory,
  });

  @override
  void onIntermediateUpdated(final ObservableSet<E> intermediate, final Set<E> value) {
    final ObservableSetChange<E> change = intermediate.change;
    applyAction(ObservableSetUpdateAction<E>.fromChange(change));
  }
}

import '../../../../../../dart_observable.dart';
import '../../../collections/set/stateful/rx_stateful.dart';
import '../_base_switch_map.dart';

class StatefulSetSwitchMap<E, S, T> extends RxStatefulSetImpl<E, S>
    with BaseSwitchMapOperator<ObservableStatefulSet<E, S>, T, Either<Set<E>, S>> {
  @override
  final Observable<T> source;
  @override
  final ObservableStatefulSet<E, S> Function(T value) mapper;

  StatefulSetSwitchMap({
    required this.source,
    required this.mapper,
    super.factory,
  }) : super(<E>{});

  @override
  void onIntermediateUpdated(final ObservableStatefulSet<E, S> intermediate, final Either<Set<E>, S> value) {
    final Either<ObservableSetChange<E>, S> change = intermediate.change;
    change.fold(
      onLeft: (final ObservableSetChange<E> change) {
        applySetUpdateAction(ObservableSetUpdateAction<E>.fromChange(change));
      },
      onRight: (final S state) {
        applyAction(Either<ObservableSetUpdateAction<E>, S>.right(state));
      },
    );
  }
}

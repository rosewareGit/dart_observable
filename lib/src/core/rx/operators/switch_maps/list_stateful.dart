import '../../../../../../dart_observable.dart';
import '../../../collections/list/stateful/rx_stateful.dart';
import '../_base_switch_map.dart';

class StatefulListSwitchMap<E, S, T> extends RxStatefulListImpl<E, S>
    with BaseSwitchMapOperator<ObservableStatefulList<E, S>, T, Either<List<E>, S>> {
  @override
  final Observable<T> source;
  @override
  final ObservableStatefulList<E, S> Function(T value) mapper;

  StatefulListSwitchMap({
    required this.source,
    required this.mapper,
  }) : super(<E>[]);

  @override
  void onIntermediateUpdated(final ObservableStatefulList<E, S> intermediate, final Either<List<E>, S> value) {
    final Either<ObservableListChange<E>, S> change = intermediate.change;
    change.fold(
      onLeft: (final ObservableListChange<E> change) {
        applyListUpdateAction(ObservableListUpdateAction<E>.fromChange(change));
      },
      onRight: (final S state) {
        applyAction(Either<ObservableListUpdateAction<E>, S>.right(state));
      },
    );
  }
}

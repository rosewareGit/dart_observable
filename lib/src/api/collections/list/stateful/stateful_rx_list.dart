import '../../../../../dart_observable.dart';
import '../../../../core/collections/list/stateful/rx_stateful.dart';
import '../rx_actions.dart';

abstract interface class RxStatefulList<E, S> implements ObservableStatefulList<E, S>, RxListActions<E> {
  factory RxStatefulList({
    final S? custom,
    final List<E>? initial,
  }) {
    if (custom != null) {
      return RxStatefulListImpl<E, S>.custom(custom);
    }

    return RxStatefulListImpl<E, S>(initial ?? <E>[]);
  }

  factory RxStatefulList.custom(final S state) {
    return RxStatefulListImpl<E, S>.custom(state);
  }

  Either<ObservableListChange<E>, S>? applyAction(
    final Either<ObservableListUpdateAction<E>, S> action,
  );

  Either<ObservableListChange<E>, S>? setState(final S newState);
}

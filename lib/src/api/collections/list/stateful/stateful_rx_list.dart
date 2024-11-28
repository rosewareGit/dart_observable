import '../../../../../dart_observable.dart';
import '../../../../core/collections/list/stateful/rx_stateful.dart';
import '../rx_actions.dart';

typedef StatefulListAction<E, S> = Either<ObservableListUpdateAction<E>, S>;

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

  set value(final Either<List<E>, S> value);

  StatefulListChange<E, S>? setState(final S newState);
}

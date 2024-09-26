import '../../../../../dart_observable.dart';
import '../../../../core/collections/list/stateful/rx_stateful.dart';
import '../rx_actions.dart';

abstract interface class RxStatefulList<E, S> implements ObservableStatefulList<E, S>, RxListActions<E> {
  factory RxStatefulList({
    final S? custom,
    final List<E>? initial,
    final FactoryList<E>? factory,
  }) {
    if (custom != null) {
      return RxStatefulListImpl<E, S>.custom(
        custom,
        factory: factory,
      );
    }

    return RxStatefulListImpl<E, S>(
      initial ?? <E>[],
      factory: factory,
    );
  }

  factory RxStatefulList.custom(
    final S state, {
    final FactoryList<E>? factory,
  }) {
    return RxStatefulListImpl<E, S>.custom(
      state,
      factory: factory,
    );
  }

  Either<ObservableListChange<E>, S>? applyAction(
    final Either<ObservableListUpdateAction<E>, S> action,
  );

  ObservableListChange<E>? applyListUpdateAction(final ObservableListUpdateAction<E> action);

  Either<ObservableListChange<E>, S>? setState(final S newState);
}

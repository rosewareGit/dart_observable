import '../../../../../dart_observable.dart';
import '../../../../core/collections/set/stateful/rx_stateful.dart';
import '../rx_actions.dart';

abstract interface class RxStatefulSet<E, S>
    implements ObservableStatefulSet<E, S>, Rx<Either<Set<E>, S>>, RxSetActions<E> {
  factory RxStatefulSet({
    final S? custom,
    final Iterable<E>? initial,
    final FactorySet<E>? factory,
  }) {
    if (custom != null) {
      return RxStatefulSetImpl<E, S>.custom(
        custom,
        factory: factory,
      );
    }

    return RxStatefulSetImpl<E, S>(
      initial ?? <E>{},
      factory: factory,
    );
  }

  factory RxStatefulSet.custom(
    final S state, {
    final FactorySet<E>? factory,
  }) {
    return RxStatefulSetImpl<E, S>.custom(
      state,
      factory: factory,
    );
  }

  Either<ObservableSetChange<E>, S>? setState(final S newState);
}

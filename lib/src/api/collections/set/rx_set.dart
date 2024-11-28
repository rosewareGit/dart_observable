import '../../../../dart_observable.dart';
import '../../../../src/core/collections/set/rx_impl.dart';
import 'rx_actions.dart';

abstract interface class RxSet<E> implements ObservableSet<E>, RxSetActions<E> {
  factory RxSet({final Iterable<E>? initial, final FactorySet<E>? factory}) {
    return RxSetImpl<E>(initial: initial, factory: factory);
  }

  factory RxSet.splayTreeSet({
    required final Comparator<E> compare,
    final Iterable<E>? initial,
  }) {
    return RxSetImpl<E>.splayTreeSet(initial: initial, compare: compare);
  }

  set value(final Set<E> value);
}

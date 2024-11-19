import '../../../../dart_observable.dart';

abstract interface class RxSetActions<E> {
  ObservableSetChange<E>? add(final E item);

  ObservableSetChange<E>? addAll(final Iterable<E> items);

  ObservableSetChange<E>? clear();

  ObservableSetChange<E>? remove(final E item);

  ObservableSetChange<E>? removeAll(final Iterable<E> items);

  ObservableSetChange<E>? removeWhere(final bool Function(E item) predicate);

  ObservableSetChange<E>? setData(final Set<E> data);
}

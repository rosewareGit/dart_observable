import '../../../../dart_observable.dart';

abstract interface class RxListActions<E> {
  void operator []=(final int index, final E value);

  ObservableListChange<E>? add(final E item);

  ObservableListChange<E>? addAll(final Iterable<E> items);

  ObservableListChange<E>? clear();

  ObservableListChange<E>? insert(final int index, final E item);

  ObservableListChange<E>? insertAll(final int index, final Iterable<E> items);

  ObservableListChange<E>? remove(final E item);

  ObservableListChange<E>? removeAt(final int index);

  ObservableListChange<E>? removeWhere(final bool Function(E item) predicate);

  ObservableListChange<E>? setData(final List<E> data);
}

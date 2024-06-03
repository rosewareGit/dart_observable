import '../../../../dart_observable.dart';

abstract interface class ObservableSet<E>
    implements ObservableCollection<E, ObservableSetChange<E>, ObservableSetState<E>> {
  int get length;

  bool contains(final E item);

  Observable<E?> rxItem(final bool Function(E item) predicate);

  List<E> toList();
}

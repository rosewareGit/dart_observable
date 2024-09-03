import '../../../../dart_observable.dart';

abstract interface class ObservableSet<E>
    implements ObservableCollection<ObservableSetChange<E>, ObservableSetState<E>> {
  int get length;

  ObservableSet<E> changeFactory(final FactorySet<E> factory);

  bool contains(final E item);

  ObservableSet<E> filterItem(
    final bool Function(E item) predicate, {
    final FactorySet<E>? factory,
  });

  ObservableSet<E2> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactorySet<E2>? factory,
  });

  Observable<E?> rxItem(final bool Function(E item) predicate);

  List<E> toList();
}

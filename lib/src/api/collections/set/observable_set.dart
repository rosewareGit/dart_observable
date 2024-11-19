import '../../../../dart_observable.dart';
import '../../../core/collections/set/factories/merged.dart';
import '../../../core/collections/set/factories/stream.dart';

abstract interface class ObservableSet<E>
    implements ObservableCollection<ObservableSetState<E>, ObservableSetChange<E>> {
  factory ObservableSet.fromStream({
    required final Stream<ObservableSetUpdateAction<E>> stream,
    final Set<E>? Function(dynamic error)? onError,
    final Set<E>? initial,
    final FactorySet<E>? factory,
  }) {
    return ObservableSetFromStream<E>(
      stream: stream,
      initial: initial,
      factory: factory,
      onError: onError,
    );
  }

  factory ObservableSet.just(
    final Set<E> value, {
    final FactorySet<E>? factory,
  }) {
    return RxSet<E>(
      initial: value,
      factory: factory,
    );
  }

  factory ObservableSet.merged({
    required final Iterable<ObservableSet<E>> collections,
    final FactorySet<E>? factory,
  }) {
    return ObservableSetMerged<E>(
      collections: collections,
      factory: factory,
    );
  }

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

  ObservableSet<E> sorted(final Comparator<E> compare);

  List<E> toList();
}

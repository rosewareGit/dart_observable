import 'dart:collection';

import '../../../../../dart_observable.dart';
import '../../../../core/collections/set/stateful/factories/merged.dart';
import '../../../../core/collections/set/stateful/factories/stream.dart';

abstract class ObservableStatefulSet<E, S>
    implements
        ObservableCollectionStateful<
            ObservableSetChange<E>, // the collection type
            S, // The custom state
            Either<Set<E>, S>> {
  factory ObservableStatefulSet.custom(final S custom) {
    return RxStatefulSet<E, S>.custom(custom);
  }

  factory ObservableStatefulSet.fromStream({
    required final Stream<Either<ObservableSetUpdateAction<E>, S>> stream,
    final Either<Set<E>, S>? Function(dynamic error)? onError,
    final Set<E>? initial,
    final FactorySet<E>? factory,
  }) {
    return ObservableStatefulSetFromStream<E, S>(
      stream: stream,
      onError: onError,
      initial: initial,
      factory: factory,
    );
  }

  @override
  Either<UnmodifiableSetView<E>, S> get value;

  factory ObservableStatefulSet.just(
    final Set<E> data, {
    final FactorySet<E>? factory,
  }) {
    return RxStatefulSet<E, S>(initial: data, factory: factory);
  }

  factory ObservableStatefulSet.merged({
    required final Iterable<ObservableStatefulSet<E, S>> collections,
    final Either<Set<E>, S>? Function(S state)? stateResolver,
    final FactorySet<E>? factory,
  }) {
    return ObservableStatefulSetMerged<E, S>(
      collections: collections,
      stateResolver: stateResolver,
      factory: factory,
    );
  }

  int? get length;

  ObservableStatefulSet<E, S> changeFactory(final FactorySet<E> factory);

  bool contains(final E item);

  ObservableStatefulSet<E, S> filterItem(
    final bool Function(E item) predicate, {
    final FactorySet<E>? factory,
  });

  ObservableStatefulSet<E, S> filterItemWithState(
    final bool Function(Either<E, S> item) predicate, {
    final FactorySet<E>? factory,
  });

  ObservableStatefulSet<E2, S> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactorySet<E2>? factory,
  });

  ObservableStatefulSet<E2, S2> mapItemWithState<E2, S2>({
    required final E2 Function(E item) mapper,
    required final S2 Function(S state) stateMapper,
    final FactorySet<E2>? factory,
  });

  Observable<Either<E?, S>> rxItem(final bool Function(E item) predicate);

  ObservableStatefulSet<E, S> sorted(final Comparator<E> compare);
}

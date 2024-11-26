import 'dart:collection';

import '../../../../../dart_observable.dart';
import '../../../../core/collections/map/stateful/factories/merged.dart';
import '../../../../core/collections/map/stateful/factories/stream.dart';

abstract class ObservableStatefulMap<K, V, S>
    implements ObservableCollectionStateful<ObservableMapChange<K, V>, S, Either<Map<K, V>, S>> {
  factory ObservableStatefulMap.custom(final S custom) {
    return RxStatefulMap<K, V, S>.custom(custom);
  }

  factory ObservableStatefulMap.fromStream({
    required final Stream<Either<ObservableMapUpdateAction<K, V>, S>> stream,
    final Either<Map<K, V>, S>? Function(dynamic error)? onError,
    final Map<K, V>? initial,
    final FactoryMap<K, V>? factory,
  }) {
    return ObservableStatefulMapFromStream<K, V, S>(
      stream: stream,
      onError: onError,
      initial: initial,
      factory: factory,
    );
  }

  factory ObservableStatefulMap.just(
    final Map<K, V> value, {
    final FactoryMap<K, V>? factory,
  }) {
    return RxStatefulMap<K, V, S>(
      initial: value,
      factory: factory,
    );
  }

  factory ObservableStatefulMap.merged({
    required final Iterable<ObservableStatefulMap<K, V, S>> collections,
    final Map<K, V> Function(Map<K, V>? items)? factory,
    final MergeConflictResolver<K, V>? conflictResolver,
    final Either<Map<K, V>, S>? Function(
      S state,
      Iterable<ObservableStatefulMap<K, V, S>> collections,
    )? stateResolver,
  }) {
    return ObservableStatefulMapMerged<K, V, S>(
      collections: collections,
      factory: factory,
      conflictResolver: conflictResolver,
      stateResolver: stateResolver,
    );
  }

  int? get length;

  @override
  Either<UnmodifiableMapView<K, V>, S> get value;

  V? operator [](final K key);

  ObservableStatefulMap<K, V, S> changeFactory(final FactoryMap<K, V> factory);

  bool containsKey(final K key);

  ObservableStatefulMap<K, V, S> filterItem(
    final bool Function(K key, V value) predicate, {
    final FactoryMap<K, V>? factory,
  });

  ObservableStatefulMap<K, V, S> filterItemWithState(
    final bool Function(Either<MapEntry<K, V>, S>) predicate, {
    final FactoryMap<K, V>? factory,
  });

  ObservableStatefulMap<K, V2, S> mapItem<V2>(
    final V2 Function(K key, V value) valueMapper, {
    final FactoryMap<K, V2>? factory,
  });

  ObservableStatefulMap<K, V2, S2> mapItemWithState<V2, S2>({
    required final V2 Function(K key, V value) valueMapper,
    required final S2 Function(S state) stateMapper,
    final FactoryMap<K, V2>? factory,
  });

  Observable<Either<V?, S>> rxItem(final K key);

  ObservableStatefulMap<K, V, S> sorted(final Comparator<V> comparator);

  List<V>? toList();
}

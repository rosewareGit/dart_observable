import '../../../../dart_observable.dart';
import 'flatmaps/list.dart';
import 'flatmaps/map.dart';
import 'flatmaps/set.dart';

class ObservableFlatMapsImpl<T> implements ObservableFlatMaps<T> {
  final Observable<T> source;

  ObservableFlatMapsImpl(this.source);

  @override
  ObservableList<E2> list<E2>({
    required final ObservableCollectionFlatMapUpdate<ObservableList<E2>>? Function(T value) sourceProvider,
    final FactoryList<E2>? factory,
  }) {
    return OperatorFlatMapAsList<E2, T, T>(
      source: source,
      sourceProvider: sourceProvider,
      factory: factory,
      toChangeFn: (final T value, _) => value,
    );
  }

  @override
  ObservableMap<K, V> map<K, V>({
    required final ObservableCollectionFlatMapUpdate<ObservableMap<K, V>> Function(T value) sourceProvider,
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorFlatMapAsMap<K, V, T, T>(
      source: source,
      sourceProvider: sourceProvider,
      factory: factory,
      toChangeFn: (final T value, _) => value,
    );
  }

  @override
  ObservableSet<E> set<E>({
    required final ObservableCollectionFlatMapUpdate<ObservableSet<E>> Function(T value) sourceProvider,
    final Set<E> Function(Iterable<E>? items)? factory,
  }) {
    return OperatorFlatMapAsSet<E, T, T>(
      source: source,
      sourceProvider: sourceProvider,
      factory: factory,
      toChangeFn: (final T value, _) => value,
    );
  }
}

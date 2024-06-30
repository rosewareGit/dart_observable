import '../../../../../dart_observable.dart';
import '../../../../core/collections/map/factories/from_collections.dart';
import '../../../../core/collections/map/factories/stream_result.dart';
import '../../../../core/collections/map/result.dart';

abstract interface class RxMapResult<K, V, F> implements ObservableMapResult<K, V, F> {
  factory RxMapResult({
    final Map<K, V>? initial,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) {
    if (initial != null) {
      return RxMapResultImpl<K, V, F>.success(
        initial,
        factory: factory,
      );
    }
    return RxMapResultImpl<K, V, F>(factory: factory);
  }

  factory RxMapResult.failure(
    final F failure, {
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) {
    return RxMapResultImpl<K, V, F>.failure(failure, factory: factory);
  }

  factory RxMapResult.fromCollections({
    required final Iterable<ObservableMapResultUpdater<K, V, F, dynamic>> observables,
    final FactoryMap<K, V>? factory,
  }) {
    return ObservableMapFromCollections<K, V, F>(
      observables: observables,
      factory: factory,
    );
  }

  factory RxMapResult.fromStream({
    required final Stream<ObservableMapResultUpdateAction<K, V, F>> stream,
    final F Function(Object error)? onError,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) {
    return ObservableMapResultFromStream<K, V, F>(
      stream: stream,
      onError: onError,
    );
  }

  factory RxMapResult.undefined({
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) {
    return RxMapResultImpl<K, V, F>.undefined(factory: factory);
  }

  operator []=(final K key, final V value);

  ObservableMapResultChange<K, V, F>? add(final K key, final V value);

  ObservableMapResultChange<K, V, F>? addAll(final Map<K, V> other);

  ObservableMapResultChange<K, V, F>? applyAction(final ObservableMapResultUpdateAction<K, V, F> action);

  ObservableMapResultChange<K, V, F>? clear();

  ObservableMapResultChange<K, V, F>? remove(final K key);

  ObservableMapResultChange<K, V, F>? removeWhere(final bool Function(K key, V value) predicate);

  ObservableMapResultChange<K, V, F>? setData(final Map<K, V> data);

  ObservableMapResultChange<K, V, F>? setFailure(final F failure);

  ObservableMapResultChange<K, V, F>? setUndefined();
}

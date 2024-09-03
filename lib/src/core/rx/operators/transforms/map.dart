part of '../../../collections/map/rx_impl.dart';

abstract class OperatorTransformAsMap<T, K, V> extends RxMapImpl<K, V>
    with BaseTransformOperator<T, ObservableMapState<K, V>, ObservableMapUpdateAction<K, V>> {
  @override
  final Observable<T> source;

  OperatorTransformAsMap({
    required this.source,
    super.factory,
  });

  @override
  void handleUpdate(final ObservableMapUpdateAction<K, V> action) {
    applyAction(action);
  }
}

class OperatorTransformAsMapArg<T, K, V> extends OperatorTransformAsMap<T, K, V> {
  final MapUpdater<K, V, T> transformFn;

  OperatorTransformAsMapArg({
    required super.source,
    required this.transformFn,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final T value,
    final Emitter<ObservableMapUpdateAction<K, V>> updater,
  ) {
    transformFn(this, value, updater);
  }
}

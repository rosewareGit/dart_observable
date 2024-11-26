import '../../../../../../dart_observable.dart';
import '../../../collections/map/stateful/rx_stateful.dart';
import '../_base_transform.dart';

class StatefulMapTransform<T, K, V, S> extends RxStatefulMapImpl<K, V, S>
    with BaseTransformOperator<T, Either<Map<K, V>, S>, Either<Map<K, V>, S>> {
  @override
  final Observable<T> source;

  final StatefulMapUpdater<K, V, S, T>? transformFn;

  StatefulMapTransform({
    required this.source,
    required super.factory,
    this.transformFn,
  }) : super(<K, V>{});

  @override
  void handleUpdate(final Either<Map<K, V>, S> action) {
    action.fold(
      onLeft: (final Map<K, V> data) => setData(data),
      onRight: (final S right) => setState(right),
    );
  }

  @override
  void transformChange(
    final T value,
    final Emitter<Either<Map<K, V>, S>> updater,
  ) {
    assert(transformFn != null, 'override transformChange or provide a transformFn');
    transformFn?.call(this, value, updater);
  }
}

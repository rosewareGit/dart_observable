import '../../../../../../dart_observable.dart';
import '../../../collections/set/stateful/rx_stateful.dart';
import '../_base_transform.dart';

class StatefulSetTransform<T, E, S> extends RxStatefulSetImpl<E, S>
    with BaseTransformOperator<T, Either<Set<E>, S>, Either<Set<E>, S>> {
  @override
  final Observable<T> source;

  final StatefulSetUpdater<E, S, T>? transformFn;

  StatefulSetTransform({
    required this.source,
    required super.factory,
    this.transformFn,
  }) : super(<E>{});

  @override
  void handleUpdate(final Either<Set<E>, S> action) {
    action.fold(
      onLeft: (final Set<E> data) => setData(data),
      onRight: (final S right) => setState(right),
    );
  }

  @override
  void transformChange(
    final T value,
    final Emitter<Either<Set<E>, S>> updater,
  ) {
    transformFn?.call(this, value, updater);
  }
}

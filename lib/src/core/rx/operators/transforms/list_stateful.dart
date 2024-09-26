import '../../../../../../dart_observable.dart';
import '../../../collections/list/stateful/rx_stateful.dart';
import '../_base_transform.dart';

class StatefulListTransform<T, E, S> extends RxStatefulListImpl<E, S>
    with BaseTransformOperator<T, ObservableStatefulListState<E, S>, Either<List<E>, S>> {
  @override
  final Observable<T> source;
  final StatefulListUpdater<E, S, T>? transformFn;

  StatefulListTransform({
    required this.source,
    required super.factory,
    this.transformFn,
  }) : super(<E>[]);

  @override
  void handleUpdate(final Either<List<E>, S> action) {
    action.fold(
      onLeft: (final List<E> data) => setData(data),
      onRight: (final S right) => setState(right),
    );
  }

  @override
  void transformChange(
    final T value,
    final Emitter<Either<List<E>, S>> updater,
  ) {
    assert(transformFn != null, 'override transformChange or provide a transformFn');

    transformFn?.call(this, value, updater);
  }
}

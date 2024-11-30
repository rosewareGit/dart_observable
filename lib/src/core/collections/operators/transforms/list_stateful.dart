import '../../../../../../dart_observable.dart';
import '../../../../api/collections/collection_transforms.dart';
import '../../list/stateful/rx_stateful.dart';
import '../_base_transform.dart';

class StatefulListChangeTransform<E, S, T, C> extends RxStatefulListImpl<E, S>
    with BaseCollectionTransformOperator<T, Either<List<E>, S>, C, StatefulListChange<E, S>> {
  @override
  final ObservableCollection<T, C> source;
  final StatefulListChangeUpdater<E, S, C, T>? transformFn;

  StatefulListChangeTransform({
    required this.source,
    this.transformFn,
  }) : super(<E>[]);

  @override
  void handleChange(final C change) {
    assert(
      transformFn != null,
      'You need to extend this class and implement the handleChange method or provide a transformFn',
    );
    transformFn?.call(this, source.value, change, applyAction);
  }
}

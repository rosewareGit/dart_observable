import '../../../../../../dart_observable.dart';
import '../../../../api/collections/collection_transforms.dart';
import '../../list/stateful/rx_stateful.dart';
import '../_base_transform.dart';

class StatefulListChangeTransform<E, S, CS extends CollectionState<C>, C> extends RxStatefulListImpl<E, S>
    with BaseCollectionTransformOperator<CS, ObservableStatefulListState<E, S>, C, Either<ObservableListChange<E>, S>> {
  @override
  final Observable<CS> source;
  final StatefulListChangeUpdater<E, S, C>? transformFn;

  StatefulListChangeTransform({
    required this.source,
    required super.factory,
    this.transformFn,
  }) : super(<E>[]);

  @override
  void handleChange(
    final C change,
  ) {
    assert(
      transformFn != null,
      'You need to extend this class and implement the handleChange method or provide a transformFn',
    );
    transformFn?.call(this, change, applyAction);
  }
}

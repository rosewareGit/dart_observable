import '../../../../../../dart_observable.dart';
import '../../../../api/collections/collection_transforms.dart';
import '../../map/stateful/rx_stateful.dart';
import '../_base_transform.dart';

class OperatorCollectionTransformMapStateful<K, V, S, CR extends CollectionState<C>, C>
    extends RxStatefulMapImpl<K, V, S>
    with
        BaseCollectionTransformOperator<CR, ObservableStatefulMapState<K, V, S>, C,
            Either<ObservableMapChange<K, V>, S>> {
  @override
  final Observable<CR> source;
  final StatefulMapChangeUpdater<K, V, S, C>? transformFn;

  OperatorCollectionTransformMapStateful({
    required this.source,
    required super.factory,
    this.transformFn,
  }) : super(<K, V>{});

  @override
  void handleChange(final C change) {
    assert(
      transformFn != null,
      'You need to extend this class and implement the handleChange method or provide a transformFn',
    );

    transformFn?.call(this, change, applyAction);
  }
}

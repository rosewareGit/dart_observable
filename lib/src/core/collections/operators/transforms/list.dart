import '../../../../../dart_observable.dart';
import '../../../../api/collections/collection_transforms.dart';
import '../../list/rx_impl.dart';
import '../_base_transform.dart';

class ListChangeTransform<
        E, //
        C,
        CS extends CollectionState<C>> extends RxListImpl<E>
    with BaseCollectionTransformOperator<CS, ObservableListState<E>, C, ObservableListChange<E>> {
  @override
  final Observable<CS> source;
  final ListChangeUpdater<E, C>? transformFn;

  ListChangeTransform({
    required this.source,
    required super.factory,
    this.transformFn,
  });

  @override
  void handleChange(
    final C change,
  ) {
    assert(transformFn != null, 'override handleChange or provide a transformFn');

    transformFn?.call(this, change, applyAction);
  }
}

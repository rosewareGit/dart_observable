import '../../../../../dart_observable.dart';
import '../../../../api/collections/collection_transforms.dart';
import '../../list/rx_impl.dart';
import '../_base_transform.dart';

class ListChangeTransform<
        E, //
        C,
        T> extends RxListImpl<E>
    with BaseCollectionTransformOperator<T, ObservableListState<E>, C, ObservableListChange<E>> {
  @override
  final ObservableCollection<T, C> source;
  final ListChangeUpdater<E, C>? transformFn;

  ListChangeTransform({
    required this.source,
    this.transformFn,
  });

  @override
  void handleChange(final C change) {
    assert(transformFn != null, 'override handleChange or provide a transformFn');

    transformFn?.call(this, change, applyAction);
  }
}

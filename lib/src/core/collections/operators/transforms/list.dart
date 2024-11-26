import '../../../../../dart_observable.dart';
import '../../../../api/collections/collection_transforms.dart';
import '../../list/rx_impl.dart';
import '../_base_transform.dart';

class ListChangeTransform<
    E, // type of the transformed items
    T, // type of the source items
    C> extends RxListImpl<E> with BaseCollectionTransformOperator<T, List<E>, C, ObservableListChange<E>> {
  @override
  final ObservableCollection<T, C> source;
  final ListChangeUpdater<E, C, T>? transformFn;

  ListChangeTransform({
    required this.source,
    this.transformFn,
  });

  @override
  void handleChange(final C change) {
    assert(transformFn != null, 'override handleChange or provide a transformFn');

    transformFn?.call(this, source.value, change, applyAction);
  }
}

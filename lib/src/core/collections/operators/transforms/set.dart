import '../../../../../dart_observable.dart';
import '../../../../api/collections/collection_transforms.dart';
import '../../set/rx_impl.dart';
import '../_base_transform.dart';

class SetChangeTransform<
        E, //
        C,
        T> extends RxSetImpl<E>
    with
        BaseCollectionTransformOperator<
            T, //
            ObservableSetState<E>,
            C,
            ObservableSetChange<E>> {
  @override
  final ObservableCollection<T, C> source;
  final SetChangeUpdater<E, C>? transformFn;

  SetChangeTransform({
    required this.source,
    required super.factory,
    this.transformFn,
  });

  @override
  void handleChange(final C change) {
    assert(transformFn != null, 'override handleChange or provide a transformFn');

    transformFn?.call(this, change, applyAction);
  }
}

import '../../../../../dart_observable.dart';
import '../../../../api/collections/collection_transforms.dart';
import '../../set/rx_impl.dart';
import '../_base_transform.dart';

class SetChangeTransform<
        E, //
        C,
        CS extends CollectionState<C>> extends RxSetImpl<E>
    with
        BaseCollectionTransformOperator<
            CS, //
            ObservableSetState<E>,
            C,
            ObservableSetChange<E>> {
  @override
  final Observable<CS> source;
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

import '../../../dart_observable.dart';
import '../../api/collections/collection_transforms.dart';
import 'operators/switch_maps.dart';
import 'operators/transforms.dart';

abstract class RxCollectionBase<T, C> extends RxBase<T> implements ObservableCollection<T, C> {
  RxCollectionBase(super.value, {super.distinct});

  @override
  ObservableCollectionSwitchMaps<C> get switchMapChangeAs => ObservableCollectionSwitchMapsImpl<T, C>(this);

  @override
  ObservableCollectionTransforms<C, T> get transformChangeAs => ObservableCollectionTransformsImpl<T, C>(this);

  @override
  Disposable onChange({required final void Function(C change) onChange}) {
    return listen(
      onChange: (final _) {
        onChange(change);
      },
    );
  }
}

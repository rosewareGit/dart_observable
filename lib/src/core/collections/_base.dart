import '../../../dart_observable.dart';
import '../../api/collections/collection_transforms.dart';
import 'operators/transforms.dart';

abstract class RxCollectionBase<T, C> extends RxBase<T> implements ObservableCollection<T, C> {
  RxCollectionBase(super.value, {super.distinct});

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

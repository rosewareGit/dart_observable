import '../../../../../../dart_observable.dart';
import '../../../../api/collections/collection_transforms.dart';
import '../../set/stateful/rx_stateful.dart';
import '../_base_transform.dart';

class StatefulSetChangeTransform<E, S, T, C> extends RxStatefulSetImpl<E, S>
    with BaseCollectionTransformOperator<T, ObservableStatefulSetState<E, S>, C, Either<ObservableSetChange<E>, S>> {
  @override
  final ObservableCollection<T, C> source;
  final StatefulSetChangeUpdater<E, S, C>? transformFn;

  StatefulSetChangeTransform({
    required this.source,
    required super.factory,
    this.transformFn,
  }) : super(<E>{});

  @override
  void handleChange(final C change) {
    assert(
      transformFn != null,
      'You need to extend this class and implement the handleChange method or provide a transformFn',
    );

    transformFn?.call(this, change, applyAction);
  }
}

import '../../../../../../dart_observable.dart';
import '../../../operators/_base_transform_proxy.dart';
import '../../operators/filter_item.dart';

class OperatorStatefulSetFilterItem<Self extends RxSetStateful<O, E, S>, O extends ObservableSetStateful<O, E, S>, E,
    S> {
  final O source;
  final Self result;
  final bool Function(E item) predicate;

  late final BaseCollectionTransformOperatorProxy<ObservableSetStatefulState<E, S>, ObservableSetStatefulState<E, S>,
          StateOf<ObservableSetChange<E>, S>, StateOf<ObservableSetChange<E>, S>> proxy =
      BaseCollectionTransformOperatorProxy<ObservableSetStatefulState<E, S>, ObservableSetStatefulState<E, S>,
          StateOf<ObservableSetChange<E>, S>, StateOf<ObservableSetChange<E>, S>>(
    current: result,
    source: source,
    transformChange: transformChange,
  );

  OperatorStatefulSetFilterItem({
    required this.source,
    required this.predicate,
    required final Self Function() instanceBuilder,
  }) : result = instanceBuilder() {
    proxy.init();
  }

  void transformChange(final StateOf<ObservableSetChange<E>, S> change) {
    change.fold(
      onData: (final ObservableSetChange<E> change) {
        ObservableSetFilterOperator.filterItems(change, result.applySetUpdateAction, predicate);
      },
      onCustom: (final S state) {
        result.applyAction(StateOf<ObservableSetUpdateAction<E>, S>.custom(state));
      },
    );
  }
}

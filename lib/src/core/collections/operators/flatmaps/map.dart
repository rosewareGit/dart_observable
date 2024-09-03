import '../../../../../dart_observable.dart';
import '../../../rx/operators/flatmaps/map.dart';

class OperatorCollectionsFlatMapAsMap<E, K, V, C, CS extends CollectionState<C>>
    extends OperatorFlatMapAsMap<K, V, CS, C> {
  OperatorCollectionsFlatMapAsMap({
    required super.source,
    required super.sourceProvider,
    super.factory,
  }) : super(
          toChangeFn: (final CS value, final bool initial) {
            if (initial) {
              return value.asChange();
            }
            return value.lastChange;
          },
        );
}

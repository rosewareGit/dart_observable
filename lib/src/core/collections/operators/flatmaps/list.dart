import '../../../../../dart_observable.dart';
import '../../../rx/operators/flatmaps/list.dart';

class OperatorCollectionsFlatMapAsList<E2, C, CS extends CollectionState<C>> extends OperatorFlatMapAsList<E2, CS, C> {
  OperatorCollectionsFlatMapAsList({
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

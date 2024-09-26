import '../../../../../dart_observable.dart';
import '../../operators/transforms/set.dart';

class ObservableSetFactoryOperator<E>
    extends SetChangeTransform<E, ObservableSetChange<E>, ObservableSetState<E>> {
  ObservableSetFactoryOperator({
    required super.factory,
    required super.source,
  });

  @override
  void handleChange(final ObservableSetChange<E> change) {
    applyAction(ObservableSetUpdateAction<E>.fromChange(change));
  }
}

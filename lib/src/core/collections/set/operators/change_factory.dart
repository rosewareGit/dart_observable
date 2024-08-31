import '../../../../../dart_observable.dart';
import '../../operators/transforms/set.dart';

class ObservableSetFactoryOperator<E>
    extends OperatorTransformAsSet<ObservableSet<E>, E, ObservableSetChange<E>, ObservableSetState<E>> {
  ObservableSetFactoryOperator({
    required super.factory,
    required super.source,
  });

  @override
  void transformChange(
    final ObservableSetChange<E> change,
    final Emitter<ObservableSetUpdateAction<E>> updater,
  ) {
    updater(ObservableSetUpdateAction<E>.fromChange(change));
  }
}

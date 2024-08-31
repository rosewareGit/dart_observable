import '../../../../../dart_observable.dart';

class RxListStatefulState<E, S> extends ObservableListStatefulState<E, S> {
  const RxListStatefulState.custom(super.custom) : super.custom();

  const RxListStatefulState.data(super.data) : super.data();
}

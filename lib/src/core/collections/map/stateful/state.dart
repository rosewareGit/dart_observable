import '../../../../../dart_observable.dart';

class RxMapStatefulState<K, V, S> extends ObservableMapStatefulState<K, V, S> {
  const RxMapStatefulState.custom(super.custom) : super.custom();

  const RxMapStatefulState.data(super.data) : super.data();
}

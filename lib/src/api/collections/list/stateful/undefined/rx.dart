import '../../../../../../dart_observable.dart';
import '../../../../../core/collections/list/stateful/undefined/rx_impl.dart';

abstract class RxListUndefined<E>
    implements ObservableListUndefined<E>, RxListStateful<ObservableListUndefined<E>, E, Undefined> {
  factory RxListUndefined({
    final Iterable<E>? initial,
    final FactoryList<E>? factory,
  }) {
    return RxListUndefinedImpl<E>(
      initial: initial,
      factory: factory,
    );
  }

  void setUndefined();
}

import '../../../../dart_observable.dart';
import '../../../core/collections/list/rx_impl.dart';
import 'rx_actions.dart';

abstract interface class RxList<E> implements ObservableList<E>, RxListActions<E> {
  factory RxList([final Iterable<E>? initial]) {
    return RxListImpl<E>(initial: initial);
  }

  ObservableListChange<E>? applyAction(final ObservableListUpdateAction<E> action);
}

import '../../../../dart_observable.dart';
import '../../../core/collections/list/rx_impl.dart';
import 'rx_actions.dart';

abstract interface class RxList<E> implements ObservableList<E>, RxListActions<E> {
  factory RxList([final Iterable<E>? initial, final List<E> Function(Iterable<E>? items)? factory]) {
    return RxListImpl<E>(initial: initial, factory: factory);
  }

  ObservableListChange<E>? applyAction(final ObservableListUpdateAction<E> action);
}

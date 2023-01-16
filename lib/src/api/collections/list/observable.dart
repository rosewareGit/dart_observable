import '../../../../dart_observable.dart';
import 'change.dart';
import 'state.dart';

abstract interface class ObservableList<E>
    implements ObservableCollection<E, ObservableListChange<E>, ObservableListState<E>> {
  factory ObservableList([
    final Iterable<E>? initial,
    final List<E> Function(Iterable<E>? items)? factory,
  ]) {
    return RxList<E>(initial, factory);
  }

  int get length;

  E? operator [](final int position);

  Observable<E?> rxItem(final int position);
}

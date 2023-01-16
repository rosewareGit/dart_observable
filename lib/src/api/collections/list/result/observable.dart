import '../../../../../dart_observable.dart';
import 'state.dart';

abstract interface class ObservableListResult<E, F>
    implements ObservableCollection<E, ObservableListResultChange<E, F>, ObservableListResultState<E, F>> {
  // TODO

  E? operator [](final int position);

  Observable<E?> rxItem(final bool Function(E item) predicate);

  Observable<E?> rxItemByPos(final int position);
}

import '../../../../../dart_observable.dart';

abstract interface class ObservableListResult<E, F>
    implements ObservableCollection<E, ObservableListResultChange<E, F>, ObservableListResultState<E, F>> {
  E? operator [](final int position);

  Observable<E?> rxItem(final int position);
}

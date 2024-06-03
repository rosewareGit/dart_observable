import 'dart:collection';

import '../../../../dart_observable.dart';

class RxSetState<E> extends ObservableSetState<E> {
  final Set<E> data;

  final ObservableSetChange<E> change;

  RxSetState(final Set<E> set, this.change) : data = set;

  RxSetState.initial(final Set<E> initial)
      : data = initial,
        change = ObservableSetChange<E>(
          added: initial,
        );

  @override
  ObservableSetChange<E> get lastChange => change;

  @override
  UnmodifiableSetView<E> get setView => UnmodifiableSetView<E>(data);

  @override
  ObservableSetChange<E> asChange() {
    return ObservableSetChange<E>(added: data);
  }
}

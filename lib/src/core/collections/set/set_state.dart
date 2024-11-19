import 'dart:collection';

import '../../../../dart_observable.dart';

class RxSetState<E> extends ObservableSetState<E> {
  final Set<E> data;

  RxSetState(final Set<E> set) : data = set;

  RxSetState.initial(final Set<E> initial) : data = initial;

  @override
  UnmodifiableSetView<E> get setView => UnmodifiableSetView<E>(data);
}

import 'dart:collection';

abstract class ObservableSetState<E> {
  UnmodifiableSetView<E> get setView;
}

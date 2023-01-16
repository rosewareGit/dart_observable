import 'dart:collection';

import '../collection_state.dart';
import 'change.dart';

abstract class ObservableSetState<E> extends CollectionState<E, ObservableSetChange<E>> {
  UnmodifiableSetView<E> get setView;
}

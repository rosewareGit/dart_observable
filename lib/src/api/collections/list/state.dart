import 'dart:collection';

import '../collection_state.dart';
import 'change.dart';

abstract class ObservableListState<E> extends CollectionState<E, ObservableListChange<E>> {
  UnmodifiableListView<E> get listView;
}

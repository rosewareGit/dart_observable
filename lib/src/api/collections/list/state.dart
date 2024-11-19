import 'dart:collection';

abstract class ObservableListState<E> {
  UnmodifiableListView<E> get listView;
}

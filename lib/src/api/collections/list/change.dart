import '../item_change.dart';

abstract class ObservableListChange<E> {
  Map<int, E> get added;

  bool get isEmpty => added.isEmpty && removed.isEmpty && updated.isEmpty;

  Map<int, E> get removed;

  Map<int, ObservableItemChange<E>> get updated;
}

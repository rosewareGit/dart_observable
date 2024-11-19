import '../item_change.dart';

abstract class ObservableListChange<E> {
  Map<int, E> get added;

  Map<int, E> get removed;

  Map<int, ObservableItemChange<E>> get updated;

  bool get isEmpty => added.isEmpty && removed.isEmpty && updated.isEmpty;
}

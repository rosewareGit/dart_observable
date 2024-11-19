import '../../../../dart_observable.dart';
import 'list_element.dart';

class ObservableListChangeElements<E> extends ObservableListChange<E> {
  final Map<int, ObservableListElement<E>> addedElements;
  final Map<int, ObservableListElementChange<E>> removedElements;
  final Map<int, ObservableListElementChange<E>> updatedElements;

  ObservableListChangeElements({
    final Map<int, ObservableListElement<E>>? added,
    final Map<int, ObservableListElementChange<E>>? removed,
    final Map<int, ObservableListElementChange<E>>? updated,
  })  : addedElements = added ?? <int, ObservableListElement<E>>{},
        removedElements = removed ?? <int, ObservableListElementChange<E>>{},
        updatedElements = updated ?? <int, ObservableListElementChange<E>>{};

  factory ObservableListChangeElements.fromDiff(
    final List<ObservableListElement<E>> current,
    final List<ObservableListElement<E>> newState,
  ) {
    final Map<int, ObservableListElement<E>> added = <int, ObservableListElement<E>>{};
    final Map<int, ObservableListElementChange<E>> removed = <int, ObservableListElementChange<E>>{};
    final Map<int, ObservableListElementChange<E>> updated = <int, ObservableListElementChange<E>>{};

    for (int i = 0; i < newState.length; i++) {
      if (i < current.length) {
        final ObservableListElement<E> currentValue = current[i];
        if (currentValue.value != newState[i].value) {
          updated[i] = ObservableListElementChange<E>(
            element: currentValue,
            oldValue: currentValue.value,
            newValue: newState[i].value,
          );
        }
      } else {
        added[i] = newState[i];
      }
    }

    for (int i = newState.length; i < current.length; i++) {
      removed[i] = ObservableListElementChange<E>(
        element: current[i],
        oldValue: current[i].value,
        newValue: current[i].value,
      );
    }

    return ObservableListChangeElements<E>(
      added: added,
      removed: removed,
      updated: updated,
    );
  }

  @override
  Map<int, E> get added {
    return addedElements.map(
      (final int key, final ObservableListElement<E> value) => MapEntry<int, E>(
        key,
        value.value,
      ),
    );
  }

  @override
  Map<int, E> get removed {
    return removedElements.map(
      (final int key, final ObservableListElementChange<E> change) => MapEntry<int, E>(
        key,
        change.oldValue,
      ),
    );
  }

  @override
  Map<int, ObservableItemChange<E>> get updated {
    return updatedElements.map(
      (final int key, final ObservableListElementChange<E> value) => MapEntry<int, ObservableItemChange<E>>(
        key,
        ObservableItemChange<E>(
          oldValue: value.oldValue,
          newValue: value.newValue,
        ),
      ),
    );
  }
}

class ObservableListElementChange<E> {
  final ObservableListElement<E> element;
  final E oldValue;
  final E newValue;

  ObservableListElementChange({
    required this.element,
    required this.oldValue,
    required this.newValue,
  });
}

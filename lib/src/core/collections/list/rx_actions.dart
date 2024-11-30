import '../../../../dart_observable.dart';
import '../../../api/collections/list/rx_actions.dart';
import 'change_elements.dart';
import 'list_element.dart';

mixin RxListActionsImpl<E> implements RxListActions<E> {
  List<ObservableListElement<E>> get data;

  @override
  void operator []=(final int index, final E value) {
    applyListUpdateAction(
      ObservableListUpdateAction<E>(
        updateItems: <int, E>{index: value},
      ),
    );
  }

  @override
  ObservableListChange<E>? add(final E item) {
    return applyListUpdateAction(
      ObservableListUpdateAction<E>(addItems: <E>[item]),
    );
  }

  @override
  ObservableListChange<E>? addAll(final Iterable<E> items) {
    return applyListUpdateAction(
      ObservableListUpdateAction<E>(addItems: items),
    );
  }

  ObservableListChange<E>? applyListUpdateAction(final ObservableListUpdateAction<E> action);

  @override
  ObservableListChange<E>? clear() {
    final List<ObservableListElement<E>> items = data;
    if (items.isEmpty) {
      onEmptyData();
      return null;
    }

    return applyListUpdateAction(
      ObservableListUpdateAction<E>(
        removeAtPositions: <int>{for (int i = 0; i < items.length; i++) i},
      ),
    );
  }

  @override
  ObservableListChange<E>? insert(final int index, final E item) {
    return applyListUpdateAction(
      ObservableListUpdateAction<E>(
        insertAt: <int, Iterable<E>>{
          index: <E>[item],
        },
      ),
    );
  }

  @override
  ObservableListChange<E>? insertAll(final int index, final Iterable<E> items) {
    return applyListUpdateAction(
      ObservableListUpdateAction<E>(
        insertAt: <int, Iterable<E>>{
          index: items,
        },
      ),
    );
  }

  void onEmptyData() {}

  @override
  ObservableListChange<E>? remove(final E item) {
    if (data.isEmpty) {
      onEmptyData();
      return null;
    }

    for (int i = 0; i < data.length; i++) {
      if (data[i].value == item) {
        return applyListUpdateAction(
          ObservableListUpdateAction<E>(removeAtPositions: <int>{i}),
        );
      }
    }

    return null;
  }

  @override
  ObservableListChange<E>? removeAt(final int index) {
    final List<ObservableListElement<E>> items = data;
    if (items.isEmpty) {
      onEmptyData();
      return null;
    }

    if (index < 0 || index >= items.length) {
      return null;
    }

    return applyListUpdateAction(
      ObservableListUpdateAction<E>(removeAtPositions: <int>{index}),
    );
  }

  @override
  ObservableListChange<E>? removeWhere(final bool Function(E item) predicate) {
    final Set<int> removed = <int>{};
    final List<ObservableListElement<E>> items = data;

    if (items.isEmpty) {
      onEmptyData();
      return null;
    }

    final int length = items.length;
    for (int i = 0; i < length; i++) {
      if (predicate(items[i].value)) {
        removed.add(i);
      }
    }

    if (removed.isEmpty) {
      return null;
    }

    return applyListUpdateAction(
      ObservableListUpdateAction<E>(removeAtPositions: removed),
    );
  }

  @override
  ObservableListChange<E>? setData(final List<E> data) {
    final List<ObservableListElement<E>> current = this.data;
    final List<ObservableListElement<E>> newItems = <ObservableListElement<E>>[];

    ObservableListElement<E>? prevElement;
    for (final E item in data) {
      final ObservableListElement<E> observableListElement = ObservableListElement<E>(
        value: item,
        previousElement: prevElement,
        nextElement: null,
      );
      prevElement?.nextElement = observableListElement;
      prevElement = observableListElement;
      newItems.add(observableListElement);
    }

    final ObservableListChangeElements<E> change = ObservableListChangeElements<E>.fromDiff(current, newItems);
    if (change.isEmpty) {
      return null;
    }

    return applyListUpdateAction(ObservableListUpdateAction<E>.fromChange(change));
  }
}

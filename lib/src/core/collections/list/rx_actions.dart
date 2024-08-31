import '../../../../dart_observable.dart';
import '../../../api/collections/list/rx_actions.dart';

mixin RxListActionsImpl<E> implements RxListActions<E> {
  List<E> get data;

  @override
  void operator []=(final int index, final E value) {
    applyListUpdateAction(
      ObservableListUpdateAction<E>.update(
        <int, E>{index: value},
      ),
    );
  }

  @override
  ObservableListChange<E>? add(final E item) {
    return applyListUpdateAction(
      ObservableListUpdateAction<E>.add(
        <MapEntry<int?, Iterable<E>>>[
          MapEntry<int?, Iterable<E>>(null, <E>[item]),
        ],
      ),
    );
  }

  @override
  ObservableListChange<E>? addAll(final Iterable<E> items) {
    return applyListUpdateAction(
      ObservableListUpdateAction<E>.add(
        <MapEntry<int?, Iterable<E>>>[
          MapEntry<int?, Iterable<E>>(null, items),
        ],
      ),
    );
  }

  ObservableListChange<E>? applyListUpdateAction(final ObservableListUpdateAction<E> action);

  @override
  ObservableListChange<E>? clear() {
    final List<E> items = data;
    if (items.isEmpty) {
      onEmptyData();
      return null;
    }

    return applyListUpdateAction(
      ObservableListUpdateAction<E>.remove(
        <int>{for (int i = 0; i < items.length; i++) i},
      ),
    );
  }

  @override
  ObservableListChange<E>? insert(final int index, final E item) {
    return applyListUpdateAction(
      ObservableListUpdateAction<E>.add(
        <MapEntry<int?, Iterable<E>>>[
          MapEntry<int?, Iterable<E>>(index, <E>[item]),
        ],
      ),
    );
  }

  @override
  ObservableListChange<E>? insertAll(final int index, final Iterable<E> items) {
    return applyListUpdateAction(
      ObservableListUpdateAction<E>.add(
        <MapEntry<int?, Iterable<E>>>[
          MapEntry<int?, Iterable<E>>(index, items),
        ],
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

    final int index = data.indexOf(item);
    if (index == -1) {
      return null;
    }
    return applyListUpdateAction(
      ObservableListUpdateAction<E>.remove(<int>{index}),
    );
  }

  @override
  ObservableListChange<E>? removeAt(final int index) {
    final List<E> items = data;
    if (items.isEmpty) {
      onEmptyData();
      return null;
    }

    if (index < 0 || index >= items.length) {
      return null;
    }
    return applyListUpdateAction(
      ObservableListUpdateAction<E>.remove(<int>{index}),
    );
  }

  @override
  ObservableListChange<E>? removeWhere(final bool Function(E item) predicate) {
    final Set<int> removed = <int>{};
    final List<E> items = data;

    if (items.isEmpty) {
      onEmptyData();
      return null;
    }

    for (int i = 0; i < items.length; i++) {
      if (predicate(items[i])) {
        removed.add(i);
      }
    }

    if (removed.isEmpty) {
      return null;
    }
    return applyListUpdateAction(
      ObservableListUpdateAction<E>.remove(removed),
    );
  }

  @override
  ObservableListChange<E>? setData(final List<E> data) {
    final List<E> current = this.data;
    final ObservableListChange<E> change = ObservableListChange<E>.fromDiff(current, data);
    if (change.isEmpty) {
      return null;
    }

    final ObservableListUpdateAction<E> action = ObservableListUpdateAction<E>.fromChange(change);
    return applyListUpdateAction(action);
  }
}

import '../../../../dart_observable.dart';
import '../../../api/collections/set/rx_actions.dart';

mixin RxSetActionsImpl<E> implements RxSetActions<E> {
  Set<E> get data;

  @override
  ObservableSetChange<E>? add(final E item) {
    return applySetUpdateAction(
      ObservableSetUpdateAction<E>(
        addItems: <E>{item},
        removeItems: <E>{},
      ),
    );
  }

  @override
  ObservableSetChange<E>? addAll(final Iterable<E> items) {
    return applySetUpdateAction(
      ObservableSetUpdateAction<E>(
        addItems: items.toSet(),
        removeItems: <E>{},
      ),
    );
  }

  ObservableSetChange<E>? applySetUpdateAction(final ObservableSetUpdateAction<E> action);

  @override
  ObservableSetChange<E>? clear() {
    final Set<E> items = data;
    if (items.isEmpty) {
      return null;
    }

    return applySetUpdateAction(
      ObservableSetUpdateAction<E>(
        removeItems: items,
        addItems: <E>{},
      ),
    );
  }

  @override
  ObservableSetChange<E>? remove(final E item) {
    return applySetUpdateAction(
      ObservableSetUpdateAction<E>(
        addItems: <E>{},
        removeItems: <E>{item},
      ),
    );
  }

  @override
  ObservableSetChange<E>? removeWhere(final bool Function(E item) predicate) {
    final Set<E> data = this.data;
    if (data.isEmpty) {
      return null;
    }

    final Set<E> removed = data.where(predicate).toSet();
    if (removed.isEmpty) {
      return null;
    }

    return applySetUpdateAction(
      ObservableSetUpdateAction<E>(
        addItems: <E>{},
        removeItems: removed,
      ),
    );
  }

  @override
  ObservableSetChange<E>? setData(final Set<E> data) {
    final Set<E> current = this.data;

    final ObservableSetChange<E> change = ObservableSetChange<E>.fromDiff(current, data);
    if (change.isEmpty) {
      return null;
    }

    final ObservableSetUpdateAction<E> action = ObservableSetUpdateAction<E>.fromChange(change);
    return applySetUpdateAction(action);
  }
}

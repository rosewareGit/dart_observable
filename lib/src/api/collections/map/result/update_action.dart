import '../../update_action.dart';
import '../change.dart';

sealed class ObservableMapResultUpdateAction<K, V, F> extends ObservableCollectionUpdateAction {
  void when({
    final void Function()? onUndefined,
    final void Function(F failure)? onFailure,
    final void Function(Map<K, V> addItems, Iterable<K> removeItems)? onData,
  }) {
    switch (this) {
      case ObservableMapResultUpdateActionUndefined<K, V, F> _:
        if (onUndefined != null) {
          onUndefined();
        }
        break;
      case final ObservableMapResultUpdateActionFailure<K, V, F> failure:
        if (onFailure != null) {
          onFailure(failure.failure);
        }
        break;
      case final ObservableMapResultUpdateActionData<K, V, F> data:
        if (onData != null) {
          onData(data.addItems, data.removeItems);
        }
        break;
    }
  }
}

class ObservableMapResultUpdateActionData<K, V, F> extends ObservableMapResultUpdateAction<K, V, F> {
  final Map<K, V> addItems;

  final Iterable<K> removeItems;
  ObservableMapResultUpdateActionData({
    required this.removeItems,
    required this.addItems,
  });

  bool get isEmpty => removeItems.isEmpty && addItems.isEmpty;

  ObservableMapChange<K, V> apply(final Map<K, V> updatedMap) {
    return ObservableMapChange.fromAction(
      state: updatedMap,
      addItems: addItems,
      removeItems: removeItems,
    );
  }
}

class ObservableMapResultUpdateActionFailure<K, V, F> extends ObservableMapResultUpdateAction<K, V, F> {
  final F failure;

  ObservableMapResultUpdateActionFailure({
    required this.failure,
  });
}

class ObservableMapResultUpdateActionUndefined<K, V, F> extends ObservableMapResultUpdateAction<K, V, F> {
  ObservableMapResultUpdateActionUndefined();
}

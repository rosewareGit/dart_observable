import '../../update_action.dart';
import '../change.dart';

sealed class ObservableSetResultUpdateAction<E, F> extends ObservableCollectionUpdateAction {
  void when({
    final void Function()? onUndefined,
    final void Function(F failure)? onFailure,
    final void Function(Set<E> addItems, Set<E> removeItems)? onData,
  }) {
    switch (this) {
      case ObservableSetResultUpdateActionUndefined<E, F> _:
        if (onUndefined != null) {
          onUndefined();
        }
        break;
      case final ObservableSetResultUpdateActionFailure<E, F> failure:
        if (onFailure != null) {
          onFailure(failure.failure);
        }
        break;
      case final ObservableSetResultUpdateActionData<E, F> data:
        if (onData != null) {
          onData(data.addItems, data.removeItems);
        }
        break;
    }
  }
}

class ObservableSetResultUpdateActionUndefined<E, F> extends ObservableSetResultUpdateAction<E, F> {
  ObservableSetResultUpdateActionUndefined();
}

class ObservableSetResultUpdateActionFailure<E, F> extends ObservableSetResultUpdateAction<E, F> {
  ObservableSetResultUpdateActionFailure({
    required this.failure,
  });

  final F failure;
}

class ObservableSetResultUpdateActionData<E, F> extends ObservableSetResultUpdateAction<E, F> {
  ObservableSetResultUpdateActionData({
    required this.removeItems,
    required this.addItems,
  });

  final Set<E> addItems;
  final Set<E> removeItems;

  bool get isEmpty => removeItems.isEmpty && addItems.isEmpty;

  ObservableSetChange<E> apply(final Set<E> sourceData) {
    return ObservableSetChange.fromAction(
      sourceToUpdate: sourceData,
      addItems: addItems,
      removeItems: removeItems,
    );
  }
}

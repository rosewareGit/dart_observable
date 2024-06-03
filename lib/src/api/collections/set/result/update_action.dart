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

class ObservableSetResultUpdateActionData<E, F> extends ObservableSetResultUpdateAction<E, F> {
  final Set<E> addItems;
  final Set<E> removeItems;

  ObservableSetResultUpdateActionData({
    required this.removeItems,
    required this.addItems,
  });

  bool get isEmpty => removeItems.isEmpty && addItems.isEmpty;

  ObservableSetChange<E> apply(final Set<E> sourceData) {
    return ObservableSetChange.fromAction(
      sourceToUpdate: sourceData,
      addItems: addItems,
      removeItems: removeItems,
    );
  }
}

class ObservableSetResultUpdateActionFailure<E, F> extends ObservableSetResultUpdateAction<E, F> {
  final F failure;

  ObservableSetResultUpdateActionFailure({
    required this.failure,
  });
}

class ObservableSetResultUpdateActionUndefined<E, F> extends ObservableSetResultUpdateAction<E, F> {
  ObservableSetResultUpdateActionUndefined();
}

import 'dart:collection';

import '../../collection_state.dart';
import '../change.dart';

sealed class ObservableListResultChange<E, F> {
  void when({
    final void Function(List<E> removedItems)? onUndefined,
    final void Function(F failure, List<E> removedItems)? onFailure,
    final void Function(UnmodifiableListView<E> data, ObservableListChange<E> change)? onSuccess,
  }) {
    switch (this) {
      case final ObservableListResultChangeUndefined<E, F> undefined:
        if (onUndefined != null) {
          onUndefined(undefined.removedItems);
        }
        break;
      case final ObservableListResultChangeFailure<E, F> failure:
        if (onFailure != null) {
          onFailure(failure.failure, failure.removedItems);
        }
        break;
      case final ObservableListResultChangeData<E, F> data:
        if (onSuccess != null) {
          onSuccess(data.data, data.change);
        }
        break;
    }
  }
}

class ObservableListResultChangeUndefined<E, F> extends ObservableListResultChange<E, F> {
  final List<E> removedItems;

  ObservableListResultChangeUndefined({
    final List<E>? removedItems,
  }) : removedItems = removedItems ?? <E>[];
}

class ObservableListResultChangeFailure<E, F> extends ObservableListResultChange<E, F> {
  final F failure;
  final List<E> removedItems;

  ObservableListResultChangeFailure({
    required this.failure,
    final List<E>? removedItems,
  }) : removedItems = removedItems ?? <E>[];
}

class ObservableListResultChangeData<E, F> extends ObservableListResultChange<E, F> {
  final ObservableListChange<E> change;
  final UnmodifiableListView<E> data;

  ObservableListResultChangeData({
    required this.change,
    required this.data,
  });
}

sealed class ObservableListResultState<E, F> implements CollectionState<E, ObservableListResultChange<E, F>> {
  R fold<R>({
    required final R Function() onUndefined,
    required final R Function(F failure) onFailure,
    required final R Function(UnmodifiableListView<E> data, ObservableListChange<E> change) onSuccess,
  }) {
    switch (this) {
      case final ObservableListResultStateUndefined<E, F> _:
        return onUndefined();
      case final ObservableListResultStateFailure<E, F> failure:
        return onFailure(failure.failure);
      case final ObservableListResultStateData<E, F> data:
        return onSuccess(data.data, data.change);
    }
  }

  R? when<R>({
    final R Function()? onUndefined,
    final R Function(F failure)? onFailure,
    final R Function(UnmodifiableListView<E> data, ObservableListChange<E> change)? onSuccess,
  }) {
    switch (this) {
      case final ObservableListResultStateUndefined<E, F> _:
        if (onUndefined != null) {
          return onUndefined();
        }
        break;
      case final ObservableListResultStateFailure<E, F> failure:
        if (onFailure != null) {
          return onFailure(failure.failure);
        }
        break;
      case final ObservableListResultStateData<E, F> data:
        if (onSuccess != null) {
          return onSuccess(data.data, data.change);
        }
        break;
    }
    return null;
  }
}

abstract class ObservableListResultStateUndefined<E, F> extends ObservableListResultState<E, F> {
  List<E> get removedItems;
}

abstract class ObservableListResultStateFailure<E, F> extends ObservableListResultState<E, F> {
  F get failure;

  List<E> get removedItems;
}

abstract class ObservableListResultStateData<E, F> extends ObservableListResultState<E, F> {
  UnmodifiableListView<E> get data;

  ObservableListChange<E> get change;
}

import 'package:collection/collection.dart';

import '../../../../../src/core/collections/set/result.dart';
import '../../collection_state.dart';
import '../change.dart';
import 'update_action.dart';

sealed class ObservableSetResultChange<E, F> {
  ObservableSetResultUpdateAction<E, F> get asAction {
    return fold(
      onUndefined: (final _) => ObservableSetResultUpdateActionUndefined<E, F>(),
      onFailure: (final F failure, final Set<E> removedItems) => ObservableSetResultUpdateActionFailure<E, F>(
        failure: failure,
      ),
      onSuccess: (final UnmodifiableSetView<E> data, final ObservableSetChange<E> change) =>
          ObservableSetResultUpdateActionData<E, F>(
        addItems: change.added,
        removeItems: change.removed,
      ),
    );
  }

  R fold<R>({
    required final R Function(Set<E> removedItems) onUndefined,
    required final R Function(F failure, Set<E> removedItems) onFailure,
    required final R Function(UnmodifiableSetView<E> data, ObservableSetChange<E> change) onSuccess,
  }) {
    switch (this) {
      case final ObservableSetResultChangeUndefined<E, F> undefined:
        return onUndefined(undefined.removedItems);
      case final ObservableSetResultChangeFailure<E, F> failure:
        return onFailure(failure.failure, failure.removedItems);
      case final ObservableSetResultChangeData<E, F> data:
        return onSuccess(data.data, data.change);
    }
  }

  void when({
    final void Function(Set<E> removedItems)? onUndefined,
    final void Function(F failure, Set<E> removedItems)? onFailure,
    final void Function(UnmodifiableSetView<E> data, ObservableSetChange<E> change)? onSuccess,
  }) {
    switch (this) {
      case final ObservableSetResultChangeUndefined<E, F> undefined:
        if (onUndefined != null) {
          onUndefined(undefined.removedItems);
        }
        break;
      case final ObservableSetResultChangeFailure<E, F> failure:
        if (onFailure != null) {
          onFailure(failure.failure, failure.removedItems);
        }
        break;
      case final ObservableSetResultChangeData<E, F> data:
        if (onSuccess != null) {
          onSuccess(data.data, data.change);
        }
        break;
    }
  }
}

class ObservableSetResultChangeData<E, F> extends ObservableSetResultChange<E, F> {
  final ObservableSetChange<E> change;
  final UnmodifiableSetView<E> data;

  ObservableSetResultChangeData({
    required this.change,
    required this.data,
  });
}

class ObservableSetResultChangeFailure<E, F> extends ObservableSetResultChange<E, F> {
  final F failure;
  final Set<E> removedItems;

  ObservableSetResultChangeFailure({
    required this.failure,
    final Set<E>? removedItems,
  }) : removedItems = removedItems ?? <E>{};
}

class ObservableSetResultChangeUndefined<E, F> extends ObservableSetResultChange<E, F> {
  final Set<E> removedItems;

  ObservableSetResultChangeUndefined({
    final Set<E>? removedItems,
  }) : removedItems = removedItems ?? <E>{};
}

sealed class ObservableSetResultState<E, F> extends CollectionState<E, ObservableSetResultChange<E, F>> {
  ObservableSetResultState();

  factory ObservableSetResultState.failure(
    final F failure, {
    final Set<E>? removedItems,
  }) {
    return RxSetResultStateFailure<E, F>(failure, removedItems: removedItems ?? <E>{});
  }

  factory ObservableSetResultState.undefined({
    final Set<E>? removedItems,
  }) {
    return RxSetResultStateUndefined<E, F>(removedItems: removedItems ?? <E>{});
  }

  factory ObservableSetResultState.data({
    required final Set<E> data,
    required final ObservableSetChange<E> change,
  }) {
    return RxSetResultStateData<E, F>(data, change);
  }

  R fold<R>({
    required final R Function() onUndefined,
    required final R Function(F failure) onFailure,
    required final R Function(UnmodifiableSetView<E> data, ObservableSetChange<E> change) onSuccess,
  }) {
    switch (this) {
      case final ObservableSetResultStateUndefined<E, F> _:
        return onUndefined();
      case final ObservableSetResultStateFailure<E, F> failure:
        return onFailure(failure.failure);
      case final ObservableSetResultStateData<E, F> data:
        return onSuccess(data.data, data.change);
    }
  }

  void when({
    final void Function()? onUndefined,
    final void Function(F failure)? onFailure,
    final void Function(UnmodifiableSetView<E> data, ObservableSetChange<E> change)? onSuccess,
  }) {
    switch (this) {
      case final ObservableSetResultStateUndefined<E, F> _:
        if (onUndefined != null) {
          return onUndefined();
        }
        break;
      case final ObservableSetResultStateFailure<E, F> failure:
        if (onFailure != null) {
          return onFailure(failure.failure);
        }
        break;
      case final ObservableSetResultStateData<E, F> data:
        if (onSuccess != null) {
          return onSuccess(data.data, data.change);
        }
        break;
    }
  }
}

abstract class ObservableSetResultStateData<E, F> extends ObservableSetResultState<E, F> {
  ObservableSetChange<E> get change;

  UnmodifiableSetView<E> get data;
}

abstract class ObservableSetResultStateFailure<E, F> extends ObservableSetResultState<E, F> {
  F get failure;

  Set<E> get removedItems;
}

abstract class ObservableSetResultStateUndefined<E, F> extends ObservableSetResultState<E, F> {
  Set<E> get removedItems;
}

import 'dart:collection';

import '../../../../../dart_observable.dart';

sealed class ObservableMapResultChange<K, V, F> {
  ObservableMapResultUpdateAction<K, V, F> get asAction {
    return fold(
      onUndefined: (_) => ObservableMapResultUpdateActionUndefined<K, V, F>(),
      onFailure: (final F failure, final Map<K, V> removedItems) => ObservableMapResultUpdateActionFailure<K, V, F>(
        failure: failure,
      ),
      onSuccess: (final UnmodifiableMapView<K, V> data, final ObservableMapChange<K, V> change) =>
          ObservableMapResultUpdateActionData<K, V, F>(
        removeItems: change.removed.keys,
        addItems: data,
      ),
    );
  }

  R fold<R>({
    required final R Function(Map<K, V> removedItems) onUndefined,
    required final R Function(F failure, Map<K, V> removedItems) onFailure,
    required final R Function(UnmodifiableMapView<K, V> data, ObservableMapChange<K, V> change) onSuccess,
  }) {
    switch (this) {
      case final ObservableMapResultChangeUndefined<K, V, F> undefined:
        return onUndefined(undefined.removedItems);
      case final ObservableMapResultChangeFailure<K, V, F> failure:
        return onFailure(failure.failure, failure.removedItems);
      case final ObservableMapResultChangeData<K, V, F> data:
        return onSuccess(data.data, data.change);
    }
  }

  void when({
    final void Function(Map<K, V> removedItems)? onUndefined,
    final void Function(F failure, Map<K, V> removedItems)? onFailure,
    final void Function(UnmodifiableMapView<K, V>, ObservableMapChange<K, V> change)? onSuccess,
  }) {
    switch (this) {
      case final ObservableMapResultChangeUndefined<K, V, F> undefined:
        if (onUndefined != null) {
          onUndefined(undefined.removedItems);
        }
        break;
      case final ObservableMapResultChangeFailure<K, V, F> failure:
        if (onFailure != null) {
          onFailure(failure.failure, failure.removedItems);
        }
        break;
      case final ObservableMapResultChangeData<K, V, F> data:
        if (onSuccess != null) {
          onSuccess(data.data, data.change);
        }
        break;
    }
  }
}

class ObservableMapResultChangeData<K, V, F> extends ObservableMapResultChange<K, V, F> {
  final ObservableMapChange<K, V> change;
  final UnmodifiableMapView<K, V> data;

  ObservableMapResultChangeData({
    required this.change,
    required this.data,
  });
}

class ObservableMapResultChangeFailure<K, V, F> extends ObservableMapResultChange<K, V, F> {
  final F failure;
  final Map<K, V> removedItems;

  ObservableMapResultChangeFailure({
    required this.failure,
    final Map<K, V>? removedItems,
  }) : removedItems = removedItems ?? <K, V>{};
}

class ObservableMapResultChangeUndefined<K, V, F> extends ObservableMapResultChange<K, V, F> {
  final Map<K, V> removedItems;

  ObservableMapResultChangeUndefined({
    final Map<K, V>? removedItems,
  }) : removedItems = removedItems ?? <K, V>{};
}

sealed class ObservableMapResultState<K, V, F> implements CollectionState<K, ObservableMapResultChange<K, V, F>> {
  ObservableMapResultChange<K, V, F> get change {
    switch (this) {
      case final ObservableMapResultStateUndefined<K, V, F> undefined:
        return ObservableMapResultChangeUndefined<K, V, F>(removedItems: undefined.removedItems);
      case final ObservableMapResultStateFailure<K, V, F> failure:
        return ObservableMapResultChangeFailure<K, V, F>(
          failure: failure.failure,
          removedItems: failure.removedItems,
        );
      case final ObservableMapResultStateData<K, V, F> data:
        return ObservableMapResultChangeData<K, V, F>(
          change: data.dataChange,
          data: data.data,
        );
    }
  }

  R fold<R>({
    required final R Function() onUndefined,
    required final R Function(F failure) onFailure,
    required final R Function(UnmodifiableMapView<K, V> data, ObservableMapChange<K, V> change) onSuccess,
  }) {
    switch (this) {
      case final ObservableMapResultStateUndefined<K, V, F> _:
        return onUndefined();
      case final ObservableMapResultStateFailure<K, V, F> failure:
        return onFailure(failure.failure);
      case final ObservableMapResultStateData<K, V, F> data:
        return onSuccess(data.data, data.dataChange);
    }
  }

  R? when<R>({
    final R Function()? onUndefined,
    final R Function(F failure)? onFailure,
    final R Function(UnmodifiableMapView<K, V> data, ObservableMapChange<K, V> change)? onSuccess,
  }) {
    switch (this) {
      case final ObservableMapResultStateUndefined<K, V, F> _:
        if (onUndefined != null) {
          return onUndefined();
        }
        break;
      case final ObservableMapResultStateFailure<K, V, F> failure:
        if (onFailure != null) {
          return onFailure(failure.failure);
        }
        break;
      case final ObservableMapResultStateData<K, V, F> data:
        if (onSuccess != null) {
          return onSuccess(data.data, data.dataChange);
        }
        break;
    }
    return null;
  }
}

abstract class ObservableMapResultStateData<K, V, F> extends ObservableMapResultState<K, V, F> {
  UnmodifiableMapView<K, V> get data;

  ObservableMapChange<K, V> get dataChange;
}

abstract class ObservableMapResultStateFailure<K, V, F> extends ObservableMapResultState<K, V, F> {
  F get failure;

  Map<K, V> get removedItems;
}

abstract class ObservableMapResultStateUndefined<K, V, F> extends ObservableMapResultState<K, V, F> {
  Map<K, V> get removedItems;
}

part of 'result.dart';

class RxSetResultStateData<E, F> extends ObservableSetResultStateData<E, F> {
  final Set<E> _data;

  @override
  final ObservableSetChange<E> change;

  RxSetResultStateData(this._data, this.change);

  @override
  UnmodifiableSetView<E> get data => UnmodifiableSetView<E>(_data);

  @override
  int get hashCode {
    return _data.hashCode ^ change.hashCode;
  }

  @override
  ObservableSetResultChange<E, F> get lastChange => ObservableSetResultChangeData<E, F>(
        change: change,
        data: data,
      );

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;

    return other is RxSetResultStateData<E, F> && other._data == _data && other.change == change;
  }

  @override
  ObservableSetResultChange<E, F> asChange() {
    return ObservableSetResultChangeData<E, F>(
      change: ObservableSetChange<E>(added: _data),
      data: data,
    );
  }
}

class RxSetResultStateFailure<E, F> extends ObservableSetResultStateFailure<E, F> {
  @override
  final F failure;

  @override
  final Set<E> removedItems;

  RxSetResultStateFailure(
    this.failure, {
    required this.removedItems,
  });

  @override
  int get hashCode {
    return failure.hashCode ^ removedItems.hashCode;
  }

  @override
  ObservableSetResultChange<E, F> get lastChange => asChange();

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;

    return other is RxSetResultStateFailure<E, F> && other.failure == failure && other.removedItems == removedItems;
  }

  @override
  ObservableSetResultChange<E, F> asChange() {
    return ObservableSetResultChangeFailure<E, F>(
      failure: failure,
      removedItems: removedItems,
    );
  }
}

class RxSetResultStateUndefined<E, F> extends ObservableSetResultStateUndefined<E, F> {
  @override
  final Set<E> removedItems;

  RxSetResultStateUndefined({
    required this.removedItems,
  });

  @override
  int get hashCode {
    return removedItems.hashCode;
  }

  @override
  ObservableSetResultChange<E, F> get lastChange => asChange();

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;

    return other is RxSetResultStateUndefined<E, F> && other.removedItems == removedItems;
  }

  @override
  ObservableSetResultChange<E, F> asChange() {
    return ObservableSetResultChangeData<E, F>(
      change: ObservableSetChange<E>(added: <E>{}),
      data: UnmodifiableSetView<E>(<E>{}),
    );
  }
}

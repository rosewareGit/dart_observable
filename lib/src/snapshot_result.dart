sealed class SnapshotResult<T, F> {
  const SnapshotResult();

  factory SnapshotResult.failure(final F failure) = _SnapshotResultFailure<T, F>;

  factory SnapshotResult.success(final T data) = _SnapshotResultData<T, F>;

  factory SnapshotResult.undefined() = _SnapshotResultUndefined<T, F>;

  R fold<R>({
    required final R Function(T data) onSuccess,
    required final R Function() onUndefined,
    required final R Function(F failure) onFailure,
  }) {
    final SnapshotResult<T, F> $this = this;
    switch ($this) {
      case _SnapshotResultData<T, F>():
        return onSuccess($this.data);
      case _SnapshotResultUndefined<T, F>():
        return onUndefined();
      case _SnapshotResultFailure<T, F>():
        return onFailure($this.failure);
    }
  }

  void when({
    final void Function(T data)? onData,
    final void Function()? onUndefined,
    final void Function(F failure)? onFailure,
  }) {
    final SnapshotResult<T, F> $this = this;
    switch ($this) {
      case _SnapshotResultData<T, F>():
        onData?.call($this.data);
        break;
      case _SnapshotResultUndefined<T, F>():
        onUndefined?.call();
        break;
      case _SnapshotResultFailure<T, F>():
        onFailure?.call($this.failure);
        break;
    }
  }

  bool get isUndefined {
    return fold(
      onSuccess: (final _) => false,
      onUndefined: () => true,
      onFailure: (final _) => false,
    );
  }

  T? get success {
    return fold(
      onSuccess: (final T data) => data,
      onUndefined: () => null,
      onFailure: (final _) => null,
    );
  }

  F? get failure {
    return fold(
      onSuccess: (final _) => null,
      onUndefined: () => null,
      onFailure: (final F failure) => failure,
    );
  }
}

class _SnapshotResultData<T, F> extends SnapshotResult<T, F> {
  final T data;

  _SnapshotResultData(this.data);

  @override
  bool operator ==(final Object other) {
    return other is _SnapshotResultData<T, F> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

class _SnapshotResultFailure<T, F> extends SnapshotResult<T, F> {
  @override
  final F failure;

  _SnapshotResultFailure(this.failure);

  @override
  bool operator ==(final Object other) {
    return other is _SnapshotResultFailure<T, F> && other.failure == failure;
  }

  @override
  int get hashCode => failure.hashCode;
}

class _SnapshotResultUndefined<T, F> extends SnapshotResult<T, F> {
  @override
  bool operator ==(final Object other) {
    return other is _SnapshotResultUndefined<T, F>;
  }

  @override
  int get hashCode => 0;
}

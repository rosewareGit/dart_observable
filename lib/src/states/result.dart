sealed class Result<T, F> {
  const Result();

  factory Result.failure(final F failure) = _ResultFailure<T, F>;

  factory Result.success(final T value) = _ResultSuccess<T, F>;

  R fold<R>({
    required final R Function(T value) onSuccess,
    required final R Function(F failure) onFailure,
  }) {
    final Result<T, F> $this = this;
    switch ($this) {
      case _ResultSuccess<T, F>():
        return onSuccess($this.success);
      case _ResultFailure<T, F>():
        return onFailure($this.failure);
    }
  }

  T getOrDefault(final T defaultValue) {
    return fold(
      onSuccess: (final T success) => success,
      onFailure: (final F failure) => defaultValue,
    );
  }

  T getOrElse({
    required final T Function(F failure) onFailure,
  }) {
    return fold(
      onSuccess: (final T success) => success,
      onFailure: (final F failure) => onFailure(failure),
    );
  }

  T? getOrNull() {
    return fold(
      onSuccess: (final T success) => success,
      onFailure: (final _) => null,
    );
  }

  T getOrThrow() {
    return fold(
      onSuccess: (final T success) => success,
      onFailure: (final F failure) => throw StateError(failure.toString()),
    );
  }

  Result<T, F> recover({
    required final T Function(F failure) onFailure,
  }) {
    return fold(
      onSuccess: (final T success) => this,
      onFailure: (final F failure) => Result<T, F>.success(
        onFailure(failure),
      ),
    );
  }

  void when({
    final void Function(T value)? onSuccess,
    final void Function(F failure)? onFailure,
  }) {
    final Result<T, F> $this = this;
    switch ($this) {
      case _ResultSuccess<T, F>():
        if (onSuccess != null) {
          onSuccess($this.success);
        }
        break;
      case _ResultFailure<T, F>():
        if (onFailure != null) {
          onFailure($this.failure);
        }
        break;
    }
  }
}

class _ResultFailure<T, F> extends Result<T, F> {
  final F failure;

  _ResultFailure(this.failure);
}

class _ResultSuccess<T, F> extends Result<T, F> {
  final T success;

  _ResultSuccess(this.success);
}

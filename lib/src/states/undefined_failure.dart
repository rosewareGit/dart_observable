sealed class UndefinedFailure<F> {
  const UndefinedFailure();

  factory UndefinedFailure.failure(final F failure) = _Failure<F>;

  factory UndefinedFailure.undefined() = _Undefined<F>;

  F? get failure {
    return fold(
      onUndefined: () => null,
      onFailure: (final F failure) => failure,
    );
  }

  bool get isFailure {
    return fold(
      onUndefined: () => false,
      onFailure: (final _) => true,
    );
  }

  bool get isUndefined {
    return fold(
      onUndefined: () => true,
      onFailure: (final _) => false,
    );
  }

  R fold<R>({
    required final R Function() onUndefined,
    required final R Function(F failure) onFailure,
  }) {
    switch (this) {
      case final _Failure<F> f:
        return onFailure(f.failure);
      case _Undefined<F>():
        return onUndefined();
    }
  }
}

class _Failure<F> extends UndefinedFailure<F> {
  @override
  final F failure;

  _Failure(this.failure);

  @override
  int get hashCode => failure.hashCode;

  @override
  bool operator ==(final Object other) {
    return other is _Failure<F> && other.failure == failure;
  }
}

class _Undefined<F> extends UndefinedFailure<F> {
  const _Undefined();

  @override
  int get hashCode => 0;

  @override
  bool operator ==(final Object other) {
    return other is _Undefined<F>;
  }
}

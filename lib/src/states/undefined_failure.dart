sealed class UndefinedFailure<F> {
  const UndefinedFailure();

  factory UndefinedFailure.undefined() = _Undefined<F>;

  factory UndefinedFailure.failure(final F failure) = _Failure<F>;

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

  F? get failure {
    return fold(
      onUndefined: () => null,
      onFailure: (final F failure) => failure,
    );
  }

  bool get isUndefined {
    return fold(
      onUndefined: () => true,
      onFailure: (final _) => false,
    );
  }

  bool get isFailure {
    return fold(
      onUndefined: () => false,
      onFailure: (final _) => true,
    );
  }
}

class _Undefined<F> extends UndefinedFailure<F> {}

class _Failure<F> extends UndefinedFailure<F> {
  final F failure;

  _Failure(this.failure);
}

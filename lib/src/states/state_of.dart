sealed class Either<L, R> {
  const Either();

  const factory Either.left(final L left) = _Left<L, R>;

  const factory Either.right(final R right) = _Right<L, R>;

  @override
  int get hashCode;

  bool get isLeft => fold(
        onLeft: (final _) => true,
        onRight: (final _) => false,
      );

  bool get isRight => fold(
        onLeft: (final _) => false,
        onRight: (final _) => true,
      );

  L? get leftOrNull => fold(
        onLeft: (final L left) => left,
        onRight: (final _) => null,
      );

  L get leftOrThrow => fold(
        onLeft: (final L left) => left,
        onRight: (final _) => (throw Exception('Not in left')),
      );

  R? get rightOrNull => fold(
        onLeft: (final _) => null,
        onRight: (final R right) => right,
      );

  R get rightOrThrow => fold(
        onLeft: (final _) => (throw Exception('Not right')),
        onRight: (final R right) => right,
      );

  @override
  bool operator ==(final Object other);

  T fold<T>({
    required final T Function(L left) onLeft,
    required final T Function(R right) onRight,
  }) {
    return switch (this) {
      final _Right<L, R> state => onRight(state.data),
      final _Left<L, R> state => onLeft(state.data),
    };
  }

  void when({
    final void Function(L left)? onLeft,
    final void Function(R right)? onRight,
  }) {
    switch (this) {
      case final _Right<L, R> state:
        onRight?.call(state.data);
        break;
      case final _Left<L, R> state:
        onLeft?.call(state.data);
        break;
    }
  }
}

class _Left<L, R> extends Either<L, R> {
  final L data;

  const _Left(this.data);

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;
    return other is _Left<L, R> && other.data == data;
  }
}

class _Right<L, R> extends Either<L, R> {
  final R data;

  const _Right(this.data);

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;
    return other is _Right<L, R> && other.data == data;
  }
}

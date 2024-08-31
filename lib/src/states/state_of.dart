class StateOf<L, R> {
  final L? data;
  final R? custom;

  final bool _isData;

  const StateOf.custom(this.custom)
      : data = null,
        _isData = false;

  const StateOf.data(this.data)
      : custom = null,
        _isData = true;

  R? get customOrNull => isCustom ? custom : null;

  R get customOrThrow => customOrNull ?? (throw Exception('Right is null'));

  L? get dataOrNull => isData ? data : null;

  L get dataOrThrow => dataOrNull ?? (throw Exception('Left is null'));

  @override
  int get hashCode => data.hashCode ^ custom.hashCode;

  bool get isCustom => !_isData;

  bool get isData => _isData;

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;
    return other is StateOf<L, R> && other.data == data && other.custom == custom;
  }

  T fold<T>({
    required final T Function(L data) onData,
    required final T Function(R custom) onCustom,
  }) {
    if (isData) {
      return onData(dataOrThrow);
    } else {
      return onCustom(customOrThrow);
    }
  }

  @override
  String toString() {
    return isData ? 'Data($data)' : 'Custom($custom)';
  }

  void when({
    final void Function(L data)? onData,
    final void Function(R custom)? onCustom,
  }) {
    if (isData) {
      onData?.call(dataOrThrow);
    } else {
      onCustom?.call(customOrThrow);
    }
  }
}

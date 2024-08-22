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

  bool get isData => _isData;

  bool get isCustom => !_isData;

  L? get dataOrNull => isData ? data : null;

  L get dataOrThrow => dataOrNull ?? (throw Exception('Left is null'));

  R? get customOrNull => isCustom ? custom : null;

  R get customOrThrow => customOrNull ?? (throw Exception('Right is null'));

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

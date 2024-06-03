class ObservableItemChange<E> {
  final E oldValue;
  final E newValue;

  ObservableItemChange({
    required this.oldValue,
    required this.newValue,
  });

  @override
  int get hashCode => oldValue.hashCode ^ newValue.hashCode;

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final ObservableItemChange<E> typedOther = other as ObservableItemChange<E>;
    return typedOther.oldValue == oldValue && typedOther.newValue == newValue;
  }
}

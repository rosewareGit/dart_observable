class Undefined {
  const Undefined();

  @override
  int get hashCode => 0;

  @override
  bool operator ==(final Object other) {
    return other is Undefined;
  }
}

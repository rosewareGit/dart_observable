extension ExtensionIterable<E> on Iterable<E>{

  E? firstWhereOrNull(final bool Function(E element) test){
    for (final E element in this){
      if (test(element)){
        return element;
      }
    }
    return null;
  }
}
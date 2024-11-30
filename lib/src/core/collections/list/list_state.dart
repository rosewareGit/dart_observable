import 'package:collection/collection.dart';

import 'list_element.dart';

class RxListState<E> {
  final List<ObservableListElement<E>> _data;
  final List<E> _cached = <E>[];

  RxListState(
    final Iterable<ObservableListElement<E>> initial,
  ) : _data = _createData(initial: initial) {
    onUpdated();
  }

  factory RxListState.fromData(final Iterable<E> data) {
    return RxListState<E>(
      _convertToObservableListElement(data),
    );
  }

  List<ObservableListElement<E>> get data => _data;

  UnmodifiableListView<E> get listView {
    return UnmodifiableListView<E>(_cached);
  }

  void onUpdated() {
    _cached.clear();
    final int length = _data.length;
    for (int i = 0; i < length; i++) {
      _cached.add(_data[i].value);
    }
  }

  static Iterable<ObservableListElement<E>> _convertToObservableListElement<E>(final Iterable<E>? data) {
    if (data == null) {
      return <ObservableListElement<E>>[];
    }

    final List<ObservableListElement<E>> list = <ObservableListElement<E>>[];
    final int length = data.length;

    ObservableListElement<E>? prevElement;
    for (int i = 0; i < length; i++) {
      final ObservableListElement<E> element = ObservableListElement<E>(
        value: data.elementAt(i),
        previousElement: prevElement,
        nextElement: null,
      );
      prevElement?.nextElement = element;
      list.add(element);
      prevElement = element;
    }
    return list;
  }

  static List<ObservableListElement<E>> _createData<E>({
    required final Iterable<ObservableListElement<E>> initial,
  }) {
    return List<ObservableListElement<E>>.of(initial);
  }
}

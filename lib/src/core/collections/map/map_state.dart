import 'dart:collection';

import '../../../../dart_observable.dart';

class RxMapState<K, V> extends ObservableMapState<K, V> {
  final Map<K, V> data;

  RxMapState(final Map<K, V> map) : data = map;

  RxMapState.initial(final Map<K, V> initial) : data = initial;

  @override
  UnmodifiableMapView<K, V> get mapView => UnmodifiableMapView<K, V>(data);
}

import 'dart:collection';

abstract class ObservableMapState<K, V> {
  UnmodifiableMapView<K, V> get mapView;
}

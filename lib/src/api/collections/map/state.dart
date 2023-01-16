import 'dart:collection';

import '../collection_state.dart';
import 'change.dart';

abstract class ObservableMapState<K, V> extends CollectionState<K, ObservableMapChange<K, V>> {
  UnmodifiableMapView<K, V> get mapView;
}

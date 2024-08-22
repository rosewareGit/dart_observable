import 'dart:collection';

import '../../change_tracking_state.dart';
import 'change.dart';

abstract class ObservableMapState<K, V> extends ChangeTrackingState<ObservableMapChange<K, V>> {
  UnmodifiableMapView<K, V> get mapView;
}

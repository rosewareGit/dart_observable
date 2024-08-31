import 'dart:collection';

import '../../../../dart_observable.dart';

class RxMapState<K, V> extends ObservableMapState<K, V> {
  final Map<K, V> data;
  final ObservableMapChange<K, V> _change;

  RxMapState(final Map<K, V> map, final ObservableMapChange<K, V> change)
      : data = map,
        _change = change;

  RxMapState.initial(final Map<K, V> initial)
      : data = initial,
        _change = ObservableMapChange<K, V>(
          added: initial,
        );

  @override
  ObservableMapChange<K, V> get lastChange => _change;

  @override
  UnmodifiableMapView<K, V> get mapView => UnmodifiableMapView<K, V>(data);

  @override
  ObservableMapChange<K, V> asChange() => ObservableMapChange<K, V>(added: data);
}

import 'dart:async';

import '../../../../../dart_observable.dart';
import '../../../../api/change_tracking_observable.dart';
import '../../../collections/map/rx_impl.dart';

class OperatorFlatMapAsMap<Self extends ChangeTrackingObservable<Self, T, C>, T, C, K, V> extends RxMapImpl<K, V> {
  final ObservableMap<K, V> Function(Self source) mapper;
  final Self source;

  Disposable? _intermediateListener;
  Disposable? _listener;
  ObservableMap<K, V>? _activeRxIntermediate;

  OperatorFlatMapAsMap({
    required this.source,
    required this.mapper,
  }) : super(
          initial: mapper(source).value.mapView,
        );

  @override
  void onActive() {
    super.onActive();
    _initListener();
  }

  @override
  Future<void> onInactive() async {
    await super.onInactive();
    await _cancelListener();
  }

  @override
  void onInit() {
    super.onInit();
    source.addDisposeWorker(() => dispose());
  }

  Future<void> _cancelListener() async {
    _listener?.dispose();
    _intermediateListener?.dispose();
    _listener = null;
    _intermediateListener = null;
    _activeRxIntermediate = null;
  }

  void _initListener() {
    if (_listener != null) {
      return;
    }

    final ObservableMap<K, V> rxIntermediate = mapper(source);
    _activeRxIntermediate = rxIntermediate;

    final ObservableMapChange<K, V> initialChange = rxIntermediate.value.asChange();
    applyAction(
      ObservableMapUpdateAction<K, V>(
        removeItems: initialChange.removed.keys,
        addItems: initialChange.added,
      ),
    );

    _intermediateListener = rxIntermediate.listen(
      onChange: (final ObservableMap<K, V> source) {
        final ObservableMapChange<K, V> change = source.value.lastChange;
        applyAction(
          ObservableMapUpdateAction<K, V>(
            removeItems: change.removed.keys,
            addItems: change.added,
          ),
        );
      },
    );

    _listener = source.listen(
      onChange: (final Self source) {
        final ObservableMap<K, V> rxIntermediate = mapper(source);
        if (_activeRxIntermediate != rxIntermediate) {
          value = rxIntermediate.value;
          _intermediateListener?.dispose();
          _intermediateListener = rxIntermediate.listen(
            onChange: (final ObservableMap<K, V> source) {
              final ObservableMapChange<K, V> change = source.value.lastChange;
              applyAction(
                ObservableMapUpdateAction<K, V>(
                  removeItems: change.removed.keys,
                  addItems: change.added,
                ),
              );
            },
          );
          _activeRxIntermediate = rxIntermediate;
        }
      },
    );
  }
}

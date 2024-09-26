import '../../../../../../dart_observable.dart';
import '../../../../rx/_impl.dart';

Either<V?, S> _getStateForKey<K, V, S>({
  required final ObservableStatefulMapState<K, V, S> state,
  required final K key,
  required final bool isInitial,
}) {
  return state.fold(
    onData: (final ObservableMapState<K, V> map) {
      return Either<V?, S>.left(map.mapView[key]);
    },
    onCustom: (final S state) {
      return Either<V?, S>.right(state);
    },
  );
}

class OperatorObservableMapStatefulRxItem<K, V, S> extends RxImpl<Either<V?, S>> {
  final K key;
  final ObservableStatefulMap<K, V, S> source;

  Disposable? _listener;

  OperatorObservableMapStatefulRxItem({
    required this.source,
    required this.key,
  }) : super(
          _getStateForKey(state: source.value, key: key, isInitial: true),
        );

  @override
  void onActive() {
    super.onActive();
    _initListener();
  }

  @override
  Future<void> onInactive() async {
    await super.onInactive();
    _cancelListener();
  }

  @override
  void onInit() {
    source.addDisposeWorker(() {
      return dispose();
    });
    super.onInit();
  }

  void _cancelListener() {
    _listener?.dispose();
    _listener = null;
  }

  void _initListener() {
    if (_listener != null) {
      return;
    }

    final Either<V?, S> newState = _getStateForKey(state: source.value, key: key, isInitial: true);
    value = newState;

    _listener = source.listen(
      onChange: (final ObservableStatefulMapState<K, V, S> value) {
        final Either<V?, S> newState = _getStateForKey(state: value, key: key, isInitial: false);
        this.value = newState;
      },
    );
  }
}

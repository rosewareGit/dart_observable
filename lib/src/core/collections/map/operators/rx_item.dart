import '../../../../../dart_observable.dart';
import '../../../rx/_impl.dart';

class OperatorObservableMapRxItem<K, V> extends RxnImpl<V?> {
  final K key;
  final ObservableMap<K, V> source;

  Disposable? _listener;

  OperatorObservableMapRxItem({
    required this.source,
    required this.key,
  }) : super(
          value: source[key],
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

    // Update initial value
    value = source[key];

    _listener = source.listen(
      onChange: (final ObservableMap<K, V> source) {
        if (state == ObservableState.inactive) {
          return;
        }

        final ObservableMapState<K, V> value = source.value;
        final ObservableMapChange<K, V> change = value.lastChange;

        if (change.removed.containsKey(key)) {
          this.value = null;
        } else if (change.added.containsKey(key)) {
          this.value = change.added[key];
        } else if (change.updated.containsKey(key)) {
          this.value = change.updated[key]?.newValue;
        }
      },
    );
  }
}

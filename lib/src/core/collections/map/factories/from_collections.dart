import '../../../../../dart_observable.dart';
import '../result.dart';

class ObservableMapFromCollections<K, V, F> extends RxMapResultImpl<K, V, F> {
  final Iterable<ObservableMapResultUpdater<K, V, F, dynamic>> observables;
  final FactoryMap<K, V>? factory;

  ObservableMapFromCollections({
    required this.observables,
    this.factory,
  }) : super(factory: factory);

  final List<Disposable> _listeners = <Disposable>[];

  @override
  void onActive() {
    super.onActive();
    _startCollect();
  }

  @override
  void onInit() {
    super.onInit();
    int disposeCount = 0;
    for (final ObservableMapResultUpdater<K, V, F, dynamic> updater in observables) {
      updater.source.addDisposeWorker(() {
        disposeCount++;
        if (disposeCount == observables.length) {
          dispose();
        }
      });
    }
  }

  @override
  Future<void> onInactive() async {
    await super.onInactive();
    for (final Disposable listener in _listeners) {
      await listener.dispose();
    }
    _listeners.clear();
  }

  void _startCollect() {
    if (_listeners.isNotEmpty) {
      return;
    }

    for (final ObservableMapResultUpdater<K, V, F, dynamic> updater in observables) {
      updater.emitInitialChange((final ObservableMapResultUpdateAction<K, V, F> value) {
        applyAction(value);
      });
      _listeners.add(
        updater.listen(
          (final ObservableMapResultUpdateAction<K, V, F> action) {
            applyAction(action);
          },
        ),
      );
    }
  }
}

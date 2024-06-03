import '../../../../../dart_observable.dart';
import '../result.dart';

class ObservableSetFromCollections<E, F> extends RxSetResultImpl<E, F> {
  final Iterable<ObservableSetResultUpdater<E, F, dynamic>> observables;
  final FactorySet<E>? factory;
  final List<Disposable> _listeners = <Disposable>[];

  ObservableSetFromCollections({
    required this.observables,
    this.factory,
  }) : super(factory: factory);

  @override
  void onActive() {
    super.onActive();
    _startCollect();
  }

  @override
  Future<void> onInactive() async {
    await super.onInactive();
    for (final Disposable listener in _listeners) {
      await listener.dispose();
    }
    _listeners.clear();
  }

  @override
  void onInit() {
    super.onInit();
    int disposeCount = 0;
    for (final ObservableSetResultUpdater<E, F, dynamic> updater in observables) {
      updater.source.addDisposeWorker(() {
        disposeCount++;
        if (disposeCount == observables.length) {
          dispose();
        }
      });
    }
  }

  void _startCollect() {
    if (_listeners.isNotEmpty) {
      return;
    }

    for (final ObservableSetResultUpdater<E, F, dynamic> updater in observables) {
      updater.emitInitialChange((final ObservableSetResultUpdateAction<E, F> value) {
        applyAction(value);
      });
      _listeners.add(
        updater.listen(
          (final ObservableSetResultUpdateAction<E, F> action) {
            applyAction(action);
          },
        ),
      );
    }
  }
}

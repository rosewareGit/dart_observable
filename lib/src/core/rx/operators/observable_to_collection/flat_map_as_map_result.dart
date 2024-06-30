import 'dart:async';

import '../../../../../dart_observable.dart';
import '../../../collections/map/result.dart';

class OperatorFlatMapAaMapResult<T, K, V, F> extends RxMapResultImpl<K, V, F> {
  final ObservableMapResult<K, V, F> Function(Observable<T> source, FactoryMap<K, V>? factory) mapper;
  final Observable<T> source;

  Disposable? _intermediateListener;
  Disposable? _listener;
  ObservableMapResult<K, V, F>? _activeRxIntermediate;
  final FactoryMap<K, V>? factory;

  OperatorFlatMapAaMapResult({
    required this.source,
    required this.mapper,
    this.factory,
  }) : super.state(mapper(source, factory).value, factory: factory);

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

    final ObservableMapResult<K, V, F> rxIntermediate = mapper(source, factory);
    _activeRxIntermediate = rxIntermediate;

    final ObservableMapResultChange<K, V, F> initialChange = rxIntermediate.value.asChange();
    applyAction(initialChange.asAction);

    _intermediateListener = rxIntermediate.listen(
      onChange: (final Observable<ObservableMapResultState<K, V, F>> source) {
        final ObservableMapResultChange<K, V, F> change = source.value.lastChange;
        applyAction(change.asAction);
      },
    );

    _listener = source.listen(
      onChange: (final Observable<T> source) {
        final ObservableMapResult<K, V, F> rxIntermediate = mapper(source, factory);
        if (_activeRxIntermediate != rxIntermediate) {
          value = rxIntermediate.value;
          _intermediateListener?.dispose();
          _intermediateListener = rxIntermediate.listen(
            onChange: (final Observable<ObservableMapResultState<K, V, F>> source) {
              final ObservableMapResultChange<K, V, F> change = source.value.lastChange;
              applyAction(change.asAction);
            },
          );
          _activeRxIntermediate = rxIntermediate;
        }
      },
    );
  }
}

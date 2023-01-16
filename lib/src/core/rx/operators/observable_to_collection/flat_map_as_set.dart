import 'dart:async';

import '../../../../../dart_observable.dart';
import '../../../collections/set/set.dart';

class OperatorFlatMapAsSet<T, T2> extends RxSetImpl<T2> {
  final ObservableSet<T2> Function(Observable<T> source) mapper;
  final Observable<T> source;

  Disposable? _intermediateListener;
  Disposable? _listener;
  ObservableSet<T2>? _activeRxIntermediate;

  OperatorFlatMapAsSet({
    required this.source,
    required this.mapper,
    final Set<T2> Function(Iterable<T2>? items)? factory,
  }) : super(
          initial: mapper(source).value.setView,
          factory: factory,
        );

  @override
  void onInit() {
    super.onInit();
    source.addDisposeWorker(() => dispose());
  }

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

  void _initListener() {
    if (_listener != null) {
      return;
    }

    final ObservableSet<T2> rxIntermediate = mapper(source);
    _activeRxIntermediate = rxIntermediate;

    final ObservableSetChange<T2> initialChange = rxIntermediate.value.asChange();
    applyAction(
      ObservableSetUpdateAction<T2>(
        removeItems: initialChange.removed,
        addItems: initialChange.added,
      ),
    );

    _intermediateListener = rxIntermediate.listen(
      onChange: (final Observable<ObservableSetState<T2>> source) {
        final ObservableSetChange<T2> change = source.value.lastChange;
        applyAction(
          ObservableSetUpdateAction<T2>(
            removeItems: change.removed,
            addItems: change.added,
          ),
        );
      },
    );

    _listener = source.listen(
      onChange: (final Observable<T> source) {
        final ObservableSet<T2> rxIntermediate = mapper(source);
        if (_activeRxIntermediate != rxIntermediate) {
          value = rxIntermediate.value;
          _intermediateListener?.dispose();
          _intermediateListener = rxIntermediate.listen(
            onChange: (final Observable<ObservableSetState<T2>> source) {
              final ObservableSetChange<T2> change = source.value.lastChange;
              applyAction(
                ObservableSetUpdateAction<T2>(
                  removeItems: change.removed,
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

  Future<void> _cancelListener() async {
    _listener?.dispose();
    _intermediateListener?.dispose();
    _listener = null;
    _intermediateListener = null;
    _activeRxIntermediate = null;
  }
}

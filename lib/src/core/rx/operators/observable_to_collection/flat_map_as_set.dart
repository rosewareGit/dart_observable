import 'dart:async';

import '../../../../../dart_observable.dart';
import '../../../../api/change_tracking_observable.dart';
import '../../../collections/set/set.dart';

class OperatorFlatMapAsSet<Self extends ChangeTrackingObservable<Self, T, C>, T, C, T2> extends RxSetImpl<T2> {
  final ObservableSet<T2> Function(Self source) mapper;
  final Self source;

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
      onChange: (final source) {
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
      onChange: (final Self source) {
        final ObservableSet<T2> rxIntermediate = mapper(source);
        if (_activeRxIntermediate != rxIntermediate) {
          value = rxIntermediate.value;
          _intermediateListener?.dispose();
          _intermediateListener = rxIntermediate.listen(
            onChange: (final ObservableSet<T2> source) {
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
}

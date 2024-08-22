import 'dart:async';

import '../../../../../dart_observable.dart';
import '../../../../api/change_tracking_observable.dart';
import '../../_impl.dart';

class OperatorFlatMap<Self extends ChangeTrackingObservable<Self, T, C>, T, C, T2> extends RxImpl<T2> {
  final Observable<T2> Function(Self source) mapper;
  final Self source;

  Disposable? _intermediateListener;
  Disposable? _listener;
  Observable<T2>? _activeRxIntermediate;

  OperatorFlatMap({
    required this.source,
    required this.mapper,
  }) : super(mapper(source).value);

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
    final Observable<T2> rxIntermediate = mapper(source);
    _activeRxIntermediate = rxIntermediate;

    _intermediateListener = rxIntermediate.listen(
      onChange: (final Observable<T2> source) {
        value = source.value;
      },
    );
    _listener = source.listen(
      onChange: (final Self source) {
        final Observable<T2> rxIntermediate = mapper(source);
        if (_activeRxIntermediate != rxIntermediate) {
          value = rxIntermediate.value;
          _intermediateListener?.dispose();
          _intermediateListener = rxIntermediate.listen(
            onChange: (final Observable<T2> source) {
              value = source.value;
            },
          );
          _activeRxIntermediate = rxIntermediate;
        }
      },
    );
  }
}

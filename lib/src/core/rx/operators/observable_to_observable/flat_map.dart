import 'dart:async';

import '../../../../../dart_observable.dart';
import '../../_impl.dart';

class OperatorFlatMap<T, T2> extends RxImpl<T2> {
  final Observable<T2> Function(T value) mapper;
  final Observable<T> source;

  Disposable? _intermediateListener;
  Disposable? _listener;
  Observable<T2>? _activeRxIntermediate;

  OperatorFlatMap({
    required this.source,
    required this.mapper,
  }) : super(mapper(source.value).value);

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
    final Observable<T2> rxIntermediate = mapper(source.value);
    _activeRxIntermediate = rxIntermediate;

    _intermediateListener = rxIntermediate.listen(
      onChange: (final T2 value) {
        this.value = value;
      },
    );
    _listener = source.listen(
      onChange: (final T value) {
        final Observable<T2> rxIntermediate = mapper(value);
        if (_activeRxIntermediate != rxIntermediate) {
          this.value = rxIntermediate.value;
          _intermediateListener?.dispose();
          _intermediateListener = rxIntermediate.listen(
            onChange: (final T2 value) {
              this.value = value;
            },
          );
          _activeRxIntermediate = rxIntermediate;
        }
      },
    );
  }
}

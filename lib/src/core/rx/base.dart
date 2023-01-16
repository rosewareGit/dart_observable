import 'dart:async';

import 'package:meta/meta.dart';

import '../../../dart_observable.dart';
import 'factories/combine_latest_2.dart';
import 'factories/combine_latest_3.dart';
import 'factories/combine_latest_4.dart';
import 'factories/combine_latest_5.dart';
import 'operators/handle_error.dart';
import 'operators/next.dart';
import 'operators/observable_to_collection/flat_map_as_map.dart';
import 'operators/observable_to_collection/flat_map_as_map_result.dart';
import 'operators/observable_to_collection/flat_map_as_set.dart';
import 'operators/observable_to_collection/flat_map_as_set_result.dart';
import 'operators/observable_to_observable.dart';

abstract class RxBase<T>
    with
        OperatorsObservableToObservable<T>, //
// OperatorsObservableToCollections<T>,
        OperatorNext<T>,
        OperatorHandleError<T>
    implements
        Rx<T> {
  @override
  late final String debugName;

  final bool _distinct;

  final List<FutureWorker> _workOnDispose = <FutureWorker>[];

  late T _value;

  T? _previous;

  bool _disposed = false;

  final Set<ObservableListener<T>> _listeners = <ObservableListener<T>>{};
  final Set<ObservableListener<T>> _activeListeners = <ObservableListener<T>>{};
  final Set<ObservableListener<T>> _inactiveListeners = <ObservableListener<T>>{};
  bool _hadListeners = false;

  RxBase({
    required final T value,
    final bool distinct = true,
  }) : _distinct = distinct {
    _initDebugName();
    _value = value;
    onInit();
  }

  @override
  bool get disposed => _disposed;

  @override
  bool get distinct => _distinct;

  int get listenerCount => _listeners.length;

  @override
  T? get previous => _previous;

  @override
  ObservableState get state {
    if (disposed) {
      return ObservableState.disposed;
    }

    if (_listeners.isEmpty) {
      return ObservableState.inactive;
    }

    return ObservableState.active;
  }

  @override
  T get value {
    return _value;
  }

  @override
  set value(final T value) {
    if (disposed) {
      throw ObservableDisposedError();
    }

    if (_distinct && _value == value) {
      return;
    }

    _previous = _value;
    _value = value;
    notify();
  }

  @override
  void addDisposeWorker(final FutureWorker worker) {
    _workOnDispose.add(worker);
  }

  @override
  Observable<R> combineWith<R, T2>({
    required final Observable<T2> other,
    required final R Function(T value, T2 value2) combiner,
  }) {
    return ObservableCombineWith2<R, T, T2>(
      observable1: this,
      observable2: other,
      combiner: combiner,
      distinct: distinct,
    );
  }

  @override
  Observable<R> combineWith2<R, T2, T3>({
    required final Observable<T2> other,
    required final Observable<T3> other2,
    required final R Function(T value, T2 value2, T3 value3) combiner,
  }) {
    return ObservableCombineWith3<R, T, T2, T3>(
      observable1: this,
      observable2: other,
      observable3: other2,
      combiner: combiner,
      distinct: distinct,
    );
  }

  @override
  Observable<R> combineWith3<R, T2, T3, T4>({
    required final Observable<T2> other,
    required final Observable<T3> other2,
    required final Observable<T4> other3,
    required final R Function(T value, T2 value2, T3 value3, T4 value4) combiner,
  }) {
    return ObservableCombineWith4<R, T, T2, T3, T4>(
      observable1: this,
      observable2: other,
      observable3: other2,
      observable4: other3,
      combiner: combiner,
      distinct: distinct,
    );
  }

  @override
  Observable<R> combineWith4<R, T2, T3, T4, T5>({
    required final Observable<T2> other,
    required final Observable<T3> other2,
    required final Observable<T4> other3,
    required final Observable<T5> other4,
    required final R Function(T value, T2 value2, T3 value3, T4 value4, T5 value5) combiner,
  }) {
    return ObservableCombineWith5<R, T, T2, T3, T4, T5>(
      observable1: this,
      observable2: other,
      observable3: other2,
      observable4: other3,
      observable5: other4,
      combiner: combiner,
      distinct: distinct,
    );
  }

  @override
  void dispatchError({
    required final dynamic error,
    final StackTrace? stack,
  }) {
    for (final ObservableListener<T> listener in _listeners) {
      listener.notifyError(error, stack ?? StackTrace.current);
    }
  }

  @override
  Future<void> dispose() async {
    if (disposed) {
      return;
    }

    _disposed = true;

    final List<Disposable> listeners = <Disposable>[
      ..._listeners,
      ..._activeListeners,
      ..._inactiveListeners,
    ];

    final List<FutureWorker> workers = <FutureWorker>[..._workOnDispose];
    for (final FutureWorker worker in workers) {
      await worker();
    }

    for (final Disposable listener in listeners) {
      await listener.dispose();
    }

    _workOnDispose.clear();
    _listeners.clear();
    _activeListeners.clear();
    _inactiveListeners.clear();

    DartObservableGlobalMetrics().emitDispose(this);
  }

  @override
  ObservableMap<K, V> flatMapAsMap<K, V>(
    final ObservableMap<K, V> Function(Observable<T> source) mapper,
  ) {
    return OperatorFlatMapAsMap<T, K, V>(
      source: this,
      mapper: mapper,
    );
  }

  @override
  ObservableMapResult<K, V, F> flatMapAsMapResult<K, V, F>(
    final ObservableMapResult<K, V, F> Function(Observable<T> source) mapper,
  ) {
    return OperatorFlatMapAaMapResult<T, K, V, F>(
      source: this,
      mapper: mapper,
    );
  }

  @override
  ObservableSet<T2> flatMapAsSet<T2>(
    final ObservableSet<T2> Function(Observable<T> source) mapper, {
    final Set<T2> Function(Iterable<T2>? items)? factory,
  }) {
    return OperatorFlatMapAsSet<T, T2>(
      source: this,
      mapper: mapper,
      factory: factory,
    );
  }

  @override
  ObservableSetResult<T2, F> flatMapAsSetResult<T2, F>({
    required final ObservableSetResult<T2, F> Function(
      Observable<T> source,
      FactorySet<T2>? factory,
    ) mapper,
    final FactorySet<T2>? factory,
  }) {
    return OperatorFlatMapAsSetResult<T, T2, F>(
      source: this,
      mapper: mapper,
      factory: factory,
    );
  }

  @override
  Disposable listen({
    final Function(Observable<T> source)? onChange,
    final Function(dynamic error, StackTrace stack)? onError,
  }) {
    if (disposed) {
      throw ObservableDisposedError();
    }

    final ObservableListener<T> listener = _createSubscription(
      onChange: onChange,
      onError: onError,
    );
    final bool hadListeners = _listeners.isNotEmpty;
    _subscriptionAdd(listener);

    if(hadListeners == false) {
      _dispatchActive();
    }

    _hadListeners = true;
    if (hadListeners == false) {
      DartObservableGlobalMetrics().emitActive(this);
    }
    return listener;
  }

  void notify() {
    final List<ObservableListener<T>> listeners = <ObservableListener<T>>[..._listeners];
    for (final ObservableListener<T> listener in listeners) {
      listener.notify(this);
    }
    DartObservableGlobalMetrics().emitNotify(this);
  }

  @mustCallSuper
  void onActive() {
    final List<ObservableListener<T>> listeners = <ObservableListener<T>>[..._activeListeners];
    for (final ObservableListener<T> listener in listeners) {
      listener.notify(this);
    }
  }

  @override
  Disposable onActivityChanged({
    final void Function(Observable<T> source)? onActive,
    final void Function(Observable<T> source)? onInactive,
  }) {
    final Disposable activeListener = _addOnActiveListener(onActive);
    final Disposable inActiveListener = _addOnInactiveListener(onInactive);
    return ObservableListener<T>(
      disposer: (final Disposable listener) async {
        await activeListener.dispose();
        await inActiveListener.dispose();
      },
    );
  }

  @mustCallSuper
  Future<void> onInactive() async {}

  void onInit() {}

  Disposable _addOnActiveListener(
    final void Function(Observable<T> source)? onActive,
  ) {
    final ObservableListener<T> listener = ObservableListener<T>(
      disposer: (final Disposable listener) {
        _activeListeners.remove(listener);
      },
      onChange: (final Observable<T> source) {
        onActive?.call(source);
      },
    );
    if (_listeners.isNotEmpty) {
      onActive?.call(this);
    }
    _activeListeners.add(listener);
    return listener;
  }

  Disposable _addOnInactiveListener(
    final void Function(Observable<T> source)? onInactive,
  ) {
    final ObservableListener<T> listener = ObservableListener<T>(
      disposer: (final Disposable listener) {
        _inactiveListeners.remove(listener);
      },
      onChange: (final Observable<T> source) {
        onInactive?.call(source);
      },
    );

    if (_hadListeners && _listeners.isEmpty) {
      onInactive?.call(this);
    }

    _inactiveListeners.add(listener);
    return listener;
  }

  ObservableListener<T> _createSubscription({
    required final Function(Observable<T> source)? onChange,
    final Function(dynamic error, StackTrace stack)? onError,
  }) {
    return ObservableListener<T>(
      disposer: (final ObservableListener<T> listener) {
        return _listenerRemove(listener);
      },
      onChange: onChange,
      onError: onError,
    );
  }

  void _dispatchActive() {
    onActive();
  }

  void _initDebugName() {
    final StackTrace stack = StackTrace.current;
    final List<String> lines = stack.toString().split('\n');
    String? caller;
    if (lines.isEmpty) {
      caller = '';
    } else {
      for (final String line in lines) {
        if (line.contains('package:dart_observable') == false) {
          caller = line;
          break;
        }
        if (line.contains('global_metrics.dart')) {
          caller = line;
          break;
        }
      }
      if (caller == null) {
        if (lines.length > 2) {
          caller = lines[1];
        } else {
          caller = lines[0];
        }
      }
    }
    debugName = caller;
  }

  FutureOr<void> _listenerRemove(final ObservableListener<T> listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty) {
      final List<ObservableListener<T>> listeners = <ObservableListener<T>>[..._inactiveListeners];
      for (final ObservableListener<T> listener in listeners) {
        listener.notify(this);
      }
      DartObservableGlobalMetrics().emitInactive(this);
      return onInactive();
    }
  }

  void _subscriptionAdd(final ObservableListener<T> listener) {
    _listeners.add(listener);
  }
}

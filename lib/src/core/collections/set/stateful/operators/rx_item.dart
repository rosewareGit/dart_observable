import '../../../../../../dart_observable.dart';
import '../../../../../utils/extensions/iterable.dart';
import '../../../../rx/_impl.dart';

Either<E?, S>? _getStateByPredicate<E, S>({
  required final ObservableStatefulSetState<E, S> state,
  required final bool Function(E item) predicate,
  required final bool isInitial,
}) {
  return state.fold(
    onData: (final ObservableSetState<E> set) {
      final ObservableSetChange<E> change = isInitial ? set.asChange() : set.lastChange;
      final Set<E> added = change.added;
      final Set<E> removed = change.removed;
      bool itemRemoved = false;
      if (removed.isNotEmpty) {
        final E? matched = removed.firstWhereOrNull((final E element) => predicate(element));
        if (matched != null) {
          itemRemoved = true;
        }
      }

      if (added.isNotEmpty) {
        final E? matched = added.firstWhereOrNull((final E element) => predicate(element));
        if (matched != null) {
          return Either<E?, S>.left(matched);
        }
      }

      if (itemRemoved) {
        return Either<E?, S>.left(null);
      }
      return null;
    },
    onCustom: (final S state) {
      return Either<E?, S>.right(state);
    },
  );
}

class OperatorObservableSetStatefulRxItem<E, S> extends RxImpl<Either<E?, S>> {
  final bool Function(E item) predicate;
  final ObservableStatefulSet<E, S> source;

  Disposable? _listener;

  OperatorObservableSetStatefulRxItem({
    required this.source,
    required this.predicate,
  }) : super(
          _getStateByPredicate(state: source.value, predicate: predicate, isInitial: true) ?? Either<E?, S>.left(null),
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

    final Either<E?, S>? newState = _getStateByPredicate(state: source.value, predicate: predicate, isInitial: true);
    if (newState != null) {
      value = newState;
    }

    _listener = source.listen(
      onChange: (final ObservableStatefulSetState<E, S> value) {
        final Either<E?, S>? newState = _getStateByPredicate(state: value, predicate: predicate, isInitial: false);
        if (newState != null) {
          this.value = newState;
        }
      },
    );
  }
}

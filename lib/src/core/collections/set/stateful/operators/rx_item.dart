import '../../../../../../dart_observable.dart';
import '../../../../../utils/extensions/iterable.dart';
import '../../../../rx/_impl.dart';

StateOf<E?, S>? _getStateByPredicate<E, S>({
  required final ObservableSetStatefulState<E, S> state,
  required final bool Function(E item) predicate,
  required final bool isInitial,
}) {
  return state.fold(
    onData: (final ObservableSetState<E> set) {
      final ObservableSetChange<E> change = isInitial ? set.asChange() : set.lastChange;
      final Set<E> added = change.added;
      final Set<E> removed = change.removed;
      if (removed.isNotEmpty) {
        final E? matched = removed.firstWhereOrNull((final E element) => predicate(element));
        if (matched != null) {
          return StateOf<E?, S>.data(null);
        }
      }

      if (added.isNotEmpty) {
        final E? matched = added.firstWhereOrNull((final E element) => predicate(element));
        if (matched != null) {
          return StateOf<E?, S>.data(matched);
        }
      }

      return null;
    },
    onCustom: (final S state) {
      return StateOf<E?, S>.custom(state);
    },
  );
}

class OperatorObservableSetStatefulRxItem<Self extends ObservableSetStateful<Self, E, S>, E, S>
    extends RxImpl<StateOf<E?, S>> {
  final bool Function(E item) predicate;
  final Self source;

  Disposable? _listener;

  OperatorObservableSetStatefulRxItem({
    required this.source,
    required this.predicate,
  }) : super(
          _getStateByPredicate(state: source.value, predicate: predicate, isInitial: true) ?? StateOf<E?, S>.data(null),
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

    final StateOf<E?, S>? newState = _getStateByPredicate(state: source.value, predicate: predicate, isInitial: true);
    if (newState != null) {
      value = newState;
    }

    _listener = source.listen(
      onChange: (final Self source) {
        final ObservableSetStatefulState<E, S> state = source.value;
        final StateOf<E?, S>? newState = _getStateByPredicate(state: state, predicate: predicate, isInitial: false);
        if (newState != null) {
          value = newState;
        }
      },
    );
  }
}

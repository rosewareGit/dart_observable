import '../../../../../../dart_observable.dart';
import '../rx_impl.dart';

class ObservableSetMerged<E> extends RxSetImpl<E> {
  final Iterable<ObservableSet<E>> collections;
  late final List<Disposable> _subscriptions = <Disposable>[];

  late final Map<ObservableSet<E>, List<ObservableSetChange<E>>> _bufferedChanges =
      <ObservableSet<E>, List<ObservableSetChange<E>>>{};

  ObservableSetMerged({
    required this.collections,
    required super.factory,
  });

  @override
  void onActive() {
    super.onActive();
    _startCollect();
  }

  @override
  void onInit() {
    addDisposeWorker(() async {
      for (final Disposable e in _subscriptions) {
        await e.dispose();
      }
      await dispose();
    });
    for (final ObservableSet<E> collection in collections) {
      collection.addDisposeWorker(() async {
        final bool allDisposed = collections.every((final ObservableSet<E> element) => element.disposed);
        if (allDisposed) {
          await dispose();
        }
      });
    }
    super.onInit();
  }

  void _startCollect() {
    if (_subscriptions.isNotEmpty) {
      // apply buffered actions
      for (final MapEntry<ObservableSet<E>, List<ObservableSetChange<E>>> entry in _bufferedChanges.entries) {
        final ObservableSet<E> collection = entry.key;
        final List<ObservableSetChange<E>> changes = entry.value;

        for (final ObservableSetChange<E> change in changes) {
          _handleChange(collection: collection, change: change);
        }
      }
      _bufferedChanges.clear();
      return;
    }

    for (final ObservableSet<E> collection in collections) {
      _handleChange(collection: collection, change: collection.currentStateAsChange);

      _subscriptions.add(
        collection.onChange(
          onChange: (final ObservableSetChange<E> change) {
            if (state == ObservableState.inactive) {
              _bufferedChanges.putIfAbsent(collection, () {
                return <ObservableSetChange<E>>[];
              }).add(change);
              return;
            }

            _handleChange(collection: collection, change: change);
          },
        ),
      );
    }
  }

  static handleChange<E>({
    required final ObservableSetChange<E> change,
    required final bool Function(E item) hasItemInOtherCollections,
    required final void Function(ObservableSetUpdateAction<E> action) applyAction,
  }) {
    final Set<E> added = change.added;
    final Set<E> removed = change.removed;
    final Set<E> removeItems = <E>{};

    if (removed.isNotEmpty) {
      for (final E item in removed) {
        final bool anyOtherCollectionContainsItem = hasItemInOtherCollections(item);
        if (!anyOtherCollectionContainsItem) {
          removeItems.add(item);
        }
      }
    }

    applyAction(
      ObservableSetUpdateAction<E>(
        removeItems: removeItems,
        addItems: added,
      ),
    );
  }

  void _handleChange({
    required final ObservableSet<E> collection,
    required final ObservableSetChange<E> change,
  }) {
    handleChange(
      change: change,
      hasItemInOtherCollections: (final E item) {
        return collections
            .where((final ObservableSet<E> element) => element != collection)
            .any((final ObservableSet<E> element) => element.contains(item));
      },
      applyAction: applyAction,
    );
  }
}

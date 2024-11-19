import '../../../../../../dart_observable.dart';
import '../list_sync_helper.dart';
import '../rx_impl.dart';

class ObservableListMerged<E> extends RxListImpl<E> {
  final Iterable<ObservableList<E>> collections;
  late final Map<ObservableList<E>, ObservableListSyncHelper<E>> _syncHelpers =
      <ObservableList<E>, ObservableListSyncHelper<E>>{};

  late final List<Disposable> _subscriptions = <Disposable>[];

  late final Map<ObservableList<E>, List<ObservableListChange<E>>> _bufferedChanges =
      <ObservableList<E>, List<ObservableListChange<E>>>{};

  ObservableListMerged({
    required this.collections,
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
    for (final ObservableList<E> collection in collections) {
      _syncHelpers[collection] = ObservableListSyncHelper<E>(actionHandler: this);

      collection.addDisposeWorker(() async {
        final bool allDisposed = collections.every((final ObservableList<E> element) => element.disposed);
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
      for (final MapEntry<ObservableList<E>, List<ObservableListChange<E>>> entry in _bufferedChanges.entries) {
        final ObservableList<E> collection = entry.key;
        final List<ObservableListChange<E>> changes = entry.value;

        for (final ObservableListChange<E> change in changes) {
          _syncHelpers[collection]!.handleListSync(sourceChange: change);
        }
      }
      _bufferedChanges.clear();
      return;
    }

    for (final ObservableList<E> collection in collections) {
      _syncHelpers[collection]!.handleListSync(sourceChange: collection.currentStateAsChange);

      _subscriptions.add(
        collection.onChange(
          onChange: (final ObservableListChange<E> change) {
            if (state == ObservableState.inactive) {
              _bufferedChanges.putIfAbsent(collection, () {
                return <ObservableListChange<E>>[];
              }).add(change);
              return;
            }

            _syncHelpers[collection]!.handleListSync(sourceChange: change);
          },
        ),
      );
    }
  }
}

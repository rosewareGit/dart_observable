import '../../../../../../dart_observable.dart';
import '../../change_elements.dart';
import '../../list_element.dart';
import '../../list_state.dart';
import '../../list_sync_helper.dart';
import '../rx_stateful.dart';

class ObservableStatefulListMerged<E, S> extends RxStatefulListImpl<E, S> {
  final Iterable<ObservableStatefulList<E, S>> collections;
  final Either<List<E>, S>? Function(S state)? stateResolver;

  late final Map<ObservableStatefulList<E, S>, ObservableListSyncHelper<E>> _syncHelpers =
      <ObservableStatefulList<E, S>, ObservableListSyncHelper<E>>{};

  late final List<Disposable> _subscriptions = <Disposable>[];

  late final Map<ObservableStatefulList<E, S>, List<Either<ObservableListChange<E>, S>>> _bufferedChanges =
      <ObservableStatefulList<E, S>, List<Either<ObservableListChange<E>, S>>>{};

  ObservableStatefulListMerged({
    required this.collections,
    required this.stateResolver,
  }) : super(<E>[]);

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
    for (final ObservableStatefulList<E, S> collection in collections) {
      _syncHelpers[collection] = ObservableListSyncHelper<E>(actionHandler: this);
      collection.addDisposeWorker(() async {
        final bool allDisposed = collections.every((final ObservableStatefulList<E, S> element) => element.disposed);
        if (allDisposed) {
          await dispose();
        }
      });
    }

    super.onInit();
  }

  void _handleChange(
    final ObservableStatefulList<E, S> collection,
    final Either<ObservableListChange<E>, S> change,
  ) {
    change.fold(
      onLeft: (final ObservableListChange<E> data) {
        _syncHelpers[collection]!.handleListSync(sourceChange: data);
      },
      onRight: (final S custom) {
        final Either<List<E>, S>? state = stateResolver?.call(custom);
        if (state != null) {
          state.fold(
            onLeft: (final List<E> data) {
              setData(data);
            },
            onRight: (final S custom) {
              setState(custom);
            },
          );
        } else {
          final ObservableStatefulListState<E, S>? previous = collection.previous;
          // remove items from collection
          if (previous != null) {
            previous.when(
              onData: (final ObservableListState<E> data) {
                final RxListState<E> parsed = data as RxListState<E>;
                final List<ObservableListElement<E>> items = parsed.data;
                final Map<int, ObservableListElementChange<E>> removed = <int, ObservableListElementChange<E>>{};
                for (int i = 0; i < items.length; i++) {
                  removed[i] = ObservableListElementChange<E>(
                    element: items[i],
                    oldValue: items[i].value,
                    newValue: items[i].value,
                  );
                }

                _syncHelpers[collection]!.handleListSync(
                  sourceChange: ObservableListChangeElements<E>(
                    removed: removed,
                  ),
                );
              },
            );
          }
        }
      },
    );
  }

  void _startCollect() {
    if (_subscriptions.isNotEmpty) {
      // apply buffered actions
      for (final MapEntry<ObservableStatefulList<E, S>, List<Either<ObservableListChange<E>, S>>> entry
          in _bufferedChanges.entries) {
        final ObservableStatefulList<E, S> collection = entry.key;
        final List<Either<ObservableListChange<E>, S>> changes = entry.value;

        for (final Either<ObservableListChange<E>, S> change in changes) {
          _handleChange(collection, change);
        }
      }
      _bufferedChanges.clear();
      return;
    }

    for (final ObservableStatefulList<E, S> collection in collections) {
      final Either<ObservableListChange<E>, S> currentStateAsChange = collection.currentStateAsChange;
      currentStateAsChange.fold(
        onLeft: (final ObservableListChange<E> data) {
          _syncHelpers[collection]!.handleListSync(sourceChange: data);
        },
        onRight: (final S custom) {},
      );

      _subscriptions.add(
        collection.onChange(
          onChange: (final Either<ObservableListChange<E>, S> change) {
            if (state == ObservableState.inactive) {
              _bufferedChanges.putIfAbsent(collection, () {
                return <Either<ObservableListChange<E>, S>>[];
              }).add(change);
              return;
            }

            _handleChange(collection, change);
          },
        ),
      );
    }
  }
}

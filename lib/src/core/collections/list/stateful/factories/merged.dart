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

  late final Map<ObservableStatefulList<E, S>, List<StatefulListChange<E, S>>> _bufferedChanges =
      <ObservableStatefulList<E, S>, List<StatefulListChange<E, S>>>{};

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
    final StatefulListChange<E, S> change,
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
          final Either<RxListState<E>, S>? previous = (collection as RxStatefulListImpl<E, S>).previousState;
          // remove items from collection
          if (previous != null) {
            previous.when(
              onLeft: (final RxListState<E> state) {
                final List<ObservableListElement<E>> items = state.data;
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
      for (final MapEntry<ObservableStatefulList<E, S>, List<StatefulListChange<E, S>>> entry
          in _bufferedChanges.entries) {
        final ObservableStatefulList<E, S> collection = entry.key;
        final List<StatefulListChange<E, S>> changes = entry.value;

        for (final StatefulListChange<E, S> change in changes) {
          _handleChange(collection, change);
        }
      }
      _bufferedChanges.clear();
      return;
    }

    for (final ObservableStatefulList<E, S> collection in collections) {
      final StatefulListChange<E, S> currentStateAsChange = collection.currentStateAsChange;
      currentStateAsChange.fold(
        onLeft: (final ObservableListChange<E> data) {
          _syncHelpers[collection]!.handleListSync(sourceChange: data);
        },
        onRight: (final S custom) {},
      );

      _subscriptions.add(
        collection.onChange(
          onChange: (final StatefulListChange<E, S> change) {
            if (state == ObservableState.inactive) {
              _bufferedChanges.putIfAbsent(collection, () {
                return <StatefulListChange<E, S>>[];
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

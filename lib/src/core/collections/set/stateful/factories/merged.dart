import '../../../../../../dart_observable.dart';
import '../../factories/merged.dart';
import '../rx_stateful.dart';

class ObservableStatefulSetMerged<E, S> extends RxStatefulSetImpl<E, S> {
  final Iterable<ObservableStatefulSet<E, S>> collections;
  final Either<Set<E>, S>? Function(S state)? stateResolver;

  late final List<Disposable> _subscriptions = <Disposable>[];

  late final Map<ObservableStatefulSet<E, S>, List<Either<ObservableSetChange<E>, S>>> _bufferedChanges =
      <ObservableStatefulSet<E, S>, List<Either<ObservableSetChange<E>, S>>>{};

  ObservableStatefulSetMerged({
    required this.collections,
    required this.stateResolver,
    required super.factory,
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
    for (final ObservableStatefulSet<E, S> collection in collections) {
      collection.addDisposeWorker(() async {
        final bool allDisposed = collections.every((final ObservableStatefulSet<E, S> element) => element.disposed);
        if (allDisposed) {
          await dispose();
        }
      });
    }

    super.onInit();
  }

  void _handleChange(
    final ObservableStatefulSet<E, S> collection,
    final Either<ObservableSetChange<E>, S> change,
  ) {
    change.fold(
      onLeft: (final ObservableSetChange<E> data) {
        ObservableSetMerged.handleChange(
          change: data,
          hasItemInOtherCollections: (final E item) {
            return collections
                .where((final ObservableStatefulSet<E, S> element) => element != collection)
                .any((final ObservableStatefulSet<E, S> element) => element.contains(item));
          },
          applyAction: applySetUpdateAction,
        );
      },
      onRight: (final S custom) {
        if (stateResolver != null) {
          final Either<Set<E>, S>? state = stateResolver?.call(custom);
          if (state != null) {
            state.fold(
              onLeft: (final Set<E> newState) {
                setData(newState);
              },
              onRight: (final S newState) {
                setState(newState);
              },
            );
          }
        } else {
          final Either<Set<E>, S>? previous = collection.previous;
          // remove items from collection
          if (previous != null) {
            previous.when(
              onLeft: (final Set<E> data) {
                _handleChange(
                  collection,
                  Either<ObservableSetChange<E>, S>.left(
                    ObservableSetChange<E>(removed: data),
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
      for (final MapEntry<ObservableStatefulSet<E, S>, List<Either<ObservableSetChange<E>, S>>> entry
          in _bufferedChanges.entries) {
        final ObservableStatefulSet<E, S> collection = entry.key;
        final List<Either<ObservableSetChange<E>, S>> changes = entry.value;

        for (final Either<ObservableSetChange<E>, S> change in changes) {
          _handleChange(collection, change);
        }
      }
      _bufferedChanges.clear();
      return;
    }

    for (final ObservableStatefulSet<E, S> collection in collections) {
      final Either<ObservableSetChange<E>, S> currentStateAsChange = collection.currentStateAsChange;
      _handleChange(collection, currentStateAsChange);

      _subscriptions.add(
        collection.onChange(
          onChange: (final Either<ObservableSetChange<E>, S> change) {
            if (state == ObservableState.inactive) {
              _bufferedChanges.putIfAbsent(collection, () {
                return <Either<ObservableSetChange<E>, S>>[];
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

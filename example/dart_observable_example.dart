import 'package:dart_observable/dart_observable.dart';

Future<void> main() async {
  final Controller controller = Controller();

  final Disposable counterListener = controller.rxCounter.listen(
    onChange: (final int value) {
      print('Counter changed to $value');
    },
  );

  controller.increment();
  final int rxCounter = controller.rxCounter.value;
  assert(rxCounter == 1);

  final Disposable listListener = controller.rxItems.listen(
    onChange: (final List<String> immutableList) {
      final ObservableListChange<String> change = controller.rxItems.change;

      print('list size: ${immutableList.length}');
      final Map<int, String> added = change.added;
      final Map<int, String> removed = change.removed;
      final Map<int, ObservableItemChange<String>> updated = change.updated;

      if (added.isNotEmpty) {
        for (final MapEntry<int, String> entry in added.entries) {
          print('added to position: ${entry.key} ${entry.value}');
        }
      }

      if (removed.isNotEmpty) {
        for (final MapEntry<int, String> entry in removed.entries) {
          print('removed from position: ${entry.key} ${entry.value}');
        }
      }

      if (updated.isNotEmpty) {
        for (final MapEntry<int, ObservableItemChange<String>> entry in updated.entries) {
          print('updated at position: ${entry.key} from ${entry.value.oldValue} to ${entry.value.newValue}');
        }
      }
    },
  );

  /// The observable is cold, so it will not compute the initial state until it is subscribed to.
  final Disposable mapListener = controller.rxItemsUppercasedMap.listen();
  final Disposable itemListener = controller.rxItemsUppercasedByItem.listen();

  /// The initial state from the source is mapped to the target.
  assert(controller.rxItemsUppercasedMap.value.length == 3);
  assert(controller.rxItemsUppercasedByItem.length == 3);

  controller.addItem('item4');
  assert(controller.rxItemsUppercasedByItem.length == 4);
  assert(controller.rxItemsUppercasedByItem[3] == 'ITEM4');

  assert(controller.rxItemsUppercasedMap.value.length == 4);
  // [] is not implemented on Observable<List>
  assert(controller.rxItemsUppercasedMap.value[3] == 'ITEM4');

  controller.updateItem(0, 'newItem');

  assert(controller.rxItemsUppercasedMap.value.length == 4);
  assert(controller.rxItemsUppercasedByItem.length == 4);

  assert(controller.rxItemsUppercasedByItem[0] == 'NEWITEM');
  assert(controller.rxItemsUppercasedMap.value[0] == 'NEWITEM');

  controller.removeItemAt(0);

  assert(controller.rxItemsUppercasedMap.value.length == 3);
  assert(controller.rxItemsUppercasedByItem.length == 3);

  assert(controller.rxItemsUppercasedByItem[0] == 'ITEM2');
  assert(controller.rxItemsUppercasedMap.value[0] == 'ITEM2');

  await listListener.dispose();
  await counterListener.dispose();
  await mapListener.dispose();
  await itemListener.dispose();
}

class Controller {
  /// Base mutable state, can hold any type.
  final Rx<int> _rxCounter = Rx<int>(0);
  final RxList<String> _rxItems = RxList<String>(<String>['item1', 'item2', 'item3']);

  /// Immutable state of the base mutable state.
  late final Observable<int> rxCounter = _rxCounter;

  /// Working with collection is always more complex because usually the returned value is mutable and modifications usually are not reactive.
  /// For collections (list, map, set), the returned value is always immutable.
  late final ObservableList<String> rxItems = _rxItems;

  /// Collection observables are used to handle changes within a collection.
  /// These changes are utilized in collection operators to compute only the differences.
  /// The base [Observable.map] operator does not handle the changes but can map to any type.
  late final Observable<List<String>> rxItemsUppercasedMap = _rxItems.map(
    (final List<String> immutableView) {
      return immutableView.map((final String item) => item.toUpperCase()).toList();
    },
  );

  /// [ObservableList.mapItem] does utilize the changes within the collection to compute the differences.
  /// So it is more efficient than [Observable.map] for collections because it will only compute the differences.
  /// On subscribing to a collection, the initial data is included in the first change.
  late final ObservableList<String> rxItemsUppercasedByItem =
      _rxItems.mapItem((final String item) => item.toUpperCase());

  void addItem(final String item) {
    _rxItems.add(item);
  }

  void increment() {
    _rxCounter.value++;
  }

  void removeItemAt(final int position) {
    _rxItems.removeAt(position);
  }

  void updateItem(final int position, final String newItem) {
    _rxItems[position] = newItem;
  }
}

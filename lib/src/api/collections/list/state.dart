import 'dart:collection';

import '../../change_tracking_state.dart';
import 'change.dart';

abstract class ObservableListState<E> extends ChangeTrackingState<ObservableListChange<E>> {
  UnmodifiableListView<E> get listView;
}

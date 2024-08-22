import 'dart:collection';

import '../../change_tracking_state.dart';
import 'change.dart';

abstract class ObservableSetState<E> extends ChangeTrackingState<ObservableSetChange<E>> {
  UnmodifiableSetView<E> get setView;
}

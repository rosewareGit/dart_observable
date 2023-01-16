import '../../../dart_observable.dart';

class DartObservableGlobalMetrics {
  factory DartObservableGlobalMetrics() {
    return _instance;
  }

  DartObservableGlobalMetrics._();

  static final DartObservableGlobalMetrics _instance = DartObservableGlobalMetrics._();

  late final RxMap<String, List<DateTime>> _rxNotifies = RxMap<String, List<DateTime>>();
  late final RxMap<String, List<DateTime>> _rxDisposes = RxMap<String, List<DateTime>>();
  late final RxMap<String, List<DateTime>> _rxActives = RxMap<String, List<DateTime>>();
  late final RxMap<String, List<DateTime>> _rxInactives = RxMap<String, List<DateTime>>();

  final Set<String> _ignoredPaths = <String>{};

  ObservableMap<String, List<DateTime>> get rxActives => _rxActives;
  ObservableMap<String, List<DateTime>> get rxDisposes => _rxDisposes;
  ObservableMap<String, List<DateTime>> get rxInactives => _rxInactives;
  ObservableMap<String, List<DateTime>> get rxNotifies => _rxNotifies;

  void clearAll() {
    _rxNotifies.clear();
    _rxDisposes.clear();
    _rxActives.clear();
    _rxInactives.clear();
  }

  void emitActive(final Observable<dynamic> source) {
    if (shouldIgnore(source)) {
      return;
    }
    final List<DateTime> current = _rxActives[source.debugName] ?? <DateTime>[];
    _rxActives[source.debugName] = <DateTime>[...current, DateTime.now()];
  }

  void emitDispose(final Observable<dynamic> source) {
    if (shouldIgnore(source)) {
      return;
    }
    final List<DateTime> current = _rxDisposes[source.debugName] ?? <DateTime>[];
    _rxDisposes[source.debugName] = <DateTime>[...current, DateTime.now()];
  }

  void emitInactive(final Observable<dynamic> source) {
    if (shouldIgnore(source)) {
      return;
    }
    final List<DateTime> current = _rxInactives[source.debugName] ?? <DateTime>[];
    _rxInactives[source.debugName] = <DateTime>[...current, DateTime.now()];
  }

  void emitNotify(final Observable<dynamic> source) {
    if (shouldIgnore(source)) {
      return;
    }
    final List<DateTime> current = _rxNotifies[source.debugName] ?? <DateTime>[];
    _rxNotifies[source.debugName] = <DateTime>[...current, DateTime.now()];
  }

  void enableMetrics() {
    final StackTrace source = StackTrace.current;
    final String sourceText = source.toString();
    if (sourceText.contains('package:') == false) {
      return;
    }
    // without line number
    final String filePath = sourceText.split('package:')[1].split('.dart')[0];
    _ignoredPaths.remove(filePath);
  }

  void ignoreMetrics() {
    final StackTrace source = StackTrace.current;
    final String sourceText = source.toString();
    if (sourceText.contains('package:') == false) {
      return;
    }
    final List<String> lines = sourceText.split('\n');
    String? sourceLine;
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      if (line.contains('global_metrics.dart')) {
        // internal usage
        continue;
      }
      sourceLine = line;
      break;
    }
    if (sourceLine == null) {
      return;
    }
    // without line number
    final String filePath = sourceLine.split('package:')[1].split('.dart')[0];
    _ignoredPaths.add(filePath);
  }

  bool shouldIgnore(final Observable<dynamic> source) {
    final String debugName = source.debugName;
      for (final String ignoredPath in _ignoredPaths) {
        if (debugName.contains(ignoredPath)) {
          return true;
        }
      }

    return debugName.contains('package:dart_observable/src/api/log/global_metrics.dart');
  }
}

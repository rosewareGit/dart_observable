import '../../../dart_observable.dart';

class ObservableGlobalLogger {
  static bool _loggingEnabled = false;

  static final ObservableGlobalLogger _instance = ObservableGlobalLogger._();

  late final RxMap<String, List<DateTime>> _rxNotifies = RxMap<String, List<DateTime>>();
  late final RxMap<String, List<DateTime>> _rxDisposes = RxMap<String, List<DateTime>>();
  late final RxMap<String, List<DateTime>> _rxActives = RxMap<String, List<DateTime>>();
  late final RxMap<String, List<DateTime>> _rxInactives = RxMap<String, List<DateTime>>();

  final List<String> _ignoreDebugNames = <String>[];
  final List<String> _ignorePaths = <String>[];

  factory ObservableGlobalLogger() {
    return _instance;
  }

  ObservableGlobalLogger._();

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

  void disableLoggingFor(final List<Observable<dynamic>> sources) {
    for (int i = 0; i < sources.length; ++i) {
      final Observable<dynamic> source = sources[i];
      final String debugName = source.debugName;
      _ignoreDebugNames.add(debugName);
    }
  }

  void disableLoggingForClass(final Object clazz) {
    final String? filePath = _extractPathFromStack(clazz);
    if (filePath != null) {
      _ignorePaths.add(filePath);
    }
  }

  void emitActive(final Observable<dynamic> source) {
    if (_shouldIgnore(source)) {
      return;
    }
    final List<DateTime> current = _rxActives[source.debugName] ?? <DateTime>[];
    _rxActives[source.debugName] = <DateTime>[...current, DateTime.now()];
  }

  void emitDispose(final Observable<dynamic> source) {
    if (_shouldIgnore(source)) {
      return;
    }
    final List<DateTime> current = _rxDisposes[source.debugName] ?? <DateTime>[];
    _rxDisposes[source.debugName] = <DateTime>[...current, DateTime.now()];
  }

  void emitInactive(final Observable<dynamic> source) {
    if (_shouldIgnore(source)) {
      return;
    }
    final List<DateTime> current = _rxInactives[source.debugName] ?? <DateTime>[];
    _rxInactives[source.debugName] = <DateTime>[...current, DateTime.now()];
  }

  void emitNotify(final Observable<dynamic> source) {
    if (_shouldIgnore(source)) {
      return;
    }
    final List<DateTime> current = _rxNotifies[source.debugName] ?? <DateTime>[];
    _rxNotifies[source.debugName] = <DateTime>[...current, DateTime.now()];
  }

  void enableLoggingFor(final List<Observable<dynamic>> sources) {
    for (int i = 0; i < sources.length; ++i) {
      final Observable<dynamic> source = sources[i];
      final String debugName = source.debugName;
      _ignoreDebugNames.remove(debugName);
    }
  }

  void enableLoggingForClass(final Object clazz) {
    final String? path = _extractPathFromStack(clazz);
    if (path != null) {
      _ignorePaths.remove(path);
    }
  }

  String? _extractPathFromStack(final Object clazz) {
    if (_isParsableStack() == false) {
      return null;
    }

    final StackTrace stack = StackTrace.current;
    final String className = clazz.runtimeType.toString();
    final String sourceText = stack.toString();

    final List<String> lines = sourceText.split('\n');
    String? sourceLine;
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      if (line.contains(className)) {
        sourceLine = line;
        break;
      }

      if (line.contains('package') == false) {
        continue;
      }

      if (line.contains('observable_global_logger.dart')) {
        // internal usage
        continue;
      }
      sourceLine = line;
      break;
    }

    if (sourceLine == null) {
      return null;
    }
    // without line number
    return sourceLine.split('package')[1].split('.dart')[0];
  }

  bool _isParsableStack() {
    final String currentStack = StackTrace.current.toString();
    return currentStack.contains('package');
  }

  bool _shouldIgnore(final Observable<dynamic> source) {
    if (_loggingEnabled == false) {
      return true;
    }

    final bool isParsableStack = _isParsableStack();
    if (isParsableStack == false) {
      return true;
    }

    final String debugName = source.debugName;
    if (_ignoreDebugNames.contains(debugName)) {
      return true;
    }

    for (final String ignore in _ignorePaths) {
      if (debugName.contains(ignore)) {
        return true;
      }
    }

    return debugName.contains('dart_observable/src/api/log/observable_global_logger.dart');
  }

  static void disableGlobalLogger() {
    _loggingEnabled = false;
  }

  static void enableGlobalLogger() {
    _loggingEnabled = true;
  }
}

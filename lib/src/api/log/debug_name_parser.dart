String debugNameParser() {
  final StackTrace stack = StackTrace.current;
  final List<String> lines = stack.toString().split('\n');
  String? caller;
  if (lines.isEmpty) {
    caller = '';
  } else {
    for (final String line in lines) {
      if (line.contains('package') == false) {
        continue;
      }

      if (line.contains('dart_observable/') == false) {
        caller = line;
        break;
      }

      if (line.contains('global_metrics')) {
        caller = line;
        break;
      }
    }
    if (caller == null) {
      if (lines.length > 2) {
        caller = lines[1];
      } else {
        caller = lines[0];
      }
    }
  }

  return caller;
}

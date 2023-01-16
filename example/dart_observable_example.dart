import 'package:dart_observable/dart_observable.dart';

class Counter {
  final Rx<int> _rxCounter = Rx<int>(0);
  late final Observable<int> rxCounter = _rxCounter;

  void increment() {
    _rxCounter.value++;
  }
}

void main() {
  final Counter counter = Counter();
  counter.rxCounter.listen(
    onChange: (final Observable<int> source) {
      print('Counter changed to ${source.value}');
    },
  );

  counter.increment();
  final int rxCounter = counter.rxCounter.value;
  assert(rxCounter == 1);
}

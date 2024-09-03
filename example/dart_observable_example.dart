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
    onChange: (final int value) {
      print('Counter changed to $value');
    },
  );

  counter.increment();
  final int rxCounter = counter.rxCounter.value;
  assert(rxCounter == 1);
}

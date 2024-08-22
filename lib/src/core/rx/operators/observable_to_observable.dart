import '../../../../dart_observable.dart';
import '../../../api/change_tracking_observable.dart';
import 'observable_to_observable/flat_map.dart';
import 'observable_to_observable/transform.dart';

mixin OperatorsObservableToObservable<Self extends ChangeTrackingObservable<Self, T, C>, T, C>
    implements ChangeTrackingObservable<Self, T, C> {
  Self get self;

  @override
  Observable<T?> filter(final bool Function(Self source) predicate) {
    return transform<T?>(
      initialProvider: (final Self source) {
        if (predicate(source)) {
          return value;
        } else {
          return null;
        }
      },
      onChanged: (
        final Self source,
        final Emitter<T?> emitter,
      ) {
        if (predicate(source)) {
          emitter(source.value);
        }
      },
    );
  }

  @override
  Observable<T2> flatMap<T2>(
    final Observable<T2> Function(Self source) mapper,
  ) {
    return OperatorFlatMap<Self, T, C, T2>(
      source: self,
      mapper: mapper,
    );
  }

  @override
  Observable<T2> map<T2>(final T2 Function(Self source) onChanged) {
    return transform(
      initialProvider: (final Self source) {
        return onChanged(source);
      },
      onChanged: (
        final Self source,
        final Emitter<T2> emitter,
      ) {
        emitter(onChanged(source));
      },
    );
  }

  @override
  Observable<T2> transform<T2>({
    required final T2 Function(Self source) initialProvider,
    required final void Function(Self source, Emitter<T2> emitter) onChanged,
  }) {
    return OperatorTransform<Self, T, C, T2>(
      initialProvider(self),
      source: self,
      handler: onChanged,
    );
  }
}

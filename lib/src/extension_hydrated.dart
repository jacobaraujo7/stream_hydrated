import 'dart:async';
import 'dart:core';

import 'hydrated_transformer.dart';

extension StreamHydrated<T> on Stream<T> {
  Stream hydrated(String key, {seeded}) {
    return this.transform(HydratedTransformer(key, seeded));
  }
}

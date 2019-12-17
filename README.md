# stream_hydrated

Persist Stream Data in SharedPreference. Simple and Easy Operator

## Instalation

in pubspec.yaml
```
dependencies:
    stream_hydrated
```

## Using

The hydrate operator is automatically added to the Dart Streams API through Extensions.
To use just import the package and use it directly in the stream.

```dart
import 'package:stream_hydrated/stream_hydrated.dart';

...
Stream stream = Stream<int>.empty().hydrated('number', seeded: 1);
```



import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class HydratedTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;
  final T Function(String value) hydrate;
  final String Function(T value) persist;
  final String key;

  HydratedTransformer(this.key, T startValue, {this.hydrate, this.persist})
      : transformer = _buildTransformer(key, startValue, hydrate, persist);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(String key, T startValue,
      T Function(String value) hydrate, String Function(T value) persist) {
    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            try {
              if (startValue != null) {
                controller.add(startValue);
              }
              getHydratedValue(key, hydrate).then((value) {
                if (value != null) controller.add(value);
              });
            } catch (e, s) {
              controller.addError(e, s);
            }

            subscription = input.listen((data) {
              controller.add(data);
              putHydratedValue(key, data, persist);
            },
                onError: controller.addError,
                onDone: controller.close,
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }

  static Future<T> getHydratedValue<T>(
      String key, T Function(String value) hydrate) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      var value = prefs.get(key);
      return hydrate != null ? hydrate(value) : value;
    } else {
      return null;
    }
  }

  static Future putHydratedValue<T>(
      String key, T val, String Function(T value) persist) async {
    final prefs = await SharedPreferences.getInstance();
    if (val is int)
      await prefs.setInt(key, val);
    else if (val is double)
      await prefs.setDouble(key, val);
    else if (val is bool)
      await prefs.setBool(key, val);
    else if (val is String)
      await prefs.setString(key, val);
    else if (val is List<String>)
      await prefs.setStringList(key, val);
    else if (persist != null) await prefs.setString(key, persist(val));
  }
}

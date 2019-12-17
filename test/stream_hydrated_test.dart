import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stream_hydrated/stream_hydrated.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({'num': 2});
  });

  test('test extension with init value', () {
    Stream stream = Stream.value(1).hydrated('num');
    expect(stream, emits(1));
  });

  test('test extension without init value', () {
    Stream stream = Stream.empty().hydrated('num', seeded: 1);
    expect(stream, emits(1));
  });

  test('test extension hydrated value', () {
    Stream stream = Stream<int>.empty().hydrated('num');
    expect(stream, emits(2));
  });

  test('test extension hydrated value with seeded value', () {
    Stream stream = Stream<int>.empty().hydrated('num', seeded: 1);
    expect(stream, emitsInOrder([1, 2]));
  });

  test('test extension hydrated value with seeded value send', () async {
    StreamController controller = StreamController.broadcast();
    expect(controller.stream.hydrated('name'), emits('jacob'));
    controller.add('jacob');
  });

}

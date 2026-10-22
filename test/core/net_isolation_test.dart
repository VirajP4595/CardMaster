import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Rule R1: only lib/core/net may use the network. Fails the build if any
/// other file imports an HTTP or socket API.
void main() {
  test('only lib/core/net touches the network', () {
    final offenders = <String>[];
    final pattern = RegExp(
        r'''import\s+['"](package:http/|dart:io['"].*show.*(Socket|HttpClient))''');
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (f.path.replaceAll('\\', '/').startsWith('lib/core/net/')) continue;
      final src = f.readAsStringSync();
      if (pattern.hasMatch(src) ||
          src.contains('HttpClient(') ||
          src.contains('Socket.connect')) {
        offenders.add(f.path);
      }
    }
    expect(offenders, isEmpty);
  });
}

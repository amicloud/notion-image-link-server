import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  final port = '8080';
  final host = 'http://0.0.0.0:$port';
  late Process p;

  setUp(() async {
    p = await Process.start(
      'dart',
      ['run', 'bin/server.dart'],
      environment: {'PORT': port},
    );
    // Wait for server to start and print to stdout.
    await p.stdout.first;
  });

  tearDown(() => p.kill());

  test('Root', () async {
    final response = await get(Uri.parse('$host/'));
    expect(response.statusCode, 200);
    expect(response.body, 'Hello, World!\n');
  });

  test('Echo', () async {
    final response = await get(Uri.parse('$host/echo/hello'));
    expect(response.statusCode, 200);
    expect(response.body, 'hello\n');
  });

  test('frame creation', () async {
    final img =
        'https://dart.dev/assets/img/shared/dart/logo+text/horizontal/white.svg';
    final imgEncoded = Uri.encodeQueryComponent(
        'https://dart.dev/assets/img/shared/dart/logo+text/horizontal/white.svg');
    final dest = 'https://dart.dev/';
    final destEncoded = Uri.encodeQueryComponent('https://dart.dev/');
    final url = '$host/frame?dest=$destEncoded&img=$imgEncoded';
    print(url);
    final response = await get(Uri.parse(url));
    expect(response.statusCode, 200);
    expect(response.body, '''
  <html>
  <head>

  </head>

  <body>
  <a target = "_blank" href="$dest" style="appearance:none">
  <img src="$img" style="width: 100%; min-width: 0; height: 100%; min-height: 0;">
  </a>
  </body>
  </html>''');
  });

  test('404', () async {
    final response = await get(Uri.parse('$host/foobar'));
    expect(response.statusCode, 404);
  });
}

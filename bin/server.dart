import 'dart:io';
import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'limiter.dart';

// Configure routes.
final _router = Router()
  ..get('/frame', _renderFrameHandler);

Random random = Random();
final Map<String, int> requests = List.generate(1000000, (index) => {"${random.nextInt(255)}.${random.nextInt(100)}.${random.nextInt(100)}.${random.nextInt(100)}": random.nextInt(1000)}).reduce((value, element) => value..addAll(element));
//final Map<String, int> requests = {};
Limiter limiter = Limiter(requests: requests);

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET',
  'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept',
};

Response _renderFrameHandler(Request request) {
  final ip = (request.context["shelf.io.connection_info"] as HttpConnectionInfo).remoteAddress.address;
  final port = (request.context["shelf.io.connection_info"] as HttpConnectionInfo).remotePort;
  if(!limiter.handleIt("$ip:$port")) {
    return Response(429, body: 'Too many requests!\n');
  }
  // final dest = request.params['dest'];
  final dest = request.url.queryParameters['dest'];
  // final img = request.params['img'];
  final img = request.url.queryParameters['img'];
  final h = request.url.queryParameters['h'];
  final hMin= request.url.queryParameters['hMin'];
  final w = request.url.queryParameters['w'];
  final wMin= request.url.queryParameters['wMin'];
  String frame = '''
  <html>
  <head>

  </head>

  <body>
  <a target = "_blank" href="$dest" style="appearance:none">
  <img src="$img" style="width: ${w ?? 100}%; min-width: ${wMin ?? 0}; height: ${h ?? 100}%; min-height: ${hMin ?? 0};">
  </a>
  </body>
  </html>''';

  return Response.ok(frame, headers: {
    'Content-Type': 'text/html',
    ...corsHeaders});
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}

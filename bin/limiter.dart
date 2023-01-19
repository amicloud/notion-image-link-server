import 'dart:async';

class Limiter {
  final Map<String, int> requests;
  Limiter({required this.requests});
  final duration = Duration(seconds: 10);

  final int requestsPerDuration = 100;

  bool handleIt(String key) {
    if (requests.containsKey(key)) {
      requests[key] = requests[key]! + 1;
      return requests[key]! < requestsPerDuration;
    } else {
      requests[key] = 1;
      final _ = Timer(duration, () {
        requests.remove(key);
      });
      return true;
    }
  }
}

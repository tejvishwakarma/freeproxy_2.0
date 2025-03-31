import 'dart:async';
import 'dart:io';
import 'package:freeproxy/models/proxy.dart';
import 'package:freeproxy/models/proxy_status.dart';

class ProxyCheckerService {
  /// The timeout duration for proxy checks
  final Duration timeout = const Duration(seconds: 5);

  /// Checks if a proxy is alive and working
  Future<ProxyStatus> checkProxy(Proxy proxy) async {
    final stopwatch = Stopwatch()..start();
    bool isAlive = false;
    int responseTimeMs = 0;

    try {
      // Since we can't easily check SOCKS5 without additional libraries,
      // we'll just check if the proxy server is reachable
      final socket = await Socket.connect(
        proxy.ip,
        int.parse(proxy.port),
        timeout: timeout,
      );

      // If we reach here, the connection was successful
      isAlive = true;
      responseTimeMs = stopwatch.elapsedMilliseconds;

      // Close the socket
      await socket.close();
    } catch (e) {
      // Connection failed, proxy is not working
      isAlive = false;
      print('Proxy check failed: ${e.toString()}');
    }

    stopwatch.stop();

    // Return the status
    // Adjust these parameters based on your actual ProxyStatus model
    return ProxyStatus(
      isAlive: isAlive,
      responseTimeMs: responseTimeMs,
      checkedAt: DateTime.now(), // Changed from lastChecked to checkedAt
    );
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Shared HTTP client for Gemini API calls that prefers IPv4 on native
/// platforms. Many mobile/ISP networks advertise broken IPv6 routes where
/// `generativelanguage.googleapis.com` AAAA records time out after 20+ seconds
/// while IPv4 A records connect in <50ms.
class GeminiHttp {
  GeminiHttp._();

  static http.Client? _client;

  static http.Client get client {
    if (kIsWeb) return http.Client();
    return _client ??= _createIpv4Client();
  }

  static http.Client _createIpv4Client() {
    final ioHttp = HttpClient();
    ioHttp.connectionTimeout = const Duration(seconds: 10);
    ioHttp.idleTimeout = const Duration(seconds: 15);
    ioHttp.connectionFactory = (
      Uri uri,
      String? proxyHost,
      int? proxyPort,
    ) async {
      final host = uri.host;
      final isSecure = uri.scheme == 'https';
      final port = uri.hasPort ? uri.port : (isSecure ? 443 : 80);

      if (proxyHost == null && host.isNotEmpty) {
        try {
          final ipv4Addrs = await InternetAddress.lookup(
            host,
            type: InternetAddressType.IPv4,
          ).timeout(const Duration(seconds: 4));

          if (ipv4Addrs.isNotEmpty) {
            final addr = ipv4Addrs.first;
            if (!isSecure) {
              return await Socket.startConnect(addr, port);
            }
            final futureSecure = () async {
              final raw = await Socket.connect(
                addr,
                port,
                timeout: const Duration(seconds: 8),
              );
              try {
                return await SecureSocket.secure(
                  raw,
                  host: host,
                ).timeout(const Duration(seconds: 8));
              } catch (e) {
                raw.destroy();
                rethrow;
              }
            }();
            return ConnectionTask.fromSocket(futureSecure, () {});
          }
        } catch (e) {
          debugPrint('GeminiHttp IPv4 connect fallback for $host: $e');
        }
      }

      return isSecure
          ? SecureSocket.startConnect(host, port)
          : Socket.startConnect(host, port);
    };
    return IOClient(ioHttp);
  }
}

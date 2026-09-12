import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Meeting-source sites (AA/NA intergroup TSML feeds) don't publish CORS
/// headers — fine for native's HTTP client, fatal for a browser fetch.
/// On web, routes GET requests through a same-purpose CORS proxy that
/// re-adds permissive headers; on native, behaves like a plain client.
class WebCorsProxyClient extends http.BaseClient {
  WebCorsProxyClient({http.Client? inner}) : _inner = inner ?? http.Client();

  final http.Client _inner;

  static const _proxyBase = 'https://cors-proxy.drownedwoods.com/';

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (!kIsWeb) return _inner.send(request);

    final proxied = Uri.parse(_proxyBase).replace(
      queryParameters: {'url': request.url.toString()},
    );
    final proxyRequest = http.Request(request.method, proxied)
      ..headers.addAll(request.headers);
    return _inner.send(proxyRequest);
  }
}

/// Default client for meeting-source adapters — use in place of a bare
/// `client ?? http.Client()` so every adapter gets the web CORS workaround
/// without needing its own platform check.
http.Client createDefaultMeetingHttpClient() => WebCorsProxyClient();

// Mobile (iOS/Android): production URL only (no localhost/LAN fallback).

/// Hosted API (set when building for phones outside your LAN).
///
/// ```sh
/// flutter build apk --dart-define=API_BASE_URL=https://api.yourdomain.com
/// ```
const String kApiBaseUrlFromEnvironment = String.fromEnvironment('API_BASE_URL');

String _trimTrailingSlash(String url) {
  if (url.endsWith('/')) return url.substring(0, url.length - 1);
  return url;
}

String get apiBaseUrl {
  final env = kApiBaseUrlFromEnvironment.trim();
  if (env.isNotEmpty) {
    return _trimTrailingSlash(env);
  }
  throw StateError(
    'API_BASE_URL is required. Build/run with '
    '--dart-define=API_BASE_URL=https://your-api-host',
  );
}

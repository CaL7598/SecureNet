// Web (no dart:io): optional compile-time API URL.
const String kApiBaseUrlFromEnvironment = String.fromEnvironment('API_BASE_URL');

String _trimTrailingSlash(String url) {
  if (url.endsWith('/')) return url.substring(0, url.length - 1);
  return url;
}

String get apiBaseUrl {
  if (kApiBaseUrlFromEnvironment.isNotEmpty) {
    return _trimTrailingSlash(kApiBaseUrlFromEnvironment);
  }
  return 'http://localhost:8000';
}

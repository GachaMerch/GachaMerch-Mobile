import 'package:flutter_dotenv/flutter_dotenv.dart';

const String _defaultBackendBaseUrl = 'https://gachamerch-be.drian.my.id';
const String _backendBaseUrlFromDefine = String.fromEnvironment('BACKEND_BASE_URL');

String get backendBaseUrl {
  final dartDefineValue = _backendBaseUrlFromDefine.trim();
  if (dartDefineValue.isNotEmpty) {
    return _normalizeBackendBaseUrl(dartDefineValue);
  }

  if (dotenv.isInitialized) {
    final envValue = dotenv.maybeGet('BACKEND_BASE_URL', fallback: '')?.trim() ?? '';
    if (envValue.isNotEmpty) {
      return _normalizeBackendBaseUrl(envValue);
    }
  }

  return _defaultBackendBaseUrl;
}

String get backendApiBaseUrl => '$backendBaseUrl/api';

String _normalizeBackendBaseUrl(String value) {
  var output = value.trim();
  while (output.endsWith('/')) {
    output = output.substring(0, output.length - 1);
  }
  if (output.toLowerCase().endsWith('/api')) {
    output = output.substring(0, output.length - 4);
  }
  return output.isEmpty ? _defaultBackendBaseUrl : output;
}

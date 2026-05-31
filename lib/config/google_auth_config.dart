import 'package:flutter_dotenv/flutter_dotenv.dart';

String get googleServerClientId {
  if (!dotenv.isInitialized) {
    return '';
  }

  return dotenv.maybeGet('GOOGLE_SERVER_CLIENT_ID', fallback: '')?.trim() ?? '';
}

bool get isGoogleSignInConfigured => googleServerClientId.isNotEmpty;

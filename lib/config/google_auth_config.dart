const String _defaultGoogleServerClientId =
    '477114095926-6dcctc43dpfesn78js1jfl4estm8dggj.apps.googleusercontent.com';

const String googleServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  defaultValue: _defaultGoogleServerClientId,
);

bool get isGoogleSignInConfigured => googleServerClientId.isNotEmpty;

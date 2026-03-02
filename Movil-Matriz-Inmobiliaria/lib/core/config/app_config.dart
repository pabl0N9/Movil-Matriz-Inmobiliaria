class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const String loginPath = String.fromEnvironment(
    'API_LOGIN_PATH',
    defaultValue: '/api/auth/login',
  );

  static const String loginUrl = String.fromEnvironment(
    'API_LOGIN_URL',
    defaultValue: '',
  );

  static const String profilePath = String.fromEnvironment(
    'API_PROFILE_PATH',
    defaultValue: '/api/auth/me',
  );

  static const String profileUrl = String.fromEnvironment(
    'API_PROFILE_URL',
    defaultValue: '',
  );

  static const String loginEmailKey = String.fromEnvironment(
    'API_LOGIN_EMAIL_KEY',
    defaultValue: 'email',
  );

  static const String loginPasswordKey = String.fromEnvironment(
    'API_LOGIN_PASSWORD_KEY',
    defaultValue: 'password',
  );

  static const String propertiesPath = String.fromEnvironment(
    'API_PROPERTIES_PATH',
    defaultValue: '/api/v1/inmuebles',
  );

  static const String propertiesUrl = String.fromEnvironment(
    'API_PROPERTIES_URL',
    defaultValue: '',
  );

  static const String ownerPropertiesUrl = String.fromEnvironment(
    'API_OWNER_PROPERTIES_URL',
    defaultValue: '',
  );

  static const String propertiesOwnerQueryKey = String.fromEnvironment(
    'API_PROPERTIES_OWNER_QUERY_KEY',
    defaultValue: 'propietario_id',
  );

  static const bool profileLookupEnabled = bool.fromEnvironment(
    'API_PROFILE_LOOKUP_ENABLED',
    defaultValue: false,
  );

  static const String ownerRoleName = String.fromEnvironment(
    'API_OWNER_ROLE_NAME',
    defaultValue: 'propietario',
  );

  static const int ownerRoleId = int.fromEnvironment(
    'API_OWNER_ROLE_ID',
    defaultValue: -1,
  );

  static Uri get loginUri {
    if (loginUrl.trim().isNotEmpty) {
      return _parseFlexibleUrl(loginUrl);
    }

    final base = _normalizeBase(apiBaseUrl);
    final path = _normalizePath(loginPath);
    return _parseFlexibleUrl('$base$path');
  }

  static Uri get profileUri {
    if (profileUrl.trim().isNotEmpty) {
      return _parseFlexibleUrl(profileUrl);
    }

    final base = _effectiveBaseUrl();
    final path = _normalizePath(profilePath);
    return _parseFlexibleUrl('$base$path');
  }

  static Uri get propertiesUri {
    if (propertiesUrl.trim().isNotEmpty) {
      return _parseFlexibleUrl(propertiesUrl);
    }

    final base = _effectiveBaseUrl();
    final path = _normalizePath(propertiesPath);
    return _parseFlexibleUrl('$base$path');
  }

  static Uri? get ownerPropertiesUri {
    if (ownerPropertiesUrl.trim().isEmpty) {
      return null;
    }
    return _parseFlexibleUrl(ownerPropertiesUrl);
  }

  static String _effectiveBaseUrl() {
    if (loginUrl.trim().isNotEmpty) {
      final login = _parseFlexibleUrl(loginUrl);
      return '${login.scheme}://${login.authority}';
    }
    return _normalizeBase(apiBaseUrl);
  }

  static String _normalizeBase(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'http://localhost:3000';
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
    }

    final withScheme = 'http://$trimmed';
    return withScheme.endsWith('/')
        ? withScheme.substring(0, withScheme.length - 1)
        : withScheme;
  }

  static String _normalizePath(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '/api/auth/login';
    }
    return trimmed.startsWith('/') ? trimmed : '/$trimmed';
  }

  static Uri _parseFlexibleUrl(String value) {
    final trimmed = value.trim();
    final withScheme = (trimmed.startsWith('http://') || trimmed.startsWith('https://'))
        ? trimmed
        : 'http://$trimmed';
    return Uri.parse(withScheme);
  }
}

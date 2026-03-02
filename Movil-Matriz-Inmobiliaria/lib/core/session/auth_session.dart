import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  static const _kToken = 'auth_token';
  static const _kUserId = 'auth_user_id';
  static const _kEmail = 'auth_email';
  static const _kRole = 'auth_role';

  final String? token;
  final int? userId;
  final String? email;
  final String? role;

  const AuthSession({
    this.token,
    this.userId,
    this.email,
    this.role,
  });

  static Future<AuthSession> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthSession(
      token: prefs.getString(_kToken),
      userId: prefs.getInt(_kUserId),
      email: prefs.getString(_kEmail),
      role: prefs.getString(_kRole),
    );
  }

  static Future<void> save({
    String? token,
    int? userId,
    String? email,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (token != null) {
      await prefs.setString(_kToken, token);
    } else {
      await prefs.remove(_kToken);
    }

    if (userId != null) {
      await prefs.setInt(_kUserId, userId);
    } else {
      await prefs.remove(_kUserId);
    }

    if (email != null && email.isNotEmpty) {
      await prefs.setString(_kEmail, email);
    } else {
      await prefs.remove(_kEmail);
    }

    if (role != null && role.isNotEmpty) {
      await prefs.setString(_kRole, role);
    } else {
      await prefs.remove(_kRole);
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUserId);
    await prefs.remove(_kEmail);
    await prefs.remove(_kRole);
  }
}

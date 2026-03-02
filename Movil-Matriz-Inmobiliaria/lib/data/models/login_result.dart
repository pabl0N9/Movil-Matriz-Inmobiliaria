class LoginResult {
  final bool success;
  final String message;
  final String? token;
  final String? role;
  final int? userId;
  final String? email;

  const LoginResult({
    required this.success,
    required this.message,
    this.token,
    this.role,
    this.userId,
    this.email,
  });
}

import 'dart:convert';

import 'package:flutter_citas_app/core/config/app_config.dart';
import 'package:flutter_citas_app/core/network/http_client_factory.dart';
import 'package:flutter_citas_app/core/session/auth_session.dart';
import 'package:flutter_citas_app/data/models/login_result.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  static void register(String name, String email, String password) {}

  static Future<LoginResult> login(String email, String password) async {
    try {
      final loginResponse = await _requestLogin(email, password);

      if (loginResponse.statusCode < 200 || loginResponse.statusCode >= 300) {
        if (loginResponse.statusCode == 429) {
          final retryAfter = loginResponse.headers['retry-after'];
          final suffix = (retryAfter != null && retryAfter.isNotEmpty)
              ? ' Intenta de nuevo en $retryAfter segundos.'
              : ' Intenta de nuevo en unos minutos.';
          return LoginResult(success: false, message: 'Demasiados intentos.$suffix');
        }
        final serverMessage = _tryExtractMessage(loginResponse.body);
        return LoginResult(
          success: false,
          message: serverMessage ?? 'Credenciales incorrectas o acceso no autorizado',
        );
      }

      final decoded = _decodeBody(loginResponse.body);
      final token = _extractToken(decoded);
      final userId = _extractUserId(decoded);
      final userEmail = _extractUserEmail(decoded, fallback: email);
      var role = _extractRole(decoded);
      var roleId = _extractRoleId(decoded);

      if (!_isOwnerRole(role, roleId) && token != null && AppConfig.profileLookupEnabled) {
        final profileData = await _fetchProfileData(token);
        if (profileData != null) {
          role = _extractRole(profileData) ?? role;
          roleId = _extractRoleId(profileData) ?? roleId;
        }
      }

      if (!_isOwnerRole(role, roleId)) {
        return LoginResult(
          success: false,
          message:
              'Solo usuarios con rol propietario pueden iniciar sesion (rol recibido: ${role ?? "sin rol"}, id_rol: ${roleId ?? "sin id"})',
          role: role,
          userId: userId,
          email: userEmail,
        );
      }

      await AuthSession.save(
        token: token,
        userId: userId,
        email: userEmail,
        role: role ?? AppConfig.ownerRoleName,
      );

      return LoginResult(
        success: true,
        message: 'Login exitoso',
        token: token,
        role: role ?? AppConfig.ownerRoleName,
        userId: userId,
        email: userEmail,
      );
    } on FormatException catch (e) {
      return LoginResult(
        success: false,
        message: 'Respuesta del servidor invalida: ${e.message}',
      );
    } catch (_) {
      return const LoginResult(success: false, message: 'No se pudo conectar con el servidor');
    }
  }

  static Future<http.Response> _requestLogin(String email, String password) {
    final payload = <String, dynamic>{
      AppConfig.loginEmailKey: email,
      AppConfig.loginPasswordKey: password,
    };

    return HttpClientFactory.client.post(
      AppConfig.loginUri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
  }

  static Future<Map<String, dynamic>?> _fetchProfileData(String token) async {
    try {
      final response = await HttpClientFactory.client.get(
        AppConfig.profileUri,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      return _decodeBody(response.body);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _decodeBody(String body) {
    final sanitized = body.trim().replaceFirst('\uFEFF', '');
    if (sanitized.isEmpty) throw const FormatException('respuesta vacia');

    final decoded = jsonDecode(sanitized);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
      return Map<String, dynamic>.from(decoded.first as Map);
    }
    throw const FormatException('formato JSON no soportado');
  }

  static bool _isOwnerRole(String? role, int? roleId) {
    if (AppConfig.ownerRoleId > 0 && roleId != null && roleId == AppConfig.ownerRoleId) {
      return true;
    }
    if (role == null) return false;
    final normalized = role.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '');
    final ownerName =
        AppConfig.ownerRoleName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '');
    return normalized == ownerName ||
        normalized.contains('propiet') ||
        normalized == 'owner' ||
        normalized == 'role_propietario' ||
        normalized == 'rol_propietario';
  }

  static String? _extractRole(Map<String, dynamic> json) {
    final direct = _findFirstString(json, const [
      'role',
      'rol',
      'tipoRol',
      'tipo_rol',
      'user.role',
      'user.rol',
      'usuario.role',
      'usuario.rol',
      'usuario.tipo_rol',
      'data.role',
      'data.rol',
      'data.user.role',
      'data.user.rol',
      'data.usuario.role',
      'data.usuario.rol',
      'data.perfil.role',
      'data.perfil.rol',
    ]);
    if (direct != null) return direct;

    final roleFromCollection = _extractRoleFromCollections(json);
    if (roleFromCollection != null) return roleFromCollection;

    final deepRole = _findRoleLikeValue(json);
    if (deepRole != null) return deepRole;

    final roleId = _extractRoleId(json);
    if (AppConfig.ownerRoleId > 0 && roleId == AppConfig.ownerRoleId) {
      return AppConfig.ownerRoleName;
    }
    if (roleId == 3) return 'propietario';
    return null;
  }

  static int? _extractRoleId(Map<String, dynamic> json) {
    return _findFirstInt(json, const [
      'roleId',
      'role_id',
      'rolId',
      'rol_id',
      'idRol',
      'id_rol',
      'user.roleId',
      'user.role_id',
      'user.idRol',
      'user.id_rol',
      'usuario.roleId',
      'usuario.role_id',
      'usuario.idRol',
      'usuario.id_rol',
      'data.roleId',
      'data.role_id',
      'data.idRol',
      'data.id_rol',
      'data.user.roleId',
      'data.user.role_id',
      'data.user.idRol',
      'data.user.id_rol',
      'data.usuario.roleId',
      'data.usuario.role_id',
      'data.usuario.idRol',
      'data.usuario.id_rol',
    ]);
  }

  static int? _extractUserId(Map<String, dynamic> json) {
    return _findFirstInt(json, const [
      'id',
      'userId',
      'user_id',
      'idUsuario',
      'id_usuario',
      'data.id',
      'data.user.id',
      'data.user.userId',
      'data.user.user_id',
      'data.usuario.id',
      'data.usuario.user_id',
    ]);
  }

  static String? _extractUserEmail(Map<String, dynamic> json, {String? fallback}) {
    return _findFirstString(json, const [
          'email',
          'correo',
          'user.email',
          'user.correo',
          'usuario.email',
          'usuario.correo',
          'data.email',
          'data.correo',
          'data.user.email',
          'data.user.correo',
          'data.usuario.email',
          'data.usuario.correo',
        ]) ??
        fallback;
  }

  static String? _extractRoleFromCollections(Map<String, dynamic> json) {
    final collections = [
      _readPath(json, 'roles'),
      _readPath(json, 'user.roles'),
      _readPath(json, 'usuario.roles'),
      _readPath(json, 'data.roles'),
      _readPath(json, 'data.user.roles'),
      _readPath(json, 'data.usuario.roles'),
      _readPath(json, 'authorities'),
      _readPath(json, 'user.authorities'),
      _readPath(json, 'data.authorities'),
    ];
    for (final collection in collections) {
      final role = _extractRoleFromCollectionNode(collection);
      if (role != null) return role;
    }
    return null;
  }

  static String? _extractRoleFromCollectionNode(dynamic node) {
    if (node is String && node.trim().isNotEmpty) return node.trim();
    if (node is List) {
      for (final item in node) {
        final role = _extractRoleFromCollectionNode(item);
        if (role != null) return role;
      }
      return null;
    }
    if (node is Map) {
      final mapped = Map<String, dynamic>.from(node);
      final role = _findFirstString(mapped, const [
        'role',
        'rol',
        'name',
        'nombre',
        'authority',
        'slug',
      ]);
      if (role != null) return role;
      for (final value in mapped.values) {
        final nestedRole = _extractRoleFromCollectionNode(value);
        if (nestedRole != null) return nestedRole;
      }
    }
    return null;
  }

  static String? _extractToken(Map<String, dynamic> json) {
    return _findFirstString(json, const [
      'token',
      'accessToken',
      'access_token',
      'jwt',
      'data.token',
      'data.accessToken',
      'data.access_token',
      'data.jwt',
      'data.auth.token',
      'data.auth.accessToken',
      'data.auth.access_token',
      'data.session.token',
      'data.session.accessToken',
      'data.session.access_token',
      'data.user.token',
    ]);
  }

  static String? _tryExtractMessage(String body) {
    try {
      final map = _decodeBody(body);
      return _findFirstString(map, const [
        'message',
        'mensaje',
        'error',
        'data.message',
        'data.mensaje',
      ]);
    } catch (_) {
      return null;
    }
  }

  static String? _findFirstString(Map<String, dynamic> source, List<String> paths) {
    for (final path in paths) {
      final value = _readPath(source, path);
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static int? _findFirstInt(Map<String, dynamic> source, List<String> paths) {
    for (final path in paths) {
      final value = _readPath(source, path);
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static String? _findRoleLikeValue(dynamic node) {
    if (node is Map) {
      for (final entry in node.entries) {
        final key = entry.key.toString().toLowerCase();
        final value = entry.value;
        if ((key.contains('role') || key.contains('rol')) && value is String) {
          final candidate = value.trim();
          if (candidate.isNotEmpty) return candidate;
        }
        final deep = _findRoleLikeValue(value);
        if (deep != null) return deep;
      }
    } else if (node is List) {
      for (final item in node) {
        final deep = _findRoleLikeValue(item);
        if (deep != null) return deep;
      }
    }
    return null;
  }

  static dynamic _readPath(Map<String, dynamic> source, String path) {
    dynamic current = source;
    for (final part in path.split('.')) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' show BrowserClient;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reporte_model.dart';
import '../models/user_model.dart';

/// Servicio para gestionar los reportes del propietario
class ReportesService {
  static const String baseUrl =
      'https://inmotech-api-develop.onrender.com/api/v1';
  static const String reportesEndpoint = '/reportes-inmobiliarios';

  http.Client _client() {
    if (kIsWeb) {
      final c = BrowserClient();
      c.withCredentials = true;
      return c;
    }
    return http.Client();
  }

  // Singleton
  static final ReportesService _instance = ReportesService._internal();
  factory ReportesService() => _instance;
  ReportesService._internal();

  // Headers base
  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Obtener token guardado
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Headers autenticados
  Future<Map<String, String>> get _authHeaders async {
    final token = await _getToken();
    return {
      ..._headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Obtener usuario actual
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        return User.fromJson(json.decode(userJson));
      }
    } catch (e) {
      debugPrint('Error al obtener usuario actual: $e');
    }
    return null;
  }

  /// Obtiene los reportes filtrados (opcionalmente por propietario o administrativo asignado)
  Future<List<Reporte>> obtenerReportes(
      {int? propietarioId, int? administrativoId}) async {
    final client = _client();
    try {
      var url = '$baseUrl$reportesEndpoint';
      if (propietarioId != null) {
        url += '?id_propietario=$propietarioId';
      }

      final response = await client.get(
        Uri.parse(url),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic>? data = responseData['data'] is List
            ? responseData['data']
            : (responseData['data'] is Map
                ? responseData['data']['data']
                : null);

        if (data != null) {
          var lista = data.map((json) => Reporte.fromJson(json)).toList();
          if (administrativoId != null) {
            lista = lista
                .where((r) => r.idPersonaReporta == administrativoId)
                .toList();
          }
          return lista;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error al obtener reportes: $e');
      return [];
    } finally {
      if (!kIsWeb) client.close();
    }
  }

  /// Obtiene un reporte específico por su ID
  Future<Reporte?> obtenerReportePorId(String id) async {
    final client = _client();
    try {
      final response = await client.get(
        Uri.parse('$baseUrl$reportesEndpoint/$id'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'];
        if (data != null) {
          return Reporte.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener reporte por ID: $e');
      return null;
    } finally {
      if (!kIsWeb) client.close();
    }
  }

  /// Calcula las estadísticas de los reportes
  Future<Map<EstadoReporte, int>> obtenerEstadisticas(
      {int? propietarioId, int? administrativoId}) async {
    final reportes = await obtenerReportes(
        propietarioId: propietarioId, administrativoId: administrativoId);
    final estadisticas = <EstadoReporte, int>{
      EstadoReporte.pendiente: 0,
      EstadoReporte.enProgreso: 0,
      EstadoReporte.finalizado: 0,
      EstadoReporte.urgente: 0,
    };

    for (var reporte in reportes) {
      estadisticas[reporte.estado] = (estadisticas[reporte.estado] ?? 0) + 1;
    }

    return estadisticas;
  }

  /// Filtra reportes por múltiples criterios
  Future<List<Reporte>> filtrarReportes({
    EstadoReporte? estado,
    String? query,
    int? propietarioId,
    int? administrativoId,
  }) async {
    var reportes = await obtenerReportes(
        propietarioId: propietarioId, administrativoId: administrativoId);

    // Filtrar por estado si se proporciona
    if (estado != null) {
      reportes = reportes.where((r) => r.estado == estado).toList();
    }

    // Filtrar por búsqueda si se proporciona
    if (query != null && query.isNotEmpty) {
      final queryLower = query.toLowerCase();
      reportes = reportes.where((reporte) {
        return reporte.id.toLowerCase().contains(queryLower) ||
            reporte.ubicacion.toLowerCase().contains(queryLower) ||
            reporte.tipoInmueble.toLowerCase().contains(queryLower) ||
            reporte.propietario.toLowerCase().contains(queryLower) ||
            reporte.tipoReporte.toLowerCase().contains(queryLower) ||
            reporte.responsable.toLowerCase().contains(queryLower) ||
            reporte.referencia.toLowerCase().contains(queryLower) ||
            reporte.descripcion.toLowerCase().contains(queryLower);
      }).toList();
    }

    return reportes;
  }

  /// Obtiene el total de seguimientos de todos los reportes de un propietario o administrativo
  Future<int> obtenerTotalSeguimientos(
      {int? propietarioId, int? administrativoId}) async {
    final reportes = await obtenerReportes(
        propietarioId: propietarioId, administrativoId: administrativoId);
    return reportes.fold<int>(
        0, (sum, reporte) => sum + reporte.totalSeguimientos);
  }

  /// Calcula el progreso promedio de todos los reportes de un propietario o administrativo
  Future<double> obtenerProgresoPromedio(
      {int? propietarioId, int? administrativoId}) async {
    final reportes = await obtenerReportes(
        propietarioId: propietarioId, administrativoId: administrativoId);
    if (reportes.isEmpty) return 0.0;

    final progresoTotal = reportes.fold<double>(
      0.0,
      (sum, reporte) => sum + reporte.progreso,
    );

    return progresoTotal / reportes.length;
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' show BrowserClient;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/inmueble_model.dart';

class InmueblesService {
  static const String baseUrl =
      'https://inmotech-api-develop.onrender.com/api/v1';
  static const String inmueblesEndpoint = '/inmuebles';

  // Singleton
  static final InmueblesService _instance = InmueblesService._internal();
  factory InmueblesService() => _instance;
  InmueblesService._internal();

  http.Client _client() {
    if (kIsWeb) {
      final c = BrowserClient();
      c.withCredentials = true;
      return c;
    }
    return http.Client();
  }

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> get _authHeaders async {
    final token = await _getToken();
    return {
      ..._headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetch all active inmuebles from API
  Future<List<Inmueble>> listarInmuebles() async {
    final client = _client();
    try {
      final response = await client.get(
        Uri.parse('$baseUrl$inmueblesEndpoint?estado=activo&limite=100'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData is Map ? responseData['data'] : null;

        if (data != null && data is Map && data['inmuebles'] is List) {
          return (data['inmuebles'] as List)
              .map((j) => Inmueble.fromJson(j))
              .where((i) => i.estado)
              .toList();
        } else if (data is List) {
          return data
              .map((j) => Inmueble.fromJson(j))
              .where((i) => i.estado)
              .toList();
        }
      } else {
        debugPrint(
            'Error al listar inmuebles: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error al listar inmuebles: $e');
    } finally {
      if (!kIsWeb) {
        client.close();
      }
    }
    return [];
  }

  /// Check availability for a specific inmueble on a given date.
  /// Returns list of available time slot strings like ["08:00:00", "09:00:00", ...]
  Future<List<String>> obtenerDisponibilidad(
      int idInmueble, String fecha) async {
    final client = _client();
    try {
      final response = await client.get(
        Uri.parse(
            '$baseUrl$inmueblesEndpoint/$idInmueble/disponibilidad?fecha=$fecha'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData is Map ? responseData['data'] : null;

        if (data != null &&
            data is Map &&
            data['horarios_disponibles'] is List) {
          final horarios = data['horarios_disponibles'] as List;
          return horarios
              .map((h) => h['hora_inicio']?.toString() ?? '')
              .where((h) => h.isNotEmpty)
              .toList();
        }
      } else {
        debugPrint(
            'Error al obtener disponibilidad: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint(
          'Error al obtener disponibilidad del inmueble $idInmueble: $e');
    } finally {
      if (!kIsWeb) {
        client.close();
      }
    }
    return [];
  }

  /// Check if a specific inmueble is available at a given date and time
  Future<bool> estaDisponible(
      int idInmueble, String fecha, String horaInicio) async {
    final disponibles = await obtenerDisponibilidad(idInmueble, fecha);
    // Normalize to HH:mm for comparison
    final horaTarget =
        horaInicio.length >= 5 ? horaInicio.substring(0, 5) : horaInicio;
    return disponibles.any((h) {
      final horaSlot = h.length >= 5 ? h.substring(0, 5) : h;
      return horaSlot == horaTarget;
    });
  }
}

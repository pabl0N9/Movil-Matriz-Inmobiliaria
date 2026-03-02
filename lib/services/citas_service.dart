import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' show BrowserClient;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cita_model.dart';
import '../models/user_model.dart' hide TipoDocumento;
import 'notification_service.dart';
import 'appointment_integration_service.dart';

class CitasService {
  // Para Flutter Web usar 127.0.0.1
  static const String baseUrl = 'http://localhost:5000/api/v1';
  static const String citasEndpoint = '/citas';
  static const String misCitasEndpoint = '/citas/mis-citas';

  http.Client _client() {
    if (kIsWeb) {
      final c = BrowserClient();
      c.withCredentials = true; // enviar cookies httpOnly en web
      return c;
    }
    return http.Client();
  }

  // Singleton
  static final CitasService _instance = CitasService._internal();
  factory CitasService() => _instance;
  CitasService._internal();

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

  TipoDocumento _mapTipoDocFromUser(String? raw) {
    final value = (raw ?? '').toUpperCase();
    switch (value) {
      case 'CC':
      case 'CE':
        return TipoDocumento.cedula;
      case 'PASAPORTE':
      case 'P':
        return TipoDocumento.pasaporte;
      case 'TI':
        return TipoDocumento.tarjetaIdentidad;
      case 'RC':
        return TipoDocumento.registroCivil;
      default:
        return TipoDocumento.cedula;
    }
  }

  // Headers autenticados
  Future<Map<String, String>> get _authHeaders async {
    final token = await _getToken();
    return {
      ..._headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  int _mapServicioToId(String servicio) {
    const servicioMapping = {
      'Visita a Propiedad': 1,
      'Avalúos': 2,
      'Gestión de Alquileres': 3,
      'Asesoría Legal': 4,
    };
    return servicioMapping[servicio] ?? 1;
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

  // Obtener todas las citas del usuario actual (con cache offline)
  Future<List<Cita>> obtenerCitas() async {
    final client = _client();
    try {
      final user = await getCurrentUser();
      if (user == null) return [];

      final response = await client.get(
        Uri.parse('$baseUrl$misCitasEndpoint'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic>? citasJson =
            responseData is Map && responseData.containsKey('data')
                ? responseData['data'] as List<dynamic>?
                : (responseData is List ? responseData : null);

        if (citasJson != null) {
          final citas = citasJson.map((json) {
            final base = Cita.fromJson(json);
            return base.copyWith(
              nombreCompleto: base.nombreCompleto.isNotEmpty
                  ? null
                  : user.nombreCompletoTexto,
              telefono:
                  base.telefono.isNotEmpty ? null : user.telefonoSeguro,
              correo: base.correo.isNotEmpty ? null : user.correoSeguro,
              numeroDocumento: base.numeroDocumento.isNotEmpty
                  ? null
                  : user.numeroDocumentoSeguro,
              tipoDocumento: user.tipoDocumentoSeguro.isNotEmpty
                  ? _mapTipoDocFromUser(user.tipoDocumentoSeguro)
                  : null,
            );
          }).toList();
          await _saveCitasToCache(citas); // cache local
          return citas;
        } else {
          debugPrint('Formato de respuesta inesperado: $responseData');
          return await _loadCitasFromCache();
        }
      } else {
        debugPrint(
            'Error al obtener citas del servidor: ${response.statusCode} - ${response.body}');
        return await _loadCitasFromCache();
      }
    } catch (e) {
      debugPrint('Error al obtener citas del servidor: $e');
      return await _loadCitasFromCache();
    } finally {
      if (!kIsWeb) {
        client.close();
      }
    }
  }

  // Crear una nueva cita (flujo usuario)
  Future<Cita?> crearCita({
    required DateTime fechaHora,
    required String servicio,
    required String detalles,
  }) async {
    final client = _client();
    try {
      final user = await getCurrentUser();
      if (user == null) {
        debugPrint('Usuario no encontrado');
        return null;
      }

      final idServicio = _mapServicioToId(servicio); // default a Visita a Propiedad

      // Separar nombres y apellidos (logica simple)
      final partesNombre = user.nombreCompleto.trim().split(' ');
      final nombreCompleto = partesNombre.isNotEmpty ? partesNombre.first : 'Usuario';
      final apellidoCompleto =
          partesNombre.length > 1 ? partesNombre.sublist(1).join(' ') : 'Sin Apellido';

      final citaData = {
        'tipo_documento':
            user.tipoDocumentoSeguro.isNotEmpty ? user.tipoDocumentoSeguro : 'CC',
        'numero_documento': user.numeroDocumentoSeguro.isNotEmpty
            ? user.numeroDocumentoSeguro
            : user.id.toString().padLeft(10, '0'),
        'nombre_completo': nombreCompleto,
        'apellido_completo': apellidoCompleto,
        'email': user.correoSeguro,
        'telefono': user.telefonoSeguro.isNotEmpty
            ? user.telefonoSeguro
            : '+573000000000',
        'id_inmueble': 1,
        'id_servicio': idServicio,
        'fecha_cita': fechaHora.toIso8601String().split('T')[0],
        'hora_inicio':
            '${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}',
        'hora_fin':
            '${(fechaHora.hour + 1).toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}',
        'observaciones': detalles,
        'id_estado_cita': 1, // solicitada
      };

      final response = await client.post(
        Uri.parse('$baseUrl$citasEndpoint'),
        headers: await _authHeaders,
        body: json.encode(citaData),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final citaJson = responseData is Map ? responseData['data'] : null;
        if (citaJson == null) return null;

        final nuevaCita = Cita.fromJson(citaJson);

        // Programar notificaciones y calendario
        try {
          await NotificationService().scheduleAdvancedAppointmentNotifications(nuevaCita);
        } catch (e) {
          debugPrint('Error al programar notificaciones: $e');
        }
        try {
          await AppointmentIntegrationService().processConfirmedAppointment(nuevaCita);
        } catch (e) {
          debugPrint('Error al agregar cita al calendario: $e');
        }

        return nuevaCita;
      } else {
        debugPrint('Error HTTP al crear cita: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Excepcion al crear cita: $e');
      return null;
    } finally {
      if (!kIsWeb) {
        client.close();
      }
    }
  }

  // Reagendar cita del usuario (fecha + hora + motivo)
  Future<Cita?> reagendarCita({
    required Cita cita,
    required DateTime nuevaFechaHora,
    required String motivo,
    int? idServicio,
  }) async {
    final client = _client();
    try {
      final payload = {
        'fecha_cita': nuevaFechaHora.toIso8601String().split('T')[0],
        'hora_inicio':
            '${nuevaFechaHora.hour.toString().padLeft(2, '0')}:${nuevaFechaHora.minute.toString().padLeft(2, '0')}',
        'hora_fin':
            '${(nuevaFechaHora.hour + 1).toString().padLeft(2, '0')}:${nuevaFechaHora.minute.toString().padLeft(2, '0')}',
        'motivo_reagendamiento': motivo,
        if (idServicio != null) 'id_servicio': idServicio,
      };

      final response = await client.put(
        Uri.parse('$baseUrl$citasEndpoint/user/${cita.id}/reagendar'),
        headers: await _authHeaders,
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final citaJson = responseData is Map ? responseData['data'] : null;
        if (citaJson == null) return null;

        final citaActualizada = Cita.fromJson(citaJson);

        // Reprogramar notificaciones
        await NotificationService().cancelAppointmentNotifications(cita.id.hashCode);
        await NotificationService().scheduleAdvancedAppointmentNotifications(citaActualizada);

        // Actualizar integraciones (calendario + notifs)
        try {
          await AppointmentIntegrationService()
              .updateAppointmentIntegrations(cita, citaActualizada);
        } catch (e) {
          debugPrint('Error al actualizar integraciones: $e');
        }

        return citaActualizada;
      } else {
        debugPrint('Error al reagendar: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error al reagendar: $e');
      return null;
    } finally {
      if (!kIsWeb) {
        client.close();
      }
    }
  }

  // Cancelar cita del usuario con motivo
  Future<bool> cancelarCita(Cita cita, String motivo) async {
    final client = _client();
    try {
      final response = await client.post(
        Uri.parse('$baseUrl$citasEndpoint/mis-citas/${cita.id}/cancelar'),
        headers: await _authHeaders,
        body: json.encode({'motivo_cancelacion': motivo}),
      );

      if (response.statusCode == 200) {
        await NotificationService().cancelAppointmentNotifications(cita.id.hashCode);
        try {
          await AppointmentIntegrationService()
              .cancelAppointmentIntegrations(int.tryParse(cita.id) ?? 0);
        } catch (e) {
          debugPrint('Error al cancelar integraciones: $e');
        }
        return true;
      } else {
        debugPrint('Error al cancelar cita: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error al cancelar cita: $e');
      return false;
    } finally {
      if (!kIsWeb) {
        client.close();
      }
    }
  }

  // Eliminar una cita (admin; no usar en app usuario)
  Future<bool> eliminarCita(String citaId) async {
    final client = _client();
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl$citasEndpoint/$citaId'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        debugPrint('Error al eliminar cita: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error al eliminar cita: $e');
      return false;
    } finally {
      if (!kIsWeb) {
        client.close();
      }
    }
  }

  // Obtener cita por ID (uso puntual)
  Future<Cita?> obtenerCitaPorId(String id) async {
    final client = _client();
    try {
      final response = await client.get(
        Uri.parse('$baseUrl$citasEndpoint/$id'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map && responseData.containsKey('data')) {
          final citaJson = responseData['data'];
          return Cita.fromJson(citaJson);
        } else {
          debugPrint('Formato de respuesta inesperado: $responseData');
          return null;
        }
      } else {
        debugPrint('Error al obtener cita: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error al obtener cita: $e');
      return null;
    } finally {
      if (!kIsWeb) {
        client.close();
      }
    }
  }

  // Obtener citas por fecha
  Future<List<Cita>> obtenerCitasPorFecha(DateTime fecha) async {
    final citas = await obtenerCitas();
    return citas.where((c) {
      return c.fechaHora.year == fecha.year &&
          c.fechaHora.month == fecha.month &&
          c.fechaHora.day == fecha.day;
    }).toList();
  }

  // Obtener citas CONFIRMADAS por fecha (para bloquear horarios en fallback)
  Future<List<Cita>> obtenerCitasConfirmadasPorFecha(DateTime fecha) async {
    try {
      final todasLasCitas = await obtenerCitas();
      final fechaString = fecha.toIso8601String().split('T')[0];

      return todasLasCitas.where((cita) {
        if (cita.estado != EstadoCita.confirmada) return false;
        final citaFechaString = cita.fechaHora.toIso8601String().split('T')[0];
        return citaFechaString == fechaString;
      }).toList();
    } catch (e) {
      debugPrint('Error al filtrar citas confirmadas: $e');
      return [];
    }
  }

  // Obtener horarios disponibles desde API (bloqueo servidor)
  Future<List<TimeOfDay>> obtenerHorariosDisponibles(DateTime fecha,
      {required int idServicio}) async {
    final client = _client();
    try {
      final query =
          '?fecha_cita=${fecha.toIso8601String().split('T')[0]}&id_servicio=$idServicio';
      final response = await client.get(
        Uri.parse('$baseUrl$misCitasEndpoint/horarios-disponibles$query'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic>? horarios =
            responseData is Map && responseData.containsKey('data')
                ? responseData['data'] as List<dynamic>?
                : (responseData is List ? responseData : null);

        if (horarios != null) {
          return horarios.map((h) {
            final parts = h.toString().split(':');
            final hour = int.tryParse(parts[0]) ?? 0;
            final minute = int.tryParse(parts[1]) ?? 0;
            return TimeOfDay(hour: hour, minute: minute);
          }).toList();
        }
      } else {
        debugPrint('Error al obtener horarios disponibles: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error al obtener horarios disponibles desde API: $e');
    } finally {
      if (!kIsWeb) {
        client.close();
      }
    }

    // Fallback a todos los horarios si hay error
    final List<TimeOfDay> todosHorarios = [];
    for (int hora = 8; hora <= 17; hora++) {
      todosHorarios.add(TimeOfDay(hour: hora, minute: 0));
      todosHorarios.add(TimeOfDay(hour: hora, minute: 30));
    }
    return todosHorarios;
  }

  // Obtener citas por estado
  Future<List<Cita>> obtenerCitasPorEstado(EstadoCita estado) async {
    final citas = await obtenerCitas();
    return citas.where((c) => c.estado == estado).toList();
  }

  // Obtener estadisticas
  Future<Map<EstadoCita, int>> obtenerEstadisticas() async {
    final citas = await obtenerCitas();
    return {
      EstadoCita.solicitada: citas.where((c) => c.estado == EstadoCita.solicitada).length,
      EstadoCita.confirmada: citas.where((c) => c.estado == EstadoCita.confirmada).length,
      EstadoCita.cancelada: citas.where((c) => c.estado == EstadoCita.cancelada).length,
      EstadoCita.completada: citas.where((c) => c.estado == EstadoCita.completada).length,
      EstadoCita.reprogramada: citas.where((c) => c.estado == EstadoCita.reprogramada).length,
    };
  }

  // Buscar citas
  Future<List<Cita>> buscarCitas(String query) async {
    if (query.isEmpty) {
      return await obtenerCitas();
    }

    final citas = await obtenerCitas();
    final queryLower = query.toLowerCase();

    return citas.where((c) {
      return c.nombreCompleto.toLowerCase().contains(queryLower) ||
          c.telefono.contains(queryLower) ||
          c.correo.toLowerCase().contains(queryLower) ||
          c.numeroDocumento.contains(queryLower) ||
          c.servicio.toLowerCase().contains(queryLower);
    }).toList();
  }

  // Cache offline
  Future<void> _saveCitasToCache(List<Cita> citas) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final citasJson = citas.map((cita) => cita.toJson()).toList();
      await prefs.setString('cached_citas', json.encode(citasJson));
      await prefs.setString('cache_timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error al guardar citas en cache: $e');
    }
  }

  Future<List<Cita>> _loadCitasFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_citas');
      if (cachedData != null) {
        final List<dynamic> citasJson = json.decode(cachedData);
        return citasJson.map((json) => Cita.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error al cargar citas desde cache: $e');
    }
    return [];
  }

  // Verificar conexion simple
  Future<bool> hasInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

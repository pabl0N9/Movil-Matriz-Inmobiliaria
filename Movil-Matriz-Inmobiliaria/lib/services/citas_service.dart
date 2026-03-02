import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cita_model.dart';

class CitasService {
  static const String _citasKey = 'citas_list';
  
  // Singleton pattern
  static final CitasService _instance = CitasService._internal();
  factory CitasService() => _instance;
  CitasService._internal();

  // Obtener todas las citas
  Future<List<Cita>> obtenerCitas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final citasJson = prefs.getString(_citasKey);
      
      if (citasJson == null || citasJson.isEmpty) {
        return [];
      }

      final List<dynamic> citasList = json.decode(citasJson);
      return citasList.map((json) => Cita.fromJson(json)).toList();
    } catch (e) {
      print('Error al obtener citas: $e');
      return [];
    }
  }

  // Guardar todas las citas
  Future<bool> guardarCitas(List<Cita> citas) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final citasJson = json.encode(citas.map((c) => c.toJson()).toList());
      return await prefs.setString(_citasKey, citasJson);
    } catch (e) {
      print('Error al guardar citas: $e');
      return false;
    }
  }

  // Crear una nueva cita
  Future<bool> crearCita(Cita cita) async {
    try {
      final citas = await obtenerCitas();
      citas.add(cita);
      return await guardarCitas(citas);
    } catch (e) {
      print('Error al crear cita: $e');
      return false;
    }
  }

  // Actualizar una cita existente
  Future<bool> actualizarCita(Cita citaActualizada) async {
    try {
      final citas = await obtenerCitas();
      final index = citas.indexWhere((c) => c.id == citaActualizada.id);
      
      if (index == -1) {
        return false;
      }

      citas[index] = citaActualizada;
      return await guardarCitas(citas);
    } catch (e) {
      print('Error al actualizar cita: $e');
      return false;
    }
  }

  // Eliminar una cita
  Future<bool> eliminarCita(String citaId) async {
    try {
      final citas = await obtenerCitas();
      citas.removeWhere((c) => c.id == citaId);
      return await guardarCitas(citas);
    } catch (e) {
      print('Error al eliminar cita: $e');
      return false;
    }
  }

  // Obtener cita por ID
  Future<Cita?> obtenerCitaPorId(String id) async {
    try {
      final citas = await obtenerCitas();
      return citas.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
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

  // Obtener citas por estado
  Future<List<Cita>> obtenerCitasPorEstado(EstadoCita estado) async {
    final citas = await obtenerCitas();
    return citas.where((c) => c.estado == estado).toList();
  }

  // Obtener estadísticas
  Future<Map<EstadoCita, int>> obtenerEstadisticas() async {
    final citas = await obtenerCitas();
    return {
      EstadoCita.programada: citas.where((c) => c.estado == EstadoCita.programada).length,
      EstadoCita.confirmada: citas.where((c) => c.estado == EstadoCita.confirmada).length,
      EstadoCita.completada: citas.where((c) => c.estado == EstadoCita.completada).length,
      EstadoCita.cancelada: citas.where((c) => c.estado == EstadoCita.cancelada).length,
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
}

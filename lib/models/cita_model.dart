import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum EstadoCita {
  solicitada,
  confirmada,
  cancelada,
  completada,
  reprogramada,
}

enum TipoDocumento {
  cedula,
  pasaporte,
  tarjetaIdentidad,
  registroCivil,
}

class Cita {
  final String id;
  final String nombreCompleto;
  final String telefono;
  final String correo;
  final TipoDocumento tipoDocumento;
  final String numeroDocumento;
  final DateTime fechaHora;
  final String servicio;
  final String? servicioNombre;
  final String detalles;
  EstadoCita estado;
  final DateTime fechaCreacion;
  final int? edicionesMaximas;
  final int? edicionesRealizadas;
  final String? inmuebleDireccion;

  // Informacion del agente asignado (solo para citas confirmadas)
  final String? agenteNombre;
  final String? agenteTelefono;
  final String? agenteCorreo;

  Cita({
    required this.id,
    required this.nombreCompleto,
    required this.telefono,
    required this.correo,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.fechaHora,
    required this.servicio,
    this.servicioNombre,
    required this.detalles,
    required this.estado,
    required this.fechaCreacion,
    this.edicionesMaximas,
    this.edicionesRealizadas,
    this.inmuebleDireccion,
    this.agenteNombre,
    this.agenteTelefono,
    this.agenteCorreo,
  });

  Cita copyWith({
    String? id,
    String? nombreCompleto,
    String? telefono,
    String? correo,
    TipoDocumento? tipoDocumento,
    String? numeroDocumento,
    DateTime? fechaHora,
    String? servicio,
    String? servicioNombre,
    String? detalles,
    EstadoCita? estado,
    DateTime? fechaCreacion,
    int? edicionesMaximas,
    int? edicionesRealizadas,
    String? inmuebleDireccion,
    String? agenteNombre,
    String? agenteTelefono,
    String? agenteCorreo,
  }) {
    return Cita(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      fechaHora: fechaHora ?? this.fechaHora,
      servicio: servicio ?? this.servicio,
      servicioNombre: servicioNombre ?? this.servicioNombre,
      detalles: detalles ?? this.detalles,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      edicionesMaximas: edicionesMaximas ?? this.edicionesMaximas,
      edicionesRealizadas: edicionesRealizadas ?? this.edicionesRealizadas,
      inmuebleDireccion: inmuebleDireccion ?? this.inmuebleDireccion,
      agenteNombre: agenteNombre ?? this.agenteNombre,
      agenteTelefono: agenteTelefono ?? this.agenteTelefono,
      agenteCorreo: agenteCorreo ?? this.agenteCorreo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreCompleto': nombreCompleto,
      'telefono': telefono,
      'correo': correo,
      'tipoDocumento': tipoDocumento.index,
      'numeroDocumento': numeroDocumento,
      'fechaHora': fechaHora.toIso8601String(),
      'servicio': servicio,
      'servicioNombre': servicioNombre,
      'detalles': detalles,
      'estado': estado.index,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'edicionesMaximas': edicionesMaximas,
      'edicionesRealizadas': edicionesRealizadas,
      'inmuebleDireccion': inmuebleDireccion,
    };
  }

  static TipoDocumento _tipoDocumentoFromApi(String? raw) {
    final upper = (raw ?? '').toUpperCase();
    switch (upper) {
      case 'CC':
      case 'CE':
        return TipoDocumento.cedula;
      case 'PASAPORTE':
        return TipoDocumento.pasaporte;
      case 'TI':
        return TipoDocumento.tarjetaIdentidad;
      case 'RC':
        return TipoDocumento.registroCivil;
      default:
        return TipoDocumento.cedula;
    }
  }

  static EstadoCita _estadoFromApi(dynamic rawEstado) {
    if (rawEstado is Map && rawEstado['id_estado_cita'] != null) {
      return _estadoFromApi(rawEstado['id_estado_cita']);
    }
    if (rawEstado is int) {
      switch (rawEstado) {
        case 1:
          return EstadoCita.solicitada;
        case 2:
        case 3:
          return EstadoCita.confirmada;
        case 4:
          return EstadoCita.reprogramada;
        case 5:
          return EstadoCita.completada;
        case 6:
          return EstadoCita.cancelada;
        default:
          return EstadoCita.solicitada;
      }
    }
    if (rawEstado is String) {
      final normalized = rawEstado.toLowerCase();
      if (normalized.contains('confirm')) return EstadoCita.confirmada;
      if (normalized.contains('cancel')) return EstadoCita.cancelada;
      if (normalized.contains('complet')) return EstadoCita.completada;
      if (normalized.contains('re') && normalized.contains('agen')) {
        return EstadoCita.reprogramada;
      }
      return EstadoCita.solicitada;
    }
    return EstadoCita.solicitada;
  }

  factory Cita.fromJson(Map<String, dynamic> json) {
    final id = json['id_cita']?.toString() ?? json['id']?.toString() ?? '';

    final cliente = json['cliente'] is Map ? json['cliente'] as Map<String, dynamic> : null;
    final primerNombre = cliente?['primer_nombre'] ?? '';
    final segundoNombre = cliente?['segundo_nombre'] ?? '';
    final primerApellido = cliente?['primer_apellido'] ?? '';
    final segundoApellido = cliente?['segundo_apellido'] ?? '';

    String nombreCompleto = '$primerNombre $segundoNombre $primerApellido $segundoApellido'.trim();
    if (nombreCompleto.isEmpty) {
      nombreCompleto =
          cliente?['nombre_completo'] ?? json['nombre_completo'] ?? json['nombreCompleto'] ?? '';
    }

    final telefono = cliente?['telefono'] ??
        json['telefono'] ??
        json['telefono_cliente'] ??
        json['telefono_contacto'] ??
        '';

    final correo = cliente?['correo'] ?? json['correo'] ?? json['email'] ?? '';

    final numeroDocumento =
        cliente?['numero_documento'] ?? json['numero_documento'] ?? json['numeroDocumento'] ?? '';

    final tipoDocumento = _tipoDocumentoFromApi(
      cliente?['tipo_documento'] ?? json['tipo_documento'] ?? json['tipoDocumento'],
    );

    DateTime fechaHora;
    try {
      if (json['fecha_cita'] != null && json['hora_inicio'] != null) {
        final fecha = json['fecha_cita'].toString();
        final hora = json['hora_inicio'].toString();
        if (hora.contains('T')) {
          final horaPart = hora.split('T')[1].split('.')[0];
          fechaHora = DateTime.parse('$fecha $horaPart');
        } else {
          fechaHora = DateTime.parse('$fecha $hora');
        }
      } else if (json['fechaHora'] != null) {
        fechaHora = DateTime.parse(json['fechaHora']);
      } else {
        fechaHora = DateTime.now();
      }
    } catch (_) {
      fechaHora = DateTime.now();
    }

    String? servicioNombre;
    String servicio;
    if (json['servicio'] is Map) {
      servicioNombre =
          json['servicio']['nombre_servicio'] ?? json['servicio']['nombre'] ?? json['servicio']['servicio'];
      servicio = servicioNombre ?? json['servicio'].toString();
    } else {
      servicio = json['servicio']?.toString() ?? 'Servicio';
    }

    final detalles = json['observaciones'] ?? json['detalles'] ?? '';

    final estado = _estadoFromApi(json['estado'] ?? json['id_estado_cita']);

    final fechaCreacion = DateTime.tryParse(
          json['fecha_creacion']?.toString() ?? json['fechaCreacion']?.toString() ?? '',
        ) ??
        DateTime.now();

    final edMax = json['ediciones_maximas'] ?? json['edicionesMaximas'];
    final edUsed = json['ediciones_realizadas'] ?? json['edicionesRealizadas'];

    final inmuebleDireccion = json['inmueble']?['direccion'] ?? json['direccion_inmueble'];

    final agente = json['agente'] is Map ? json['agente'] as Map<String, dynamic> : null;
    final agenteNombre = agente?['nombre_completo'] ??
        agente?['primer_nombre'] ??
        (agente != null
            ? '${agente['nombre'] ?? ''} ${agente['apellido'] ?? ''}'.trim()
            : null);

    return Cita(
      id: id,
      nombreCompleto: nombreCompleto,
      telefono: telefono,
      correo: correo,
      tipoDocumento: tipoDocumento,
      numeroDocumento: numeroDocumento,
      fechaHora: fechaHora,
      servicio: servicio,
      servicioNombre: servicioNombre,
      detalles: detalles,
      estado: estado,
      fechaCreacion: fechaCreacion,
      edicionesMaximas: edMax is int ? edMax : int.tryParse(edMax?.toString() ?? ''),
      edicionesRealizadas: edUsed is int ? edUsed : int.tryParse(edUsed?.toString() ?? ''),
      inmuebleDireccion: inmuebleDireccion,
      agenteNombre: (agenteNombre ?? '').trim().isEmpty ? null : agenteNombre,
      agenteTelefono: agente?['telefono'],
      agenteCorreo: agente?['correo'],
    );
  }

  String get tipoDocumentoTexto {
    switch (tipoDocumento) {
      case TipoDocumento.cedula:
        return 'Cedula';
      case TipoDocumento.pasaporte:
        return 'Pasaporte';
      case TipoDocumento.tarjetaIdentidad:
        return 'Tarjeta de Identidad';
      case TipoDocumento.registroCivil:
        return 'Registro Civil';
    }
  }

  String get estadoTexto {
    switch (estado) {
      case EstadoCita.solicitada:
        return 'Solicitada';
      case EstadoCita.confirmada:
        return 'Confirmada';
      case EstadoCita.cancelada:
        return 'Cancelada';
      case EstadoCita.completada:
        return 'Completada';
      case EstadoCita.reprogramada:
        return 'Reagendada';
    }
  }

  Color get estadoColor {
    switch (estado) {
      case EstadoCita.solicitada:
        return const Color(0xFF6366F1);
      case EstadoCita.confirmada:
        return const Color(0xFF10B981);
      case EstadoCita.cancelada:
        return const Color(0xFFEF4444);
      case EstadoCita.completada:
        return const Color(0xFF8B5CF6);
      case EstadoCita.reprogramada:
        return const Color(0xFFF97316);
    }
  }
}

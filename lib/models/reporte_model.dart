import 'package:flutter/material.dart';

/// Enum que representa los diferentes estados de un reporte
enum EstadoReporte {
  pendiente,
  enProgreso,
  finalizado,
  urgente,
}

/// Extensión para obtener información visual y textual de los estados
extension EstadoReporteExtension on EstadoReporte {
  /// Retorna el nombre legible del estado
  String get nombre {
    switch (this) {
      case EstadoReporte.pendiente:
        return 'Pendiente';
      case EstadoReporte.enProgreso:
        return 'En progreso';
      case EstadoReporte.finalizado:
        return 'Finalizado';
      case EstadoReporte.urgente:
        return 'Urgente';
    }
  }

  /// Retorna el color asociado al estado
  Color get color {
    switch (this) {
      case EstadoReporte.pendiente:
        return Colors.orange;
      case EstadoReporte.enProgreso:
        return const Color(0xFF0A4B84); // Azul corporativo
      case EstadoReporte.finalizado:
        return Colors.green;
      case EstadoReporte.urgente:
        return Colors.red;
    }
  }

  /// Retorna el icono asociado al estado
  IconData get icono {
    switch (this) {
      case EstadoReporte.pendiente:
        return Icons.pending_outlined;
      case EstadoReporte.enProgreso:
        return Icons.autorenew;
      case EstadoReporte.finalizado:
        return Icons.check_circle_outline;
      case EstadoReporte.urgente:
        return Icons.warning_amber_outlined;
    }
  }

  /// Convierte el enum a String para JSON
  String toJson() => name;

  /// Crea un EstadoReporte desde un String
  static EstadoReporte fromString(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return EstadoReporte.pendiente;
      case 'en progreso':
      case 'enprogreso':
        return EstadoReporte.enProgreso;
      case 'finalizado':
        return EstadoReporte.finalizado;
      case 'urgente':
        return EstadoReporte.urgente;
      default:
        return EstadoReporte.pendiente;
    }
  }
}

/// Modelo que representa un seguimiento dentro de un rubro
class SeguimientoRubro {
  final String id;
  final String tipo;
  final String responsable;
  final DateTime fecha;
  final int subSeguimientos;
  final String estado;
  final String descripcion;

  SeguimientoRubro({
    required this.id,
    required this.tipo,
    required this.responsable,
    required this.fecha,
    required this.subSeguimientos,
    required this.estado,
    required this.descripcion,
  });

  /// Crea una instancia desde JSON
  factory SeguimientoRubro.fromJson(Map<String, dynamic> json) {
    return SeguimientoRubro(
      id: json['id'] ?? '',
      tipo: json['tipo'] ?? '',
      responsable: json['responsable'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      subSeguimientos: json['subSeguimientos'] ?? 0,
      estado: json['estado'] ?? '',
      descripcion: json['descripcion'] ?? '',
    );
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'responsable': responsable,
      'fecha': fecha.toIso8601String(),
      'subSeguimientos': subSeguimientos,
      'estado': estado,
      'descripcion': descripcion,
    };
  }
}

/// Modelo que representa un rubro dentro de un reporte
class RubroReporte {
  final String id;
  final String nombre;
  final bool activo;
  final double valorTotal;
  final List<SeguimientoRubro> seguimientos;

  RubroReporte({
    required this.id,
    required this.nombre,
    required this.activo,
    required this.valorTotal,
    required this.seguimientos,
  });

  /// Crea una instancia desde JSON
  factory RubroReporte.fromJson(Map<String, dynamic> json) {
    return RubroReporte(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      activo: json['activo'] ?? true,
      valorTotal: (json['valorTotal'] ?? 0).toDouble(),
      seguimientos: (json['seguimientos'] as List<dynamic>?)
              ?.map((s) => SeguimientoRubro.fromJson(s))
              .toList() ??
          [],
    );
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'activo': activo,
      'valorTotal': valorTotal,
      'seguimientos': seguimientos.map((s) => s.toJson()).toList(),
    };
  }
}

/// Modelo que representa un seguimiento en el historial general
class SeguimientoHistorial {
  final String id;
  final String estado;
  final String responsable;
  final DateTime fecha;
  final String descripcion;

  SeguimientoHistorial({
    required this.id,
    required this.estado,
    required this.responsable,
    required this.fecha,
    required this.descripcion,
  });

  /// Crea una instancia desde JSON
  factory SeguimientoHistorial.fromJson(Map<String, dynamic> json) {
    return SeguimientoHistorial(
      id: json['id'] ?? '',
      estado: json['estado'] ?? '',
      responsable: json['responsable'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      descripcion: json['descripcion'] ?? '',
    );
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estado': estado,
      'responsable': responsable,
      'fecha': fecha.toIso8601String(),
      'descripcion': descripcion,
    };
  }
}

/// Modelo principal que representa un reporte completo
class Reporte {
  final String id;
  final String ubicacion;
  final String tipoInmueble;
  final String propietario;
  final String tipoReporte;
  final DateTime fecha;
  final EstadoReporte estado;
  final String responsable;
  final String referencia;
  final String descripcion;
  final String seguimientoGeneral;
  final int? idPersonaReporta;
  final List<RubroReporte> rubros;
  final List<String> imagenes;
  final List<String> archivos;
  final List<SeguimientoHistorial> seguimientos;

  Reporte({
    required this.id,
    required this.ubicacion,
    required this.tipoInmueble,
    required this.propietario,
    required this.tipoReporte,
    required this.fecha,
    required this.estado,
    required this.responsable,
    required this.referencia,
    required this.descripcion,
    required this.seguimientoGeneral,
    this.idPersonaReporta,
    required this.rubros,
    required this.imagenes,
    required this.archivos,
    required this.seguimientos,
  });

  /// Crea una instancia desde JSON
  factory Reporte.fromJson(Map<String, dynamic> json) {
    return Reporte(
      id: (json['id_reporte'] ?? json['id'] ?? '').toString(),
      ubicacion: json['inmueble_direccion'] ?? json['ubicacion'] ?? '',
      tipoInmueble: json['inmueble_categoria'] ?? json['tipoInmueble'] ?? '',
      propietario: json['propietario_nombre'] ?? json['propietario'] ?? '',
      tipoReporte: json['tipo_reporte'] ?? json['tipoReporte'] ?? '',
      fecha: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : (json['fecha'] != null
              ? DateTime.parse(json['fecha'])
              : DateTime.now()),
      estado: EstadoReporteExtension.fromString(json['estado'] ?? 'Pendiente'),
      responsable: json['reporta_nombre'] ?? json['responsable'] ?? '',
      referencia: json['inmueble_referencia'] ?? json['referencia'] ?? '',
      descripcion: json['descripcion'] ?? '',
      seguimientoGeneral:
          json['seguimiento_general'] ?? json['seguimientoGeneral'] ?? '',
      idPersonaReporta: json['id_persona_reporta'] ?? json['idPersonaReporta'],
      rubros: (json['rubros'] as List<dynamic>?)
              ?.map((r) => RubroReporte.fromJson(r))
              .toList() ??
          [],
      imagenes: (json['imagenes'] as List<dynamic>?)?.cast<String>() ?? [],
      archivos: (json['archivos'] as List<dynamic>?)?.cast<String>() ?? [],
      seguimientos: (json['seguimientosGenerales'] as List<dynamic>?)
              ?.map((s) => SeguimientoHistorial.fromJson(s))
              .toList() ??
          (json['seguimientos'] as List<dynamic>?)
              ?.map((s) => SeguimientoHistorial.fromJson(s))
              .toList() ??
          [],
    );
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ubicacion': ubicacion,
      'tipoInmueble': tipoInmueble,
      'propietario': propietario,
      'tipoReporte': tipoReporte,
      'fecha': fecha.toIso8601String(),
      'estado': estado.nombre,
      'responsable': responsable,
      'referencia': referencia,
      'descripcion': descripcion,
      'seguimientoGeneral': seguimientoGeneral,
      'idPersonaReporta': idPersonaReporta,
      'rubros': rubros.map((r) => r.toJson()).toList(),
      'imagenes': imagenes,
      'archivos': archivos,
      'seguimientos': seguimientos.map((s) => s.toJson()).toList(),
    };
  }

  /// Calcula el total de seguimientos (rubros + historial)
  int get totalSeguimientos {
    final seguimientosRubros =
        rubros.fold<int>(0, (sum, rubro) => sum + rubro.seguimientos.length);
    return seguimientosRubros + seguimientos.length;
  }

  /// Calcula el progreso del reporte (porcentaje de seguimientos finalizados)
  double get progreso {
    if (totalSeguimientos == 0) return 0.0;

    final seguimientosFinalizados = rubros.fold<int>(
          0,
          (sum, rubro) =>
              sum +
              rubro.seguimientos
                  .where((s) => s.estado.toLowerCase() == 'finalizado')
                  .length,
        ) +
        seguimientos
            .where((s) => s.estado.toLowerCase() == 'finalizado')
            .length;

    return (seguimientosFinalizados / totalSeguimientos) * 100;
  }

  /// Copia el reporte con valores modificados
  Reporte copyWith({
    String? id,
    String? ubicacion,
    String? tipoInmueble,
    String? propietario,
    String? tipoReporte,
    DateTime? fecha,
    EstadoReporte? estado,
    String? responsable,
    String? referencia,
    String? descripcion,
    String? seguimientoGeneral,
    int? idPersonaReporta,
    List<RubroReporte>? rubros,
    List<String>? imagenes,
    List<String>? archivos,
    List<SeguimientoHistorial>? seguimientos,
  }) {
    return Reporte(
      id: id ?? this.id,
      ubicacion: ubicacion ?? this.ubicacion,
      tipoInmueble: tipoInmueble ?? this.tipoInmueble,
      propietario: propietario ?? this.propietario,
      tipoReporte: tipoReporte ?? this.tipoReporte,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
      responsable: responsable ?? this.responsable,
      referencia: referencia ?? this.referencia,
      descripcion: descripcion ?? this.descripcion,
      seguimientoGeneral: seguimientoGeneral ?? this.seguimientoGeneral,
      idPersonaReporta: idPersonaReporta ?? this.idPersonaReporta,
      rubros: rubros ?? this.rubros,
      imagenes: imagenes ?? this.imagenes,
      archivos: archivos ?? this.archivos,
      seguimientos: seguimientos ?? this.seguimientos,
    );
  }
}

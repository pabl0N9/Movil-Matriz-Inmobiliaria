import 'dart:convert';
import 'package:flutter/material.dart';

enum EstadoCita {
  programada,
  confirmada,
  completada,
  cancelada,
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
  final String detalles;
  EstadoCita estado;
  final DateTime fechaCreacion;

  Cita({
    required this.id,
    required this.nombreCompleto,
    required this.telefono,
    required this.correo,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.fechaHora,
    required this.servicio,
    required this.detalles,
    required this.estado,
    required this.fechaCreacion,
  });

  // Convertir a JSON
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
      'detalles': detalles,
      'estado': estado.index,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  // Crear desde JSON
  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'],
      nombreCompleto: json['nombreCompleto'],
      telefono: json['telefono'],
      correo: json['correo'],
      tipoDocumento: TipoDocumento.values[json['tipoDocumento']],
      numeroDocumento: json['numeroDocumento'],
      fechaHora: DateTime.parse(json['fechaHora']),
      servicio: json['servicio'],
      detalles: json['detalles'],
      estado: EstadoCita.values[json['estado']],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }

  // Copiar con modificaciones
  Cita copyWith({
    String? id,
    String? nombreCompleto,
    String? telefono,
    String? correo,
    TipoDocumento? tipoDocumento,
    String? numeroDocumento,
    DateTime? fechaHora,
    String? servicio,
    String? detalles,
    EstadoCita? estado,
    DateTime? fechaCreacion,
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
      detalles: detalles ?? this.detalles,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  // Helpers para obtener texto legible
  String get tipoDocumentoTexto {
    switch (tipoDocumento) {
      case TipoDocumento.cedula:
        return 'Cédula';
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
      case EstadoCita.programada:
        return 'Programada';
      case EstadoCita.confirmada:
        return 'Confirmada';
      case EstadoCita.completada:
        return 'Completada';
      case EstadoCita.cancelada:
        return 'Cancelada';
    }
  }

  Color get estadoColor {
    switch (estado) {
      case EstadoCita.programada:
        return const Color(0xFFFFA726); // Naranja
      case EstadoCita.confirmada:
        return const Color(0xFF42A5F5); // Azul
      case EstadoCita.completada:
        return const Color(0xFF66BB6A); // Verde
      case EstadoCita.cancelada:
        return const Color(0xFFEF5350); // Rojo
    }
  }
}

class Seguimiento {
  final String id;
  final DateTime fecha;
  final String estado;
  final String descripcion;

  // Estados válidos
  static const List<String> estadosValidos = ['Pendiente', 'En proceso', 'Completado'];

  Seguimiento({
    required this.id,
    required this.fecha,
    required this.estado,
    required this.descripcion,
  }) : assert(estadosValidos.contains(estado), 'Estado no válido: $estado');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'estado': estado,
      'descripcion': descripcion,
    };
  }

  factory Seguimiento.fromMap(Map<String, dynamic> map) {
    return Seguimiento(
      id: map['id'] ?? '',
      fecha: DateTime.parse(map['fecha'] ?? DateTime.now().toIso8601String()),
      estado: map['estado'] ?? 'Pendiente',
      descripcion: map['descripcion'] ?? '',
    );
  }
}

class RubroProyecto {
  final String id;
  final String nombre;
  final String estado;
  final String descripcion;
  final List<Seguimiento> listaSeguimientos;

  RubroProyecto({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.descripcion,
    this.listaSeguimientos = const [],
  });

  // Getter para obtener el número de seguimientos
  int get cantidadSeguimientos => listaSeguimientos.length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'estado': estado,
      'descripcion': descripcion,
      'listaSeguimientos': listaSeguimientos.map((s) => s.toMap()).toList(),
    };
  }
  
  factory RubroProyecto.fromMap(Map<String, dynamic> map) {
    return RubroProyecto(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      estado: map['estado'] ?? 'Pendiente',
      descripcion: map['descripcion'] ?? '',
      listaSeguimientos: (map['listaSeguimientos'] as List<dynamic>?)
          ?.map((s) => Seguimiento.fromMap(s as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  RubroProyecto copyWith({
    String? id,
    String? nombre,
    String? estado,
    String? descripcion,
    List<Seguimiento>? listaSeguimientos,
  }) {
    return RubroProyecto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      estado: estado ?? this.estado,
      descripcion: descripcion ?? this.descripcion,
      listaSeguimientos: listaSeguimientos ?? this.listaSeguimientos,
    );
  }
}

class Reporte {
  final String id;
  final String ubicacion;
  final String tipoInmueble;
  final String referencia;
  final String titulo;
  final String descripcion;
  final String estado;
  final String responsable;
  final List<RubroProyecto> rubros;
  final List<String> archivos;
  final DateTime fechaCreacion;

  Reporte({
    required this.id,
    required this.ubicacion,
    required this.tipoInmueble,
    required this.referencia,
    required this.titulo,
    required this.descripcion,
    required this.estado,
    required this.responsable,
    required this.rubros,
    required this.archivos,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  // Getters para estadísticas
  int get rubrosCompletados => rubros.where((r) => r.estado == 'Completado').length;
  int get rubrosPendientes => rubros.where((r) => r.estado == 'Pendiente').length;
  int get rubrosEnProceso => rubros.where((r) => r.estado == 'En proceso').length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ubicacion': ubicacion,
      'tipoInmueble': tipoInmueble,
      'referencia': referencia,
      'titulo': titulo,
      'descripcion': descripcion,
      'estado': estado,
      'responsable': responsable,
      'rubros': rubros.map((r) => r.toMap()).toList(),
      'archivos': archivos,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Reporte.fromMap(Map<String, dynamic> map) {
    return Reporte(
      id: map['id'] ?? '',
      ubicacion: map['ubicacion'] ?? '',
      tipoInmueble: map['tipoInmueble'] ?? '',
      referencia: map['referencia'] ?? '',
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      estado: map['estado'] ?? 'Pendiente',
      responsable: map['responsable'] ?? '',
      rubros: (map['rubros'] as List<dynamic>?)
          ?.map((r) => RubroProyecto.fromMap(r as Map<String, dynamic>))
          .toList() ?? [],
      archivos: List<String>.from(map['archivos'] ?? []),
      fechaCreacion: map['fechaCreacion'] != null 
          ? DateTime.parse(map['fechaCreacion'])
          : DateTime.now(),
    );
  }

  Reporte copyWith({
    String? id,
    String? ubicacion,
    String? tipoInmueble,
    String? referencia,
    String? titulo,
    String? descripcion,
    String? estado,
    String? responsable,
    List<RubroProyecto>? rubros,
    List<String>? archivos,
    DateTime? fechaCreacion,
  }) {
    return Reporte(
      id: id ?? this.id,
      ubicacion: ubicacion ?? this.ubicacion,
      tipoInmueble: tipoInmueble ?? this.tipoInmueble,
      referencia: referencia ?? this.referencia,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      responsable: responsable ?? this.responsable,
      rubros: rubros ?? this.rubros,
      archivos: archivos ?? this.archivos,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}
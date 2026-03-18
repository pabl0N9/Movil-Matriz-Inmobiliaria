class Inmueble {
  final int idInmueble;
  final String registroInmobiliario;
  final String? titulo;
  final String direccion;
  final String ciudad;
  final String departamento;
  final String pais;
  final String? barrio;
  final String? categoria;
  final double? precioVenta;
  final double? precioArriendo;
  final double? areaConstruida;
  final double? areaTerreno;
  final String? descripcion;
  final String operacion;
  final bool estado;
  final String estadoFrontend;
  final List<String> imagenes;

  Inmueble({
    required this.idInmueble,
    required this.registroInmobiliario,
    this.titulo,
    required this.direccion,
    required this.ciudad,
    required this.departamento,
    required this.pais,
    this.barrio,
    this.categoria,
    this.precioVenta,
    this.precioArriendo,
    this.areaConstruida,
    this.areaTerreno,
    this.descripcion,
    this.operacion = 'Venta',
    this.estado = true,
    this.estadoFrontend = 'Disponible',
    this.imagenes = const [],
  });

  factory Inmueble.fromJson(Map<String, dynamic> json) {
    // Parse images - API returns a flat list of URL strings
    List<String> imagenes = [];
    if (json['imagenes'] != null && json['imagenes'] is List) {
      imagenes = (json['imagenes'] as List)
          .map((img) => img?.toString() ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    }

    return Inmueble(
      idInmueble: json['id_inmueble'] ?? 0,
      registroInmobiliario: json['registro_inmobiliario'] ?? '',
      titulo: json['titulo'],
      direccion: json['direccion'] ?? '',
      ciudad: json['ciudad'] ?? '',
      departamento: json['departamento'] ?? '',
      pais: json['pais'] ?? '',
      barrio: json['barrio'],
      categoria: json['categoria'],
      precioVenta: _parseDouble(json['precio_venta']),
      precioArriendo: _parseDouble(json['precio_arriendo']),
      areaConstruida: _parseDouble(json['area_construida']),
      areaTerreno: _parseDouble(json['area_terreno']),
      descripcion: json['descripcion'],
      operacion: json['operacion'] ?? 'Venta',
      estado: json['estado'] == true ||
          json['estado'] == 1 ||
          json['estado'] == '1',
      estadoFrontend: json['estado_frontend'] ?? 'Disponible',
      imagenes: imagenes,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Display name for the property
  String get displayName {
    if (titulo != null && titulo!.isNotEmpty) return titulo!;
    return registroInmobiliario;
  }

  /// First image URL or null
  String? get imagenPrincipal => imagenes.isNotEmpty ? imagenes.first : null;
}

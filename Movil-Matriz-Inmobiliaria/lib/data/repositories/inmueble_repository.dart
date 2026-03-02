import 'dart:convert';

import 'package:flutter_citas_app/core/config/app_config.dart';
import 'package:flutter_citas_app/core/network/http_client_factory.dart';
import 'package:flutter_citas_app/core/session/auth_session.dart';
import 'package:flutter_citas_app/data/models/inmueble_model.dart';
import 'package:http/http.dart' as http;

class InmuebleRepository {
  static Future<List<Inmueble>> getForCurrentOwner() async {
    final session = await AuthSession.load();
    final ownerId = session.userId;
    final token = session.token;

    final attempts = _buildCandidateUris(ownerId);
    http.Response? successResponse;
    int? lastStatus;

    for (final uri in attempts) {
      final response = await _requestWithAuthFallback(uri, token);
      lastStatus = response.statusCode;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        successResponse = response;
        break;
      }
    }

    if (successResponse == null) {
      throw Exception('No se pudieron cargar inmuebles (${lastStatus ?? 0})');
    }

    final body = _decodeBody(successResponse.body);
    final items = _extractItems(body);
    final inmuebles = items.map(_toInmueble).toList();

    if (ownerId == null) {
      return inmuebles;
    }

    final hasOwnerInPayload = inmuebles.any((item) => item.ownerId != null);
    if (!hasOwnerInPayload) {
      return inmuebles;
    }

    return inmuebles.where((item) => item.ownerId == ownerId).toList();
  }

  static Future<http.Response> _requestWithAuthFallback(
    Uri uri,
    String? token,
  ) async {
    final normalizedToken = token?.trim();
    final rawToken =
        (normalizedToken != null && normalizedToken.startsWith('Bearer '))
            ? normalizedToken.substring(7).trim()
            : normalizedToken;

    final headerVariants = <Map<String, String>>[
      {
        if (rawToken != null && rawToken.isNotEmpty)
          'Authorization': 'Bearer $rawToken',
      },
      {
        if (rawToken != null && rawToken.isNotEmpty) 'Authorization': rawToken,
      },
      const {},
    ];

    http.Response? fallback;
    for (final headers in headerVariants) {
      final response =
          await HttpClientFactory.client.get(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      fallback ??= response;
    }
    return fallback ?? http.Response('{}', 500);
  }

  static List<Uri> _buildCandidateUris(int? ownerId) {
    final base = AppConfig.propertiesUri;
    final list = <Uri>[];

    void add(Uri uri) {
      if (!list.any((item) => item.toString() == uri.toString())) {
        list.add(uri);
      }
    }

    if (ownerId != null) {
      final withQuery = _withOwnerQuery(base, ownerId);
      add(withQuery);
    }
    add(base);

    final explicitOwner = AppConfig.ownerPropertiesUri;
    if (explicitOwner != null) {
      add(_replaceOwnerId(explicitOwner, ownerId));
    }

    if (ownerId != null) {
      add(base.replace(path: '${base.path}/propietario/$ownerId'));
      add(base.replace(path: '/api/v1/propietarios/$ownerId/inmuebles'));
      add(base.replace(path: '/api/v1/auth/mobile/inmuebles'));
      add(base.replace(path: '/api/v1/auth/mobile/inmuebles/$ownerId'));
    } else {
      add(base.replace(path: '/api/v1/auth/mobile/inmuebles'));
    }

    return list;
  }

  static Uri _withOwnerQuery(Uri base, int ownerId) {
    final currentQuery = Map<String, String>.from(base.queryParameters);
    currentQuery.putIfAbsent(
      AppConfig.propertiesOwnerQueryKey,
      () => ownerId.toString(),
    );
    return base.replace(queryParameters: currentQuery);
  }

  static Uri _replaceOwnerId(Uri uri, int? ownerId) {
    final asString = uri.toString();
    if (ownerId == null) {
      return uri;
    }
    if (asString.contains('{ownerId}')) {
      return Uri.parse(asString.replaceAll('{ownerId}', ownerId.toString()));
    }
    return uri;
  }

  static dynamic _decodeBody(String raw) {
    final sanitized = raw.trim().replaceFirst('\uFEFF', '');
    if (sanitized.isEmpty) return <String, dynamic>{};
    return jsonDecode(sanitized);
  }

  static List<Map<String, dynamic>> _extractItems(dynamic body) {
    if (body is List) {
      return body
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (body is Map) {
      final root = Map<String, dynamic>.from(body);
      final candidates = [
        root['inmuebles'],
        root['propiedades'],
        root['items'],
        root['results'],
        root['data'],
        (root['data'] is Map) ? (root['data'] as Map)['inmuebles'] : null,
        (root['data'] is Map) ? (root['data'] as Map)['propiedades'] : null,
        (root['data'] is Map) ? (root['data'] as Map)['items'] : null,
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }

    return const [];
  }

  static Inmueble _toInmueble(Map<String, dynamic> map) {
    final id = _firstString(map, const ['id', 'id_inmueble', 'inmueble_id']) ??
        DateTime.now().microsecondsSinceEpoch.toString();

    final title = _firstString(map, const [
          'titulo',
          'nombre',
          'nombre_inmueble',
          'tipo_inmueble',
          'descripcion',
        ]) ??
        'Inmueble';

    final location = _firstString(map, const [
          'ubicacion',
          'direccion',
          'direccion_completa',
          'ciudad',
          'barrio',
        ]) ??
        'Ubicacion no disponible';

    final priceValue =
        _firstString(map, const ['precio', 'valor', 'canon', 'renta']);

    final code = _firstString(map, const [
          'codigo',
          'codigo_inmueble',
          'registro',
          'referencia',
          'consecutivo',
        ]) ??
        id;

    String? salePrice = _firstString(map, const [
      'precio_venta',
      'valor_venta',
      'venta',
      'precioVenta',
      'valorVenta',
    ]);

    String? rentPrice = _firstString(map, const [
      'canon_arriendo',
      'valor_arriendo',
      'precio_arriendo',
      'arriendo',
      'renta',
      'canon',
      'canon_esperado',
      'canonEsperado',
    ]);

    var operation = (_firstString(map, const [
              'operacion',
              'tipo_operacion',
              'tipoOperacion',
              'negocio',
              'tipo_negocio',
              'modalidad',
            ]) ??
            '')
        .trim()
        .toLowerCase();

    final hasSaleHints = operation.contains('venta');
    final hasRentHints =
        operation.contains('arriendo') || operation.contains('arrend');

    if (salePrice == null && rentPrice == null && priceValue != null) {
      if (hasSaleHints && !hasRentHints) {
        salePrice = priceValue;
      } else if (hasRentHints && !hasSaleHints) {
        rentPrice = priceValue;
      } else {
        rentPrice = priceValue;
      }
    }

    if (operation.isEmpty || operation == 'null') {
      if (salePrice != null && rentPrice != null) {
        operation = 'venta y arriendo';
      } else if (salePrice != null) {
        operation = 'venta';
      } else if (rentPrice != null) {
        operation = 'arriendo';
      }
    }

    if (salePrice == null &&
        operation.contains('venta') &&
        !operation.contains('arriendo') &&
        priceValue != null) {
      salePrice = priceValue;
    }

    if (rentPrice == null &&
        (operation.contains('arriendo') || operation.contains('arrend')) &&
        !operation.contains('venta') &&
        priceValue != null) {
      rentPrice = priceValue;
    }

    final price = salePrice != null
        ? '\$$salePrice'
        : rentPrice != null
            ? '\$$rentPrice'
            : 'Sin precio';

    final status = _firstString(map, const [
          'estado',
          'estado_inmueble',
          'estadoInmueble',
          'situacion',
        ]) ??
        'Disponible';

    final area =
        _firstString(map, const ['area', 'metros', 'm2', 'metros_cuadrados']) ??
            '-';
    final rooms =
        _firstString(map, const ['habitaciones', 'cuartos', 'dormitorios']) ??
            '-';
    final baths =
        _firstString(map, const ['banos', 'banios', 'baths', 'bathrooms']) ??
            '-';

    final image = _firstString(map, const [
          'imagen',
          'image',
          'foto_url',
          'url_imagen',
          'foto',
        ]) ??
        'assets/images/casa1.jpg';

    final featured = _firstBool(map, const ['destacado', 'featured']) ?? false;
    final ownerId = _firstInt(map, const [
      'propietario_id',
      'id_propietario',
      'persona_propietario_id',
      'id_persona_propietario',
      'owner_id',
      'user_id',
      'id_usuario',
      'id_persona',
      'usuario_id',
      'propietario.id',
      'propietario.id_persona',
      'owner.id',
      'usuario.id',
      'usuario.id_persona',
      'data.propietario.id',
      'data.propietario.id_persona',
    ]);

    return Inmueble(
      id: id,
      imagePath: image,
      title: title,
      code: code,
      location: location,
      operation: operation,
      status: status,
      salePrice: salePrice,
      rentPrice: rentPrice,
      price: price,
      area: area,
      rooms: rooms,
      baths: baths,
      featured: featured,
      ownerId: ownerId,
    );
  }

  static String? _firstString(Map<String, dynamic> map, List<String> paths) {
    for (final path in paths) {
      final value = _readPath(map, path);
      if (value == null) continue;
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is num) return value.toString();
    }
    return null;
  }

  static int? _firstInt(Map<String, dynamic> map, List<String> paths) {
    for (final path in paths) {
      final value = _readPath(map, path);
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static bool? _firstBool(Map<String, dynamic> map, List<String> paths) {
    for (final path in paths) {
      final value = _readPath(map, path);
      if (value is bool) return value;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1') return true;
        if (normalized == 'false' || normalized == '0') return false;
      }
      if (value is num) return value != 0;
    }
    return null;
  }

  static dynamic _readPath(Map<String, dynamic> map, String path) {
    dynamic current = map;
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

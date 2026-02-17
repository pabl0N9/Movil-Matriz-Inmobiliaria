import '../models/reporte_model.dart';

/// Servicio para gestionar los reportes del propietario
/// Actualmente utiliza datos simulados, pero está preparado para integración con API REST
class ReportesService {
  // Simulación de delay de red
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Obtiene todos los reportes del propietario actual
  /// En producción, este método haría una petición GET al backend
  Future<List<Reporte>> obtenerReportes() async {
    await _simulateNetworkDelay();

    // Datos de ejemplo basados en OwnerReportsPage.jsx
    return [
      Reporte(
        id: 'R-001',
        ubicacion: 'Medellín, Laureles',
        tipoInmueble: 'Apartamento',
        propietario: 'Dario Jaramillo',
        tipoReporte: 'Reparación baño',
        fecha: DateTime(2025, 5, 20),
        estado: EstadoReporte.enProgreso,
        responsable: 'Juan Pérez',
        referencia: 'AP-9012',
        descripcion:
            'Filtración en el baño principal que requiere revisión y reparación del sello.',
        seguimientoGeneral:
            'Se ha iniciado la evaluación del daño. Pendiente cotización de materiales.',
        rubros: [
          RubroReporte(
            id: 'RB-1',
            nombre: 'Fontanería',
            activo: true,
            valorTotal: 250000,
            seguimientos: [
              SeguimientoRubro(
                id: 'SEG-1',
                tipo: 'Revisión',
                responsable: 'Juan Pérez',
                fecha: DateTime(2025, 5, 21),
                subSeguimientos: 2,
                estado: 'En progreso',
                descripcion:
                    'Primera revisión realizada, detectado sello deteriorado.',
              ),
              SeguimientoRubro(
                id: 'SEG-2',
                tipo: 'Cotización',
                responsable: 'Juan Pérez',
                fecha: DateTime(2025, 5, 22),
                subSeguimientos: 0,
                estado: 'Finalizado',
                descripcion: 'Cotización enviada al propietario.',
              ),
            ],
          ),
        ],
        imagenes: [],
        archivos: [],
        seguimientos: [
          SeguimientoHistorial(
            id: 'HS-1',
            estado: 'Revisión',
            responsable: 'Juan Pérez',
            fecha: DateTime(2025, 5, 21),
            descripcion: 'Visita técnica realizada.',
          ),
          SeguimientoHistorial(
            id: 'HS-2',
            estado: 'Cotización',
            responsable: 'Juan Pérez',
            fecha: DateTime(2025, 5, 22),
            descripcion: 'Cotización enviada por correo.',
          ),
        ],
      ),
      Reporte(
        id: 'R-002',
        ubicacion: 'Envigado, La Mina',
        tipoInmueble: 'Casa',
        propietario: 'Ana Martínez',
        tipoReporte: 'Mantenimiento general',
        fecha: DateTime(2025, 5, 18),
        estado: EstadoReporte.finalizado,
        responsable: 'Equipo de Mantenimiento',
        referencia: 'CAS-5512',
        descripcion: 'Mantenimiento preventivo de techos y canaletas.',
        seguimientoGeneral: 'Mantenimiento completado satisfactoriamente.',
        rubros: [],
        imagenes: [],
        archivos: [],
        seguimientos: [
          SeguimientoHistorial(
            id: 'HS-3',
            estado: 'En ejecución',
            responsable: 'Equipo de Mantenimiento',
            fecha: DateTime(2025, 5, 18),
            descripcion: 'Limpieza de canaletas y ajuste de tejas.',
          ),
          SeguimientoHistorial(
            id: 'HS-4',
            estado: 'Finalizado',
            responsable: 'Equipo de Mantenimiento',
            fecha: DateTime(2025, 5, 19),
            descripcion: 'Trabajo completado y validado.',
          ),
        ],
      ),
      Reporte(
        id: 'R-003',
        ubicacion: 'Bello, Centro',
        tipoInmueble: 'Local comercial',
        propietario: 'Carlos López',
        tipoReporte: 'Mejora iluminación',
        fecha: DateTime(2025, 5, 15),
        estado: EstadoReporte.pendiente,
        responsable: 'No asignado',
        referencia: 'LC-3456',
        descripcion:
            'Instalación de luces LED para mejorar la visibilidad en el local.',
        seguimientoGeneral: 'Aún no se ha asignado responsable.',
        rubros: [],
        imagenes: [],
        archivos: [],
        seguimientos: [],
      ),
      Reporte(
        id: 'R-004',
        ubicacion: 'Itagüí, Industrial',
        tipoInmueble: 'Fábrica',
        propietario: 'María González',
        tipoReporte: 'Emergencia plomería',
        fecha: DateTime(2025, 4, 25),
        estado: EstadoReporte.urgente,
        responsable: 'Equipo Emergencia',
        referencia: 'FAB-7890',
        descripcion:
            'Ruptura de tubería principal causando inundación.',
        seguimientoGeneral:
            'Requiere atención inmediata. Sin avances en 10 días.',
        rubros: [
          RubroReporte(
            id: 'RB-2',
            nombre: 'Emergencia',
            activo: true,
            valorTotal: 500000,
            seguimientos: [
              SeguimientoRubro(
                id: 'SEG-3',
                tipo: 'Evaluación',
                responsable: 'Equipo Emergencia',
                fecha: DateTime(2025, 4, 26),
                subSeguimientos: 0,
                estado: 'Pendiente',
                descripcion: 'Evaluación inicial pendiente.',
              ),
            ],
          ),
        ],
        imagenes: [],
        archivos: [],
        seguimientos: [
          SeguimientoHistorial(
            id: 'HS-5',
            estado: 'Alerta',
            responsable: 'Equipo Emergencia',
            fecha: DateTime(2025, 4, 25),
            descripcion: 'Reporte de emergencia recibido.',
          ),
        ],
      ),
      Reporte(
        id: 'R-005',
        ubicacion: 'Sabaneta, Calle Larga',
        tipoInmueble: 'Apartamento',
        propietario: 'Luis Ramírez',
        tipoReporte: 'Pintura exterior',
        fecha: DateTime(2025, 5, 10),
        estado: EstadoReporte.enProgreso,
        responsable: 'Equipo de Pintura',
        referencia: 'AP-1234',
        descripcion: 'Renovación de pintura en fachada y balcones.',
        seguimientoGeneral: 'Trabajo en progreso, 60% completado.',
        rubros: [
          RubroReporte(
            id: 'RB-3',
            nombre: 'Pintura',
            activo: true,
            valorTotal: 800000,
            seguimientos: [
              SeguimientoRubro(
                id: 'SEG-4',
                tipo: 'Preparación',
                responsable: 'Equipo de Pintura',
                fecha: DateTime(2025, 5, 11),
                subSeguimientos: 1,
                estado: 'Finalizado',
                descripcion: 'Limpieza y preparación de superficies.',
              ),
              SeguimientoRubro(
                id: 'SEG-5',
                tipo: 'Aplicación',
                responsable: 'Equipo de Pintura',
                fecha: DateTime(2025, 5, 13),
                subSeguimientos: 0,
                estado: 'En progreso',
                descripcion: 'Aplicación de primera capa.',
              ),
            ],
          ),
        ],
        imagenes: [],
        archivos: [],
        seguimientos: [
          SeguimientoHistorial(
            id: 'HS-6',
            estado: 'Iniciado',
            responsable: 'Equipo de Pintura',
            fecha: DateTime(2025, 5, 10),
            descripcion: 'Inicio de trabajos de pintura.',
          ),
        ],
      ),
    ];
  }

  /// Obtiene un reporte específico por su ID
  /// En producción, haría una petición GET /reportes/{id}
  Future<Reporte?> obtenerReportePorId(String id) async {
    await _simulateNetworkDelay();
    final reportes = await obtenerReportes();
    try {
      return reportes.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Calcula las estadísticas de los reportes
  /// Retorna un mapa con contadores por estado
  Future<Map<EstadoReporte, int>> obtenerEstadisticas() async {
    final reportes = await obtenerReportes();
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

  /// Busca reportes por texto (ubicación, tipo, ID, propietario, etc.)
  /// Retorna lista filtrada de reportes
  Future<List<Reporte>> buscarReportes(String query) async {
    if (query.isEmpty) return obtenerReportes();

    final reportes = await obtenerReportes();
    final queryLower = query.toLowerCase();

    return reportes.where((reporte) {
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

  /// Filtra reportes por estado específico
  Future<List<Reporte>> filtrarPorEstado(EstadoReporte estado) async {
    final reportes = await obtenerReportes();
    return reportes.where((r) => r.estado == estado).toList();
  }

  /// Filtra reportes por múltiples criterios
  /// Si estado es null, no filtra por estado
  Future<List<Reporte>> filtrarReportes({
    EstadoReporte? estado,
    String? query,
  }) async {
    var reportes = await obtenerReportes();

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

  /// Obtiene el total de seguimientos de todos los reportes
  Future<int> obtenerTotalSeguimientos() async {
    final reportes = await obtenerReportes();
    return reportes.fold<int>(0, (sum, reporte) => sum + reporte.totalSeguimientos);
  }

  /// Calcula el progreso promedio de todos los reportes
  Future<double> obtenerProgresoPromedio() async {
    final reportes = await obtenerReportes();
    if (reportes.isEmpty) return 0.0;

    final progresoTotal = reportes.fold<double>(
      0.0,
      (sum, reporte) => sum + reporte.progreso,
    );

    return progresoTotal / reportes.length;
  }
}

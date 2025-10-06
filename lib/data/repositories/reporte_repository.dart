import '../models/reporte_model.dart';

class ReporteRepository {
  static final List<Reporte> _reportes = [];
  static bool _initialized = false;

  // Inicializar con reportes de ejemplo
  static void _initializeDefaultReportes() {
    if (!_initialized) {
      final reportesEjemplo = [
        Reporte(
          id: '#12345',
          ubicacion: 'Zona Norte',
          tipoInmueble: 'Casa',
          referencia: 'Apto 502',
          titulo: 'Casa Moderna',
          descripcion: 'Reparación integral de apartamento',
          estado: 'En proceso',
          responsable: 'Juan Pérez',
          rubros: [
            RubroProyecto(
              id: 'rubro_1',
              nombre: 'Baños',
              descripcion: 'Inspección y reparación',
              estado: 'En proceso',
              listaSeguimientos: [
                Seguimiento(
                  id: 'seg_1',
                  fecha: DateTime.now().subtract(const Duration(days: 2)),
                  estado: 'Completado',
                  descripcion: 'Revisión inicial completada',
                ),
                Seguimiento(
                  id: 'seg_2',
                  fecha: DateTime.now().subtract(const Duration(days: 1)),
                  estado: 'En proceso',
                  descripcion: 'Reparación en progreso',
                ),
              ],
            ),
            RubroProyecto(
              id: 'rubro_2',
              nombre: 'Cocina',
              descripcion: 'Reparación de grifería',
              estado: 'Completado',
              listaSeguimientos: [
                Seguimiento(
                  id: 'seg_3',
                  fecha: DateTime.now().subtract(const Duration(days: 3)),
                  estado: 'Completado',
                  descripcion: 'Grifería reparada exitosamente',
                ),
              ],
            ),
            RubroProyecto(
              id: 'rubro_3',
              nombre: 'Ventanas',
              descripcion: 'Cambio de marcos',
              estado: 'Pendiente',
              listaSeguimientos: [],
            ),
          ],
          archivos: ['imagen1.jpg', 'documento1.pdf'],
        ),
      ];

      _reportes.addAll(reportesEjemplo);
      _initialized = true;
    }
  }

  // Crear nuevo reporte
  static String createReporte(Reporte reporte) {
    _initializeDefaultReportes();
    
    final newId = '#${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final newReporte = Reporte(
      id: newId,
      ubicacion: reporte.ubicacion,
      tipoInmueble: reporte.tipoInmueble,
      referencia: reporte.referencia,
      titulo: reporte.titulo,
      descripcion: reporte.descripcion,
      estado: reporte.estado,
      responsable: reporte.responsable,
      rubros: reporte.rubros,
      archivos: reporte.archivos,
    );

    _reportes.add(newReporte);
    return newId;
  }

  // Obtener todos los reportes
  static List<Reporte> getAllReportes() {
    _initializeDefaultReportes();
    return List.unmodifiable(_reportes);
  }

  // Obtener reporte por ID
  static Reporte? getReporteById(String id) {
    _initializeDefaultReportes();
    try {
      return _reportes.firstWhere((reporte) => reporte.id == id);
    } catch (e) {
      return null;
    }
  }

  // Actualizar reporte
  static bool updateReporte(String id, Reporte updatedReporte) {
    _initializeDefaultReportes();
    
    final index = _reportes.indexWhere((reporte) => reporte.id == id);
    if (index == -1) return false;

    _reportes[index] = updatedReporte;
    return true;
  }

  // Eliminar reporte
  static bool deleteReporte(String id) {
    _initializeDefaultReportes();
    
    final index = _reportes.indexWhere((reporte) => reporte.id == id);
    if (index == -1) return false;

    _reportes.removeAt(index);
    return true;
  }

  // Filtrar reportes
  static List<Reporte> filterReportes({
    String? estado,
    String? tipoInmueble,
    String? responsable,
    String? searchQuery,
  }) {
    _initializeDefaultReportes();
    
    return _reportes.where((reporte) {
      bool matchesEstado = estado == null || estado == 'Todos' || reporte.estado == estado;
      bool matchesTipo = tipoInmueble == null || tipoInmueble == 'Todos' || reporte.tipoInmueble == tipoInmueble;
      bool matchesResponsable = responsable == null || reporte.responsable == responsable;
      bool matchesSearch = searchQuery == null || searchQuery.isEmpty ||
          reporte.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
          reporte.titulo.toLowerCase().contains(searchQuery.toLowerCase()) ||
          reporte.ubicacion.toLowerCase().contains(searchQuery.toLowerCase());
      
      return matchesEstado && matchesTipo && matchesResponsable && matchesSearch;
    }).toList();
  }

  // Agregar rubro a un reporte
  static bool addRubroToReporte(String reporteId, RubroProyecto rubro) {
    _initializeDefaultReportes();
    
    final reporte = getReporteById(reporteId);
    if (reporte == null) return false;

    final updatedRubros = List<RubroProyecto>.from(reporte.rubros);
    updatedRubros.add(rubro);

    final updatedReporte = Reporte(
      id: reporte.id,
      ubicacion: reporte.ubicacion,
      tipoInmueble: reporte.tipoInmueble,
      referencia: reporte.referencia,
      titulo: reporte.titulo,
      descripcion: reporte.descripcion,
      estado: reporte.estado,
      responsable: reporte.responsable,
      rubros: updatedRubros,
      fechaCreacion: reporte.fechaCreacion,
      archivos: reporte.archivos,
    );

    return updateReporte(reporteId, updatedReporte);
  }
}
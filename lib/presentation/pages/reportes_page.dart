import 'package:flutter/material.dart';
import '../../models/reporte_model.dart';
import '../../services/reportes_service.dart';
import '../widgets/reportes/estadisticas_reportes_cards.dart';
import '../widgets/reportes/barra_busqueda_reportes.dart';
import '../widgets/reportes/filtros_estado_chips.dart';
import '../widgets/reportes/reporte_card.dart';
import '../widgets/reportes/detalle_reporte_dialog.dart';

/// Página principal de reportes para propietarios
/// Permite consultar el estado y seguimiento de reportes de mantenimiento
class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  // Servicio de reportes
  final ReportesService _reportesService = ReportesService();

  // Controlador de búsqueda
  final TextEditingController _busquedaController = TextEditingController();

  // Estado de la página
  List<Reporte> _todosLosReportes = [];
  List<Reporte> _reportesFiltrados = [];
  Map<EstadoReporte, int> _estadisticas = {};
  int _totalSeguimientos = 0;
  double _progresoPromedio = 0.0;

  // Filtros
  EstadoReporte? _estadoFiltro;

  // Estado de carga
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  /// Carga los reportes desde el servicio
  Future<void> _cargarReportes() async {
    setState(() => _isLoading = true);

    try {
      // Cargar datos en paralelo
      final reportes = await _reportesService.obtenerReportes();
      final estadisticas = await _reportesService.obtenerEstadisticas();
      final totalSeguimientos = await _reportesService.obtenerTotalSeguimientos();
      final progresoPromedio = await _reportesService.obtenerProgresoPromedio();

      setState(() {
        _todosLosReportes = reportes;
        _reportesFiltrados = reportes;
        _estadisticas = estadisticas;
        _totalSeguimientos = totalSeguimientos;
        _progresoPromedio = progresoPromedio;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar reportes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Aplica los filtros de búsqueda y estado
  void _aplicarFiltros() {
    setState(() {
      _reportesFiltrados = _todosLosReportes.where((reporte) {
        // Filtro por estado
        if (_estadoFiltro != null && reporte.estado != _estadoFiltro) {
          return false;
        }

        // Filtro por búsqueda
        if (_busquedaController.text.isNotEmpty) {
          final query = _busquedaController.text.toLowerCase();
          return reporte.id.toLowerCase().contains(query) ||
              reporte.ubicacion.toLowerCase().contains(query) ||
              reporte.tipoInmueble.toLowerCase().contains(query) ||
              reporte.propietario.toLowerCase().contains(query) ||
              reporte.tipoReporte.toLowerCase().contains(query) ||
              reporte.responsable.toLowerCase().contains(query) ||
              reporte.referencia.toLowerCase().contains(query) ||
              reporte.descripcion.toLowerCase().contains(query);
        }

        return true;
      }).toList();
    });
  }

  /// Muestra el modal de detalle de un reporte
  void _mostrarDetalleReporte(Reporte reporte) {
    showDialog(
      context: context,
      builder: (context) => DetalleReporteDialog(reporte: reporte),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gradiente dinámico según hora del día (similar a citas_page.dart)
    final hour = DateTime.now().hour;
    final isMorning = hour >= 6 && hour < 12;
    final isAfternoon = hour >= 12 && hour < 18;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isMorning
                ? [const Color(0xFFE3F2FD), const Color(0xFFF5F5F5)] // Azul claro mañana
                : isAfternoon
                    ? [const Color(0xFFFFF8E1), const Color(0xFFF5F5F5)] // Amarillo claro tarde
                    : [const Color(0xFFE8EAF6), const Color(0xFFF5F5F5)], // Púrpura claro noche
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0A4B84),
                ),
              )
            : RefreshIndicator(
                onRefresh: _cargarReportes,
                color: const Color(0xFF0A4B84),
                child: CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      expandedHeight: 120,
                      floating: false,
                      pinned: true,
                      backgroundColor: const Color(0xFF0A4B84),
                      flexibleSpace: FlexibleSpaceBar(
                        title: const Text(
                          'Mis Reportes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF0A4B84),
                                Color(0xFF0D5FA3),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Contenido
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Tarjetas de estadísticas
                          EstadisticasReportesCards(
                            estadisticas: _estadisticas,
                            total: _todosLosReportes.length,
                            totalSeguimientos: _totalSeguimientos,
                            progresoPromedio: _progresoPromedio,
                            onEstadoTap: (estado) {
                              setState(() {
                                _estadoFiltro = estado;
                                _aplicarFiltros();
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // Barra de búsqueda
                          BarraBusquedaReportes(
                            controller: _busquedaController,
                            onChanged: (value) => _aplicarFiltros(),
                            onClear: () {
                              setState(() => _aplicarFiltros());
                            },
                          ),

                          const SizedBox(height: 8),

                          // Filtros por estado
                          FiltrosEstadoChips(
                            estadoSeleccionado: _estadoFiltro,
                            onEstadoSeleccionado: (estado) {
                              setState(() {
                                _estadoFiltro = estado;
                                _aplicarFiltros();
                              });
                            },
                          ),

                          const SizedBox(height: 8),

                          // Lista de reportes
                          if (_reportesFiltrados.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No se encontraron reportes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...(_reportesFiltrados.map((reporte) {
                              return ReporteCard(
                                reporte: reporte,
                                onTap: () => _mostrarDetalleReporte(reporte),
                              );
                            })),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}


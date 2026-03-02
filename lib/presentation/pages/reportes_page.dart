import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/reporte_model.dart';
import '../../models/user_model.dart';
import '../../services/reportes_service.dart';

import '../widgets/reportes/barra_busqueda_reportes.dart';
import '../widgets/reportes/filtros_estado_chips.dart';
import '../widgets/reportes/reporte_card.dart';
import '../widgets/reportes/detalle_reporte_dialog.dart';

/// Página principal de reportes para propietarios
class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage>
    with TickerProviderStateMixin {
  final ReportesService _reportesService = ReportesService();
  final TextEditingController _busquedaController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  User? _currentUser;
  bool _isLoading = true;
  List<Reporte> _todosLosReportes = [];
  List<Reporte> _reportesFiltrados = [];
  Map<EstadoReporte, int> _estadisticas = {
    EstadoReporte.pendiente: 0,
    EstadoReporte.enProgreso: 0,
    EstadoReporte.finalizado: 0,
    EstadoReporte.urgente: 0,
  };
  int _totalSeguimientos = 0;
  double _progresoPromedio = 0.0;
  EstadoReporte? _estadoFiltro;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _inicializar();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _inicializar() async {
    await _cargarUsuario();
    await _cargarDatos();
  }

  Future<void> _cargarUsuario() async {
    final user = await _reportesService.getCurrentUser();
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

  Future<void> _cargarDatos() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final propietarioId = _currentUser?.esPropietario == true
          ? _currentUser?.idPersona
          : null;

      final reportes = await _reportesService.obtenerReportes(
        propietarioId: propietarioId,
      );
      final estadisticas = await _reportesService.obtenerEstadisticas(
        propietarioId: propietarioId,
      );
      final totalSeguimientos = await _reportesService.obtenerTotalSeguimientos(
        propietarioId: propietarioId,
      );
      final progresoPromedio = await _reportesService.obtenerProgresoPromedio(
        propietarioId: propietarioId,
      );

      if (mounted) {
        setState(() {
          _todosLosReportes = reportes;
          _estadisticas = estadisticas;
          _totalSeguimientos = totalSeguimientos;
          _progresoPromedio = progresoPromedio;
          _isLoading = false;
          _aplicarFiltros();
        });
        _fadeController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text('Error al cargar reportes: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _aplicarFiltros() {
    _reportesFiltrados = _todosLosReportes.where((reporte) {
      if (_estadoFiltro != null && reporte.estado != _estadoFiltro) {
        return false;
      }
      if (_busquedaController.text.isNotEmpty) {
        final q = _busquedaController.text.toLowerCase();
        return reporte.id.toLowerCase().contains(q) ||
            reporte.ubicacion.toLowerCase().contains(q) ||
            reporte.tipoInmueble.toLowerCase().contains(q) ||
            reporte.propietario.toLowerCase().contains(q) ||
            reporte.tipoReporte.toLowerCase().contains(q) ||
            reporte.responsable.toLowerCase().contains(q) ||
            reporte.referencia.toLowerCase().contains(q) ||
            reporte.descripcion.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  void _mostrarDetalleReporte(Reporte reporte) {
    showDialog(
      context: context,
      builder: (context) => DetalleReporteDialog(reporte: reporte),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        color: const Color(0xFF0A4B84),
        displacement: 100,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ─── Hero Header ───────────────────────────────────────
            SliverAppBar(
              expandedHeight: 170,
              pinned: true,
              stretch: true,
              backgroundColor: const Color(0xFF0A4B84),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.fadeTitle,
                ],
                titlePadding:
                    const EdgeInsets.only(left: 20, bottom: 16, right: 20),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mis Reportes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (_currentUser != null)
                      Text(
                        _currentUser!.nombreCompletoTexto,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0D5FA3), Color(0xFF0A4B84)],
                        ),
                      ),
                    ),
                    // Decorative circles
                    Positioned(
                      right: -30,
                      top: -20,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      top: 40,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    // Total badge top right
                    if (!_isLoading)
                      Positioned(
                        right: 20,
                        top: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_todosLosReportes.length} reportes',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ─── Body Content ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0A4B84),
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Búsqueda
                          BarraBusquedaReportes(
                            controller: _busquedaController,
                            onChanged: (value) {
                              setState(() => _aplicarFiltros());
                            },
                            onClear: () {
                              setState(() => _aplicarFiltros());
                            },
                          ),

                          const SizedBox(height: 14),

                          // Filtros de estado
                          FiltrosEstadoChips(
                            estadoSeleccionado: _estadoFiltro,
                            onEstadoSeleccionado: (estado) {
                              setState(() {
                                _estadoFiltro = estado;
                                _aplicarFiltros();
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // Encabezado lista
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _reportesFiltrados.isEmpty
                                      ? 'Sin resultados'
                                      : '${_reportesFiltrados.length} resultado${_reportesFiltrados.length == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                if (_estadoFiltro != null ||
                                    _busquedaController.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _estadoFiltro = null;
                                        _busquedaController.clear();
                                        _aplicarFiltros();
                                      });
                                    },
                                    child: const Text(
                                      'Limpiar filtros',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF0A4B84),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Lista de reportes o estado vacío
                          if (_reportesFiltrados.isEmpty)
                            _buildEmptyState()
                          else
                            ...(_reportesFiltrados.map((reporte) {
                              return ReporteCard(
                                reporte: reporte,
                                onTap: () => _mostrarDetalleReporte(reporte),
                              );
                            })),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilters =
        _estadoFiltro != null || _busquedaController.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFilters ? Icons.search_off_rounded : Icons.inbox_rounded,
              size: 52,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'Sin resultados' : 'Sin reportes',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A2540),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Prueba ajustando los filtros\no la búsqueda.'
                : 'Aún no tienes reportes\nasociados a tus inmuebles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  _estadoFiltro = null;
                  _busquedaController.clear();
                  _aplicarFiltros();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A4B84),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Limpiar filtros',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

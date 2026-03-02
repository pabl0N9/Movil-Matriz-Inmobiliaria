import 'package:flutter/material.dart';
// import removed; DateFormat replaced with manual formatting in _buildRubroCard
import '../../data/models/reporte_model.dart';
import 'editar_reporte_page.dart';
import 'detalle_rubro_page.dart';

class DetalleReportePage extends StatefulWidget {
  final Reporte reporte;

  const DetalleReportePage({
    super.key,
    required this.reporte,
  });

  @override
  State<DetalleReportePage> createState() => _DetalleReportePageState();
}

class _DetalleReportePageState extends State<DetalleReportePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Completado': // Cambiado de 'completado'
        return Colors.green;
      case 'En proceso':
        return Colors.blue;
      case 'Pendiente': // Cambiado de 'pendiente'
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getEstadoIcon(String estado) {
    switch (estado) {
      case 'Completado': // Cambiado de 'completado'
        return '✓';
      case 'En proceso':
        return '⏳';
      case 'Pendiente': // Cambiado de 'pendiente'
        return '⏸';
      default:
        return '❓';
    }
  }

  String _getPrioridad() {
    // Simulamos prioridad basada en el estado
    switch (widget.reporte.estado.toLowerCase()) {
      case 'pendiente':
      case 'Pendiente':
      case 'sin novedades':
        return 'Alto';
      case 'en proceso':
      case 'iniciado':
        return 'Medio';
      default:
        return 'Bajo';
    }
  }

  Color _getPrioridadColor() {
    final prioridad = _getPrioridad();
    switch (prioridad) {
      case 'Alto':
        return Colors.red;
      case 'Medio':
        return Colors.orange;
      case 'Bajo':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Reporte Detallado',
          style: TextStyle(
            color: Color(0xFF0078CE),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          indicator: BoxDecoration(
            color: const Color(0xFF0078CE),
            borderRadius: BorderRadius.circular(8),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          isScrollable: false,
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          tabs: const [
            Tab(text: 'Información'),
            Tab(text: 'Detalles'),
            Tab(text: 'Rubros'),
            Tab(text: 'Resumen'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInformacionTab(),
          _buildDetallesTab(),
          _buildRubrosTab(),
          _buildResumenTab(),
        ],
      ),
    );
  }

  Widget _buildInformacionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Reporte',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          _buildInfoCard(
            'Dirección',
            '${widget.reporte.ubicacion} - ${widget.reporte.referencia}',
            Icons.location_on,
          ),
          const SizedBox(height: 16),

          _buildInfoCard(
            'Fecha',
            "${widget.reporte.fechaCreacion.year.toString().padLeft(4, '0')}-${widget.reporte.fechaCreacion.month.toString().padLeft(2, '0')}-${widget.reporte.fechaCreacion.day.toString().padLeft(2, '0')}",
            Icons.calendar_today,
          ),
          const SizedBox(height: 16),

          _buildInfoCard(
            'Estado',
            widget.reporte.estado,
            Icons.info,
            valueColor: _getEstadoColor(widget.reporte.estado),
            showBadge: true,
          ),
          const SizedBox(height: 16),

          _buildInfoCard(
            'Tipo',
            widget.reporte.tipoInmueble,
            Icons.home,
          ),
          const SizedBox(height: 16),

          _buildInfoCard(
            'Título',
            widget.reporte.titulo,
            Icons.title,
          ),
          const SizedBox(height: 32),

          // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditarReportePage(reporte: widget.reporte),
                        ),
                      );
                      
                      if (result == true) {
                        // Si se guardaron cambios, actualizar la vista
                        setState(() {});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078CE),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Editar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Función de descarga en desarrollo')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      'Descargar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetallesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles del Reporte',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          _buildDetailSection(
            'Descripción',
            widget.reporte.descripcion,
          ),
          const SizedBox(height: 24),

          _buildDetailSection(
            'Prioridad',
            _getPrioridad(),
            valueColor: _getPrioridadColor(),
            showBadge: true,
          ),
          const SizedBox(height: 24),

          _buildDetailSection(
            'Asignación',
            'Asignado a: ${widget.reporte.responsable}',
          ),
          const SizedBox(height: 24),

          _buildDetailSection(
            'Seguimiento General',
            _getSeguimientoGeneral(),
          ),
          const SizedBox(height: 32),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función de edición en desarrollo')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0078CE),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Editar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función de descarga en desarrollo')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text(
                    'Descargar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRubrosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rubros del Proyecto',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          if (widget.reporte.rubros.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.construction,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay rubros asignados',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            ...widget.reporte.rubros.map((rubro) => _buildRubroCard(rubro)),
          
          const SizedBox(height: 32),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función de edición en desarrollo')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0096D4),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Editar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función de descarga en desarrollo')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text(
                    'Descargar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumenTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del Proyecto',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Estadísticas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  widget.reporte.rubros.length.toString(),
                  'Total rubros',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  widget.reporte.rubrosCompletados.toString(),
                  'Completados',
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  widget.reporte.rubrosEnProceso.toString(),
                  'En proceso',
                  const Color(0xFF0078CE),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  widget.reporte.rubrosPendientes.toString(),
                  'Pendientes',
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Adjuntos
          const Text(
            'Adjuntos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          if (widget.reporte.archivos.isEmpty)
            Text(
              'No hay archivos adjuntos',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            )
          else ...[
            // Simulamos imágenes
            Row(
              children: [
                Expanded(child: _buildImagePlaceholder()),
                const SizedBox(width: 16),
                Expanded(child: _buildImagePlaceholder()),
              ],
            ),
            const SizedBox(height: 16),

            // Archivo PDF
            _buildFileCard(
              'presupuesto_materiales.pdf',
              '2.3 MB',
              Icons.picture_as_pdf,
            ),
            const SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Implementar edición
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078CE),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Editar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Implementar descarga
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      'Descargar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value, 
    IconData icon, {
    Color? valueColor,
    bool showBadge = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          if (showBadge && valueColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: valueColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: valueColor ?? Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    String content, {
    Color? valueColor,
    bool showBadge = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (showBadge && valueColor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: valueColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              content,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          )
        else
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: valueColor ?? Colors.grey[600],
              height: 1.5,
            ),
          ),
      ],
    );
  }

  Widget _buildRubroCard(RubroProyecto rubro) {
    final estadoColor = _getEstadoColor(rubro.estado);
    // Corregido: usar una fecha simulada en lugar de rubro.seguimientos
    final fechaActualizacion = "${DateTime.now().subtract(const Duration(days: 1)).year.toString().padLeft(4, '0')}-${DateTime.now().subtract(const Duration(days: 1)).month.toString().padLeft(2, '0')}-${DateTime.now().subtract(const Duration(days: 1)).day.toString().padLeft(2, '0')}";
    // Fecha simulada

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleRubroPage(
              rubro: rubro,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    rubro.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: estadoColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    rubro.estado,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              rubro.descripcion,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Última actualización:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          fechaActualizacion,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  size: 16,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  '${rubro.listaSeguimientos.length} seguimientos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Toca para ver detalles',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildFileCard(String fileName, String size, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.red),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  size,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.grey),
            onPressed: () {
              // Implementar descarga
            },
          ),
        ],
      ),
    );
  }

  String _getSeguimientoGeneral() {
    switch (widget.reporte.estado.toLowerCase()) {
      case 'en proceso':
        return 'Se ha iniciado la inspección preliminar. Pendiente coordinación con proveedores para materiales especializados.';
      case 'pendiente':
      case 'Pendiente':
        return 'Reporte recibido y en espera de asignación de técnico especializado.';
      case 'completado':
      case 'Completado':
        return 'Trabajo finalizado satisfactoriamente. Cliente notificado y conforme.';
      default:
        return 'Seguimiento en proceso. Se actualizará próximamente.';
    }
  }

  String _getNotasRubro(String nombreRubro) {
    switch (nombreRubro.toLowerCase()) {
      case 'baños':
        return 'Revisión de tuberías completada. Pendiente cambio de grifería.';
      case 'ventanas':
        return 'Identificados marcos con deterioro en sala principal.';
      case 'sistema de calefacción':
        return 'Sistema reparado y funcionando correctamente.';
      default:
        return 'Sin notas adicionales.';
    }
  }
}
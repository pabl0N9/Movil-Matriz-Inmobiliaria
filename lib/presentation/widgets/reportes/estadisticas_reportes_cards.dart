import 'package:flutter/material.dart';
import '../../../models/reporte_model.dart';
import 'package:intl/intl.dart';

/// Widget que muestra las tarjetas de estadísticas de reportes
/// Diseño responsivo con animaciones y colores diferenciados
class EstadisticasReportesCards extends StatelessWidget {
  final Map<EstadoReporte, int> estadisticas;
  final int total;
  final int totalSeguimientos;
  final double progresoPromedio;
  final Function(EstadoReporte?)? onEstadoTap;

  const EstadisticasReportesCards({
    super.key,
    required this.estadisticas,
    required this.total,
    required this.totalSeguimientos,
    required this.progresoPromedio,
    this.onEstadoTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular totales por categoría
    final activos = (estadisticas[EstadoReporte.pendiente] ?? 0) +
        (estadisticas[EstadoReporte.enProgreso] ?? 0) +
        (estadisticas[EstadoReporte.urgente] ?? 0);
    final finalizados = estadisticas[EstadoReporte.finalizado] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.2,
        children: [
          // Total de reportes
          _buildStatCard(
            context: context,
            icon: Icons.description_outlined,
            label: 'Total',
            value: total.toString(),
            color: Colors.blueGrey,
            backgroundColor: Colors.blueGrey.shade50,
            onTap: () => onEstadoTap?.call(null),
          ),
          // Reportes activos
          _buildStatCard(
            context: context,
            icon: Icons.pending_actions_outlined,
            label: 'Activos',
            value: activos.toString(),
            color: Colors.orange,
            backgroundColor: Colors.orange.shade50,
            onTap: () => onEstadoTap?.call(EstadoReporte.enProgreso),
          ),
          // Reportes finalizados
          _buildStatCard(
            context: context,
            icon: Icons.check_circle_outline,
            label: 'Finalizados',
            value: finalizados.toString(),
            color: Colors.green,
            backgroundColor: Colors.green.shade50,
            onTap: () => onEstadoTap?.call(EstadoReporte.finalizado),
          ),
          // Total de seguimientos
          _buildStatCard(
            context: context,
            icon: Icons.timeline_outlined,
            label: 'Seguimientos',
            value: totalSeguimientos.toString(),
            color: const Color(0xFF0A4B84),
            backgroundColor: const Color(0xFF0A4B84).withOpacity(0.1),
            onTap: null,
          ),
          // Progreso promedio (ocupa 2 columnas)
        ],
      ),
    );
  }

  /// Construye una tarjeta individual de estadística
  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color backgroundColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              // Label y valor
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

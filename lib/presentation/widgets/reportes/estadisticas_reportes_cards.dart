import 'package:flutter/material.dart';
import '../../../models/reporte_model.dart';

/// Widget que muestra las tarjetas de estadísticas de reportes
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
    final pendientes = estadisticas[EstadoReporte.pendiente] ?? 0;
    final enProgreso = estadisticas[EstadoReporte.enProgreso] ?? 0;
    final finalizados = estadisticas[EstadoReporte.finalizado] ?? 0;
    final urgentes = estadisticas[EstadoReporte.urgente] ?? 0;
    final activos = pendientes + enProgreso + urgentes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Fila 1: Total + Activos
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.description_rounded,
                  label: 'Total',
                  value: total.toString(),
                  accent: const Color(0xFF4A6FA5),
                  bgGradient: [const Color(0xFF4A6FA5), const Color(0xFF0A4B84)],
                  onTap: () => onEstadoTap?.call(null),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.pending_actions_rounded,
                  label: 'Activos',
                  value: activos.toString(),
                  accent: const Color(0xFFE07B39),
                  bgGradient: [const Color(0xFFE07B39), const Color(0xFFBF5D1B)],
                  onTap: () => onEstadoTap?.call(EstadoReporte.pendiente),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Fila 2: Finalizados + Urgentes
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Finalizados',
                  value: finalizados.toString(),
                  accent: const Color(0xFF2E8B57),
                  bgGradient: [const Color(0xFF2E8B57), const Color(0xFF1A6B3E)],
                  onTap: () => onEstadoTap?.call(EstadoReporte.finalizado),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.warning_rounded,
                  label: 'Urgentes',
                  value: urgentes.toString(),
                  accent: const Color(0xFFCC2929),
                  bgGradient: [const Color(0xFFCC2929), const Color(0xFF991F1F)],
                  onTap: () => onEstadoTap?.call(EstadoReporte.urgente),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de progreso global
          _ProgressSummaryCard(
            progresoPromedio: progresoPromedio,
            totalSeguimientos: totalSeguimientos,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final List<Color> bgGradient;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.bgGradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: const BoxConstraints(minHeight: 95),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: bgGradient.first.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: Colors.white.withOpacity(0.6)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSummaryCard extends StatelessWidget {
  final double progresoPromedio;
  final int totalSeguimientos;

  const _ProgressSummaryCard({
    required this.progresoPromedio,
    required this.totalSeguimientos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso promedio',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${progresoPromedio.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A4B84),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progresoPromedio / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0A4B84)),
                    minHeight: 7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                totalSeguimientos.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A4B84),
                ),
              ),
              Text(
                'seguim.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

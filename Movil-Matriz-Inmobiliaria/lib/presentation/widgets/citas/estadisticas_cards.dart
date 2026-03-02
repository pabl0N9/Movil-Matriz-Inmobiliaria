import 'package:flutter/material.dart';
import '../../../models/cita_model.dart';

class EstadisticasCards extends StatelessWidget {
  final Map<EstadoCita, int> estadisticas;
  final int total;
  final Function(EstadoCita?)? onEstadoTap;

  const EstadisticasCards({
    super.key,
    required this.estadisticas,
    required this.total,
    this.onEstadoTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildCard(
                'Total',
                total.toString(),
                const Color(0xFF0A4B84),
                Icons.calendar_today,
                null,
              ),
              _buildCard(
                'Programadas',
                estadisticas[EstadoCita.programada].toString(),
                const Color(0xFFFFA726),
                Icons.schedule,
                EstadoCita.programada,
              ),
              _buildCard(
                'Confirmadas',
                estadisticas[EstadoCita.confirmada].toString(),
                const Color(0xFF42A5F5),
                Icons.check_circle_outline,
                EstadoCita.confirmada,
              ),
              _buildCard(
                'Completadas',
                estadisticas[EstadoCita.completada].toString(),
                const Color(0xFF66BB6A),
                Icons.done_all,
                EstadoCita.completada,
              ),
              _buildCard(
                'Canceladas',
                estadisticas[EstadoCita.cancelada].toString(),
                const Color(0xFFEF5350),
                Icons.cancel_outlined,
                EstadoCita.cancelada,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String label, String value, Color color, IconData icon, EstadoCita? estado) {
    return GestureDetector(
      onTap: () => onEstadoTap?.call(estado),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../models/reporte_model.dart';

/// Widget de chips para filtrar reportes por estado
/// Permite selección única con colores según estado
class FiltrosEstadoChips extends StatelessWidget {
  final EstadoReporte? estadoSeleccionado;
  final Function(EstadoReporte?) onEstadoSeleccionado;

  const FiltrosEstadoChips({
    super.key,
    required this.estadoSeleccionado,
    required this.onEstadoSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Chip "Todos"
            _buildFilterChip(
              label: 'Todos',
              isSelected: estadoSeleccionado == null,
              color: Colors.blueGrey,
              onTap: () => onEstadoSeleccionado(null),
            ),
            const SizedBox(width: 8),
            // Chip por cada estado
            ...EstadoReporte.values.map((estado) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildFilterChip(
                  label: estado.nombre,
                  isSelected: estadoSeleccionado == estado,
                  color: estado.color,
                  icon: estado.icono,
                  onTap: () => onEstadoSeleccionado(estado),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Construye un chip de filtro individual
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color color,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

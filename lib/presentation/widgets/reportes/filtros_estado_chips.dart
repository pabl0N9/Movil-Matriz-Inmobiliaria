import 'package:flutter/material.dart';
import '../../../models/reporte_model.dart';

/// Widget de chips para filtrar reportes por estado - diseño premium
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'Todos',
              isSelected: estadoSeleccionado == null,
              color: const Color(0xFF0A4B84),
              onTap: () => onEstadoSeleccionado(null),
            ),
            const SizedBox(width: 8),
            ...EstadoReporte.values.map((estado) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _FilterChip(
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
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.32),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

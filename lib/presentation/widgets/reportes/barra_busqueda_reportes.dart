import 'package:flutter/material.dart';

/// Widget de barra de búsqueda optimizada para reportes
/// Incluye debounce, icono de búsqueda y botón para limpiar
class BarraBusquedaReportes extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback? onClear;

  const BarraBusquedaReportes({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
  });

  @override
  State<BarraBusquedaReportes> createState() => _BarraBusquedaReportesState();
}

class _BarraBusquedaReportesState extends State<BarraBusquedaReportes> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
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
        child: TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: 'Buscar por ubicación, tipo, ID...',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade500,
              size: 22,
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onClear?.call();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

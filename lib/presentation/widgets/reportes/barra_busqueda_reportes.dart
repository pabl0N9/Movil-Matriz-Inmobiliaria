import 'package:flutter/material.dart';

/// Barra de búsqueda premium para reportes
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          onChanged: (v) {
            widget.onChanged(v);
            setState(() {});
          },
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Buscar por ubicación, tipo o ID...',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(
                Icons.search_rounded,
                color: const Color(0xFF0A4B84).withOpacity(0.7),
                size: 22,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: widget.controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      widget.controller.clear();
                      widget.onClear?.call();
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }
}

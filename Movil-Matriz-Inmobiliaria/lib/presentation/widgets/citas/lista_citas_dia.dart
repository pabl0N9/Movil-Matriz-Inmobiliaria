import 'package:flutter/material.dart';
import '../../../models/cita_model.dart';
import 'package:intl/intl.dart';

class ListaCitasDia extends StatelessWidget {
  final List<Cita> citas;
  final Function(Cita) onCitaTap;
  final Function(Cita) onEstadoChange;
  final Function(Cita) onEdit;
  final Function(Cita) onDelete;
  final Function(Cita, DateTime) onDragToNewDate;

  const ListaCitasDia({
    super.key,
    required this.citas,
    required this.onCitaTap,
    required this.onEstadoChange,
    required this.onEdit,
    required this.onDelete,
    required this.onDragToNewDate,
  });

  @override
  Widget build(BuildContext context) {
    if (citas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No hay citas para este día',
            style: TextStyle(color: Colors.black38, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: citas.length,
      itemBuilder: (context, index) {
        final cita = citas[index];
        return _CitaCard(
          cita: cita,
          onTap: () => onCitaTap(cita),
          onEstadoChange: () => onEstadoChange(cita),
          onEdit: () => onEdit(cita),
          onDelete: () => onDelete(cita),
          onDragToNewDate: onDragToNewDate,
        );
      },
    );
  }
}

class _CitaCard extends StatelessWidget {
  final Cita cita;
  final VoidCallback onTap;
  final VoidCallback onEstadoChange;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(Cita, DateTime) onDragToNewDate;

  const _CitaCard({
    required this.cita,
    required this.onTap,
    required this.onEstadoChange,
    required this.onEdit,
    required this.onDelete,
    required this.onDragToNewDate,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Cita>(
      data: cita,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: MediaQuery.of(context).size.width - 32,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cita.estadoColor, width: 2),
          ),
          child: Text(
            cita.nombreCompleto,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCard(context),
      ),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cita.estadoColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cita.estadoColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      cita.estadoTexto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(cita.fechaHora),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A4B84),
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy', 'es').format(cita.fechaHora),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF0A4B84),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                cita.nombreCompleto,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    cita.telefono,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.medical_services, size: 14, color: Colors.black54),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      cita.servicio,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, size: 20),
                    color: const Color(0xFF0A4B84),
                    onPressed: onEstadoChange,
                    tooltip: 'Cambiar estado',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: const Color(0xFF42A5F5),
                    onPressed: onEdit,
                    tooltip: 'Editar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: const Color(0xFFEF5350),
                    onPressed: onDelete,
                    tooltip: 'Eliminar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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

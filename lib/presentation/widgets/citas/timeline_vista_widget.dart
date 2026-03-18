import 'package:flutter/material.dart';
import '../../../models/cita_model.dart';
import 'package:intl/intl.dart';

class TimelineVistaWidget extends StatelessWidget {
  final List<Cita> citas;
  final Function(Cita) onCitaTap;
  final Function(Cita) onEstadoChange;
  final Function(Cita) onEdit;
  final Function(Cita) onDelete;
  final bool showEdits;

  const TimelineVistaWidget({
    super.key,
    required this.citas,
    required this.onCitaTap,
    required this.onEstadoChange,
    required this.onEdit,
    required this.onDelete,
    this.showEdits = true,
  });

  @override
  Widget build(BuildContext context) {
    if (citas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No hay citas programadas',
            style: TextStyle(color: Colors.black38, fontSize: 16),
          ),
        ),
      );
    }

    // Ordenar citas por fecha
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final futuras = citas.where((c) {
      final d = DateTime(c.fechaHora.year, c.fechaHora.month, c.fechaHora.day);
      return !d.isBefore(today);
    }).toList()
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

    final pasadas = citas.where((c) {
      final d = DateTime(c.fechaHora.year, c.fechaHora.month, c.fechaHora.day);
      return d.isBefore(today);
    }).toList()
      ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

    final citasOrdenadas = [...futuras, ...pasadas];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: citasOrdenadas.length,
      itemBuilder: (context, index) {
        final cita = citasOrdenadas[index];
        final isLast = index == citasOrdenadas.length - 1;
        final isFirst = index == 0;

        return TimelineItem(
          cita: cita,
          isFirst: isFirst,
          isLast: isLast,
          onTap: () => onCitaTap(cita),
          onEstadoChange: () => onEstadoChange(cita),
          onEdit: () => onEdit(cita),
          onDelete: () => onDelete(cita),
          showEdits: showEdits,
          onBell: () => onDelete(
              cita), // reutilizamos onDelete como campana en esta vista
          onAddCalendar: null,
        );
      },
    );
  }
}

class TimelineItem extends StatelessWidget {
  final Cita cita;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onEstadoChange;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showEdits;
  final VoidCallback? onBell;
  final VoidCallback? onAddCalendar;

  const TimelineItem({
    super.key,
    required this.cita,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    required this.onEstadoChange,
    required this.onEdit,
    required this.onDelete,
    this.showEdits = true,
    this.onBell,
    this.onAddCalendar,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isPast = cita.fechaHora.isBefore(now);
    final isToday = cita.fechaHora.day == now.day &&
        cita.fechaHora.month == now.month &&
        cita.fechaHora.year == now.year;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line and dot
        SizedBox(
          width: 60,
          child: Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 20,
                  color: Colors.grey.shade300,
                ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isPast ? Colors.grey : cita.estadoColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isPast ? Colors.grey : cita.estadoColor)
                          .withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: Colors.grey.shade300,
                ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, left: 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and time header
                      Row(
                        children: [
                          Icon(
                            isToday ? Icons.today : Icons.event,
                            size: 18,
                            color:
                                isPast ? Colors.grey : const Color(0xFF0A4B84),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isToday
                                ? 'Hoy'
                                : DateFormat('dd MMM yyyy', 'es')
                                    .format(cita.fechaHora),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isPast
                                  ? Colors.grey
                                  : const Color(0xFF0A4B84),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('h:mm a').format(cita.fechaHora),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isPast
                                  ? Colors.grey
                                  : const Color(0xFF0A4B84),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: cita.estadoColor
                                  .withOpacity(isPast ? 0.5 : 1.0),
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
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Client info
                      Text(
                        cita.nombreCompleto,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPast ? Colors.grey.shade600 : Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Service and contact info
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services,
                            size: 16,
                            color:
                                isPast ? Colors.grey.shade500 : Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              cita.servicioNombre ?? cita.servicio,
                              style: TextStyle(
                                fontSize: 14,
                                color: isPast
                                    ? Colors.grey.shade500
                                    : Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color:
                                isPast ? Colors.grey.shade500 : Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cita.telefono,
                            style: TextStyle(
                              fontSize: 14,
                              color: isPast
                                  ? Colors.grey.shade500
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),

                      if (cita.inmuebleDireccion != null &&
                          cita.inmuebleDireccion!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: isPast
                                  ? Colors.grey.shade500
                                  : Colors.black54,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                cita.inmuebleDireccion!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isPast
                                      ? Colors.grey.shade500
                                      : Colors.black54,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (showEdits) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                '${cita.edicionesRealizadas ?? 0}/${cita.edicionesMaximas ?? 2} ediciones',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (cita.detalles.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          cita.detalles,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                isPast ? Colors.grey.shade500 : Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Action buttons
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.swap_horiz,
                              size: 20,
                              color: isPast
                                  ? Colors.grey
                                  : const Color(0xFF0A4B84),
                            ),
                            onPressed: isPast ? null : onEstadoChange,
                            tooltip: 'Reagendar',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: Icon(
                              Icons.cancel,
                              size: 20,
                              color: isPast
                                  ? Colors.grey
                                  : const Color(0xFFEF5350),
                            ),
                            onPressed: isPast ? null : onEdit,
                            tooltip: 'Cancelar',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          if (onBell != null)
                            IconButton(
                              icon: Icon(
                                Icons.notifications_active,
                                size: 20,
                                color: isPast
                                    ? Colors.grey
                                    : const Color(0xFFFFA000),
                              ),
                              onPressed: isPast ? null : onBell,
                              tooltip: 'Activar recordatorios',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

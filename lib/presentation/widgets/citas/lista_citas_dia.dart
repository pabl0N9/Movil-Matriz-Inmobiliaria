import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../models/cita_model.dart';
import '../../../services/calendar_service.dart';

class ListaCitasDia extends StatelessWidget {
  final List<Cita> citas;
  final Function(Cita) onCitaTap; // Ver
  final Function(Cita) onEstadoChange; // Reagendar
  final Function(Cita) onEdit; // Cancelar
  final Function(Cita) onDelete; // Recordatorios/borrar segun caller
  final Function(Cita, DateTime) onDragToNewDate;
  final Function(Cita)? onBell;
  final Function(Cita)? onAddCalendar;
  final bool showEdits;

  const ListaCitasDia({
    super.key,
    required this.citas,
    required this.onCitaTap,
    required this.onEstadoChange,
    required this.onEdit,
    required this.onDelete,
    required this.onDragToNewDate,
    this.onBell,
    this.onAddCalendar,
    this.showEdits = true,
  });

  @override
  Widget build(BuildContext context) {
    if (citas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No hay citas para este dia',
            style: TextStyle(color: Colors.black38, fontSize: 14),
          ),
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: citas.length,
        itemBuilder: (context, index) {
          final cita = citas[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _CitaCard(
                  cita: cita,
                  onView: () => onCitaTap(cita),
                  onReagendar: () => onEstadoChange(cita),
                  onCancelar: () => onEdit(cita),
                  onAddCalendar:
                      onAddCalendar != null ? () => onAddCalendar!(cita) : null,
                  onBell: onBell != null ? () => onBell!(cita) : null,
                  onDragToNewDate: onDragToNewDate,
                  showEdits: showEdits,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CitaCard extends StatelessWidget {
  final Cita cita;
  final VoidCallback onView;
  final VoidCallback onReagendar;
  final VoidCallback onCancelar;
  final VoidCallback? onAddCalendar;
  final VoidCallback? onBell;
  final Function(Cita, DateTime) onDragToNewDate;
  final bool showEdits;

  const _CitaCard({
    required this.cita,
    required this.onView,
    required this.onReagendar,
    required this.onCancelar,
    required this.onAddCalendar,
    required this.onBell,
    required this.onDragToNewDate,
    this.showEdits = true,
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
        child: _buildSlidableCard(context),
      ),
      child: _buildSlidableCard(context),
    );
  }

  Widget _buildSlidableCard(BuildContext context) {
    return Slidable(
      key: ValueKey(cita.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onView(),
            backgroundColor: const Color(0xFF42A5F5),
            foregroundColor: Colors.white,
            icon: Icons.visibility,
            label: 'Ver',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onReagendar(),
            backgroundColor: const Color(0xFF66BB6A),
            foregroundColor: Colors.white,
            icon: Icons.swap_horiz,
            label: 'Reagendar',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onCancelar(),
            backgroundColor: const Color(0xFFEF5350),
            foregroundColor: Colors.white,
            icon: Icons.cancel,
            label: 'Cancelar',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final now = DateTime.now();
    final timeDifference = cita.fechaHora.difference(now).inHours;
    final isUpcoming =
        timeDifference > 0 && timeDifference <= 72; // siguiente 72h
    final isVeryClose =
        timeDifference > 0 && timeDifference <= 1; // siguiente hora

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVeryClose
              ? Colors.red.withOpacity(0.5)
              : cita.estadoColor.withOpacity(0.3),
          width: isVeryClose ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: isUpcoming ? 16 : 12,
            offset: const Offset(-4, -4),
          ),
          BoxShadow(
            color: isVeryClose
                ? Colors.red.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            blurRadius: isUpcoming ? 16 : 12,
            offset: const Offset(4, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            isUpcoming ? Colors.orange.shade50 : Colors.grey.shade50,
          ],
        ),
      ),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(12),
        splashColor: cita.estadoColor.withOpacity(0.1),
        highlightColor: cita.estadoColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cita.estadoColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: cita.estadoColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      cita.estadoTexto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      .animate()
                      .scale(duration: 300.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 200.ms),
                  const Spacer(),
                  if (showEdits) ...[
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
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('h:mm a').format(cita.fechaHora),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A4B84),
                        ),
                      )
                          .animate()
                          .slideX(
                              begin: 0.2,
                              end: 0,
                              duration: 400.ms,
                              curve: Curves.easeOut)
                          .fadeIn(duration: 400.ms),
                      Text(
                        DateFormat('dd MMM yyyy', 'es').format(cita.fechaHora),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF0A4B84),
                        ),
                      )
                          .animate()
                          .slideX(
                              begin: 0.2,
                              end: 0,
                              duration: 500.ms,
                              curve: Curves.easeOut)
                          .fadeIn(duration: 500.ms),
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
              )
                  .animate()
                  .slideY(
                      begin: 0.1,
                      end: 0,
                      duration: 300.ms,
                      curve: Curves.easeOut)
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.black54)
                      .animate()
                      .scale(duration: 200.ms, delay: 100.ms)
                      .fadeIn(duration: 200.ms, delay: 100.ms),
                  const SizedBox(width: 4),
                  Text(
                    cita.telefono,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  )
                      .animate()
                      .slideX(
                          begin: 0.1, end: 0, duration: 350.ms, delay: 150.ms)
                      .fadeIn(duration: 350.ms, delay: 150.ms),
                  const SizedBox(width: 12),
                  const Icon(Icons.medical_services,
                          size: 14, color: Colors.black54)
                      .animate()
                      .scale(duration: 200.ms, delay: 200.ms)
                      .fadeIn(duration: 200.ms, delay: 200.ms),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      cita.servicioNombre ?? cita.servicio,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    )
                        .animate()
                        .slideX(
                            begin: 0.1, end: 0, duration: 350.ms, delay: 250.ms)
                        .fadeIn(duration: 350.ms, delay: 250.ms),
                  ),
                ],
              ),
              if (cita.inmuebleDireccion != null &&
                  cita.inmuebleDireccion!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                            size: 14, color: Colors.black54)
                        .animate()
                        .scale(duration: 200.ms, delay: 220.ms)
                        .fadeIn(duration: 200.ms, delay: 220.ms),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        cita.inmuebleDireccion!,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      )
                          .animate()
                          .slideX(
                              begin: 0.1,
                              end: 0,
                              duration: 350.ms,
                              delay: 270.ms)
                          .fadeIn(duration: 350.ms, delay: 270.ms),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onBell != null) ...[
                    IconButton(
                      icon: Icon(
                        Icons.notifications_active,
                        size: 20,
                        color: isUpcoming
                            ? Colors.orange
                            : const Color(0xFF0A4B84),
                      )
                          .animate(
                            onPlay: (controller) =>
                                isVeryClose ? controller.repeat() : null,
                          )
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.15, 1.15),
                            duration: 800.ms,
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .scale(
                            begin: const Offset(1.15, 1.15),
                            end: const Offset(1, 1),
                            duration: 800.ms,
                            curve: Curves.easeInOut,
                          ),
                      onPressed: onBell,
                      tooltip: 'Activar recordatorios',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                        .animate()
                        .slideY(
                            begin: 0.2, end: 0, duration: 400.ms, delay: 250.ms)
                        .fadeIn(duration: 400.ms, delay: 250.ms),
                    const SizedBox(width: 12),
                  ],
                  if (onAddCalendar != null) ...[
                    IconButton(
                      icon: const Icon(Icons.calendar_today, size: 20),
                      color: const Color(0xFF9C27B0),
                      onPressed: () async {
                        final success = await CalendarService()
                            .addAppointmentToCalendar(cita);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cita agregada al calendario'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                        onAddCalendar?.call();
                      },
                      tooltip: 'Agregar al calendario',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                        .animate()
                        .slideY(
                            begin: 0.2, end: 0, duration: 400.ms, delay: 300.ms)
                        .fadeIn(duration: 400.ms, delay: 300.ms),
                    const SizedBox(width: 12),
                  ],
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, size: 20),
                    color: const Color(0xFF0A4B84),
                    onPressed: onReagendar,
                    tooltip: 'Reagendar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                      .animate()
                      .slideY(
                          begin: 0.2, end: 0, duration: 450.ms, delay: 350.ms)
                      .fadeIn(duration: 450.ms, delay: 350.ms),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.cancel, size: 20),
                    color: const Color(0xFFEF5350),
                    onPressed: onCancelar,
                    tooltip: 'Cancelar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                      .animate()
                      .slideY(
                          begin: 0.2, end: 0, duration: 500.ms, delay: 400.ms)
                      .fadeIn(duration: 500.ms, delay: 400.ms),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut)
        .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.easeOut);
  }
}

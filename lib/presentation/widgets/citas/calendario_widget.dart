import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/cita_model.dart';

/// Calendario compacto y limpio para móvil con tarjetas dentro de cada día,
/// botón de crear en el día seleccionado y drag & drop entre días.
class CalendarioWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<Cita>> citasPorFecha;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final Function(Cita, DateTime) onCitaDraggedToNewDate;
  final Function(DateTime)? onCreateAtDay;

  const CalendarioWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.citasPorFecha,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onCitaDraggedToNewDate,
    this.onCreateAtDay,
  });

  DateTime _startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);
  DateTime _endOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0);

  List<DateTime> _daysForMonth(DateTime month) {
    final start = _startOfMonth(month);
    final end = _endOfMonth(month);
    final leading = start.weekday - 1; // lunes = 1
    const totalCells = 42; // 6x7
    return List.generate(totalCells, (index) {
      final dayNumber = index - leading + 1;
      return DateTime(month.year, month.month, dayNumber);
    });
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysForMonth(focusedDay);
    final currentMonth = focusedDay.month;
    final monthLabel = DateFormat('MMMM yyyy', 'es').format(focusedDay);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onPageChanged(DateTime(focusedDay.year, focusedDay.month - 1, 1)),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    toBeginningOfSentenceCase(monthLabel) ?? monthLabel,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A4B84),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onPageChanged(DateTime(focusedDay.year, focusedDay.month + 1, 1)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _weekHeader(),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = (constraints.maxWidth - 6 * 8) / 7;
              final cellHeight = cellWidth * 1.05;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: days.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: cellWidth / cellHeight,
                ),
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isCurrentMonth = day.month == currentMonth;
                  return _DayCell(
                    day: day,
                    citas: citasPorFecha[DateTime(day.year, day.month, day.day)] ?? [],
                    isCurrentMonth: isCurrentMonth,
                    isSelected: _isSameDay(day, selectedDay),
                    onTap: () => onDaySelected(day, day),
                    onDrop: (cita) => onCitaDraggedToNewDate(cita, day),
                    onCreate: onCreateAtDay != null ? () => onCreateAtDay!(day) : null,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _weekHeader() {
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final List<Cita> citas;
  final bool isCurrentMonth;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(Cita) onDrop;
  final VoidCallback? onCreate;

  const _DayCell({
    required this.day,
    required this.citas,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.onTap,
    required this.onDrop,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
    final baseColor = isWeekend ? const Color(0xFFFFF7ED) : Colors.white;

    return DragTarget<Cita>(
      onWillAccept: (_) => isCurrentMonth,
      onAccept: (cita) => onDrop(cita),
      builder: (context, candidate, rejected) {
        final hovering = candidate.isNotEmpty;
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0A4B84)
                    : hovering
                        ? const Color(0xFF38BDF8)
                        : const Color(0xFFE2E8F0),
                width: isSelected ? 1.6 : 1,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCurrentMonth ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        const Spacer(),
                        if (citas.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Text(
                              '${citas.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ..._buildCitasPreview(),
                  ],
                ),
                if (onCreate != null && isSelected)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: IconButton(
                      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0A4B84),
                        side: const BorderSide(color: Color(0xFF0A4B84)),
                        shape: const CircleBorder(),
                      ),
                      onPressed: onCreate,
                      icon: const Icon(Icons.add),
                      tooltip: 'Nueva cita en este dia',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCitasPreview() {
    if (citas.isEmpty) return [const SizedBox.shrink()];
    final preview = citas.take(2).toList();
    final remaining = citas.length - preview.length;
    return [
      ...preview.map((c) => _MiniCitaChip(cita: c)),
      if (remaining > 0)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '+$remaining más',
            style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
          ),
        ),
    ];
  }
}

class _MiniCitaChip extends StatelessWidget {
  final Cita cita;
  const _MiniCitaChip({required this.cita});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Cita>(
      data: cita,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(10),
        child: _body(highlight: true, isFeedback: true),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: _body()),
      child: _body(),
    );
  }

  Widget _body({bool highlight = false, bool isFeedback = false}) {
    return Container(
      width: isFeedback ? 170 : double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? Colors.white : cita.estadoColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cita.estadoColor.withOpacity(highlight ? 0.9 : 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('HH:mm').format(cita.fechaHora),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cita.estadoColor,
            ),
          ),
          Text(
            cita.servicioNombre ?? cita.servicio,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

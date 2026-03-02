import 'package:flutter/material.dart';
import '../../../models/reporte_model.dart';
import 'package:intl/intl.dart';

/// Tarjeta premium para un reporte individual en la lista
class ReporteCard extends StatelessWidget {
  final Reporte reporte;
  final VoidCallback onTap;

  const ReporteCard({
    super.key,
    required this.reporte,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Barra de color con estado en la parte superior
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: reporte.estado.color.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Referencia / ID
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: reporte.estado.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        reporte.referencia.isNotEmpty ? reporte.referencia : reporte.id,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: reporte.estado.color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  // Badge de estado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: reporte.estado.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(reporte.estado.icono, size: 13, color: reporte.estado.color),
                        const SizedBox(width: 4),
                        Text(
                          reporte.estado.nombre,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: reporte.estado.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Cuerpo de la tarjeta
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo de reporte (título principal)
                  Text(
                    reporte.tipoReporte.isNotEmpty ? reporte.tipoReporte : 'Sin tipo',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2540),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Descripción
                  if (reporte.descripcion.isNotEmpty)
                    Text(
                      reporte.descripcion,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Info row
                  Row(
                    children: [
                      Expanded(
                        child: _InfoPill(
                          icon: Icons.location_on_outlined,
                          label: reporte.ubicacion.isNotEmpty
                              ? reporte.ubicacion
                              : 'Sin ubicación',
                          iconColor: const Color(0xFF0A4B84),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _InfoPill(
                        icon: Icons.home_work_outlined,
                        label: reporte.tipoInmueble.isNotEmpty
                            ? reporte.tipoInmueble
                            : '–',
                        iconColor: const Color(0xFF0A4B84),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 10),

                  // Pie: fecha + seguimientos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 13, color: Colors.grey.shade400),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat('dd MMM yyyy', 'es').format(reporte.fecha),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (reporte.totalSeguimientos > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A4B84).withOpacity(0.09),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timeline_rounded,
                                  size: 13, color: Color(0xFF0A4B84)),
                              const SizedBox(width: 4),
                              Text(
                                '${reporte.totalSeguimientos} seguim.',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0A4B84),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Barra de progreso
                  if (reporte.totalSeguimientos > 0) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: reporte.progreso / 100,
                              backgroundColor: Colors.grey.shade100,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  reporte.estado.color),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${reporte.progreso.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: reporte.estado.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor.withOpacity(0.7)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

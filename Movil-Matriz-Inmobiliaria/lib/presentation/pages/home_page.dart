import 'package:flutter/material.dart';
import 'package:flutter_citas_app/data/models/inmueble_model.dart';
import 'package:flutter_citas_app/data/repositories/inmueble_repository.dart';
import 'package:intl/intl.dart';

import '../widgets/header.dart';
import 'property_details.dart';

class TusInmueblesScreen extends StatefulWidget {
  const TusInmueblesScreen({super.key});

  @override
  State<TusInmueblesScreen> createState() => _TusInmueblesScreenState();
}

class _TusInmueblesScreenState extends State<TusInmueblesScreen> {
  int _selectedIndex = 0;
  late Future<List<Inmueble>> _inmueblesFuture;
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'es_CO',
    symbol: r'$ ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _inmueblesFuture = InmuebleRepository.getForCurrentOwner();
  }

  void _reload() {
    setState(() {
      _inmueblesFuture = InmuebleRepository.getForCurrentOwner();
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.pushNamed(context, '/citas');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/reports');
    }
  }

  bool _hasSale(Inmueble inmueble) {
    final op = inmueble.operation.toLowerCase();
    return inmueble.salePrice != null || op.contains('venta');
  }

  bool _hasRent(Inmueble inmueble) {
    final op = inmueble.operation.toLowerCase();
    return inmueble.rentPrice != null ||
        op.contains('arriendo') ||
        op.contains('arrend');
  }

  String _operationLabel(Inmueble inmueble) {
    final hasSale = _hasSale(inmueble);
    final hasRent = _hasRent(inmueble);
    if (hasSale && hasRent) return 'Venta y arriendo';
    if (hasSale) return 'Venta';
    if (hasRent) return 'Arriendo';
    return 'Sin definir';
  }

  num? _parseNumber(String? raw) {
    if (raw == null) return null;
    final cleaned = raw.replaceAll(RegExp(r'[^0-9,.-]'), '').trim();
    if (cleaned.isEmpty) return null;

    String normalized;
    if (cleaned.contains(',') && cleaned.contains('.')) {
      normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else if (cleaned.contains(',')) {
      final parts = cleaned.split(',');
      normalized = parts.last.length == 3
          ? cleaned.replaceAll(',', '')
          : cleaned.replaceAll(',', '.');
    } else if (cleaned.contains('.')) {
      final parts = cleaned.split('.');
      normalized = parts.length > 2 || parts.last.length == 3
          ? cleaned.replaceAll('.', '')
          : cleaned;
    } else {
      normalized = cleaned;
    }

    return num.tryParse(normalized);
  }

  String _formatMoney(String? raw) {
    final value = _parseNumber(raw);
    return value == null ? 'No definido' : _currency.format(value);
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('arrendad')) return const Color(0xFF2563EB);
    if (normalized.contains('vendid')) return const Color(0xFF16A34A);
    if (normalized.contains('dispon')) return const Color(0xFF0EA5E9);
    return const Color(0xFF64748B);
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B4A7F), Color(0xFF1D7EEA)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220F172A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.apartment_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Inmuebles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Aqui puedes ver los inmuebles que tienes asignados, su estado y valores esperados.',
                  style: TextStyle(
                    color: Color(0xFFD8E7FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(List<Inmueble> inmuebles) {
    final total = inmuebles.length;
    final venta = inmuebles.where(_hasSale).length;
    final arriendo = inmuebles.where(_hasRent).length;
    final canonTotal = inmuebles
        .where(_hasRent)
        .map((item) => _parseNumber(item.rentPrice) ?? 0)
        .fold<num>(0, (acc, value) => acc + value);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up_rounded,
                  color: Color(0xFF334155), size: 20),
              SizedBox(width: 8),
              Text(
                'Resumen',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SummaryCard(
                title: 'Total',
                value: '$total',
                borderColor: const Color(0xFFCBD5E1),
                icon: Icons.home_work_outlined,
                textColor: const Color(0xFF334155),
              ),
              _SummaryCard(
                title: 'En venta',
                value: '$venta',
                borderColor: const Color(0xFF93C5FD),
                icon: Icons.domain_verification_outlined,
                textColor: const Color(0xFF2563EB),
              ),
              _SummaryCard(
                title: 'En arriendo',
                value: '$arriendo',
                borderColor: const Color(0xFF86EFAC),
                icon: Icons.verified_rounded,
                textColor: const Color(0xFF16A34A),
              ),
              _SummaryCard(
                title: 'Canon esperado total',
                value: _currency.format(canonTotal),
                borderColor: const Color(0xFFFCD34D),
                icon: Icons.price_change_outlined,
                textColor: const Color(0xFFD97706),
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, Inmueble inmueble) {
    final hasSale = _hasSale(inmueble);
    final hasRent = _hasRent(inmueble);

    return _HoverCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x110F172A),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inmueble.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Registro: ${inmueble.code}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        _statusColor(inmueble.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    inmueble.status,
                    style: TextStyle(
                      color: _statusColor(inmueble.status),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 1080
                    ? 4
                    : constraints.maxWidth > 760
                        ? 2
                        : 1;
                final itemWidth =
                    (constraints.maxWidth - (columns - 1) * 8) / columns;
                final tiles = <Widget>[
                  SizedBox(
                    width: itemWidth,
                    child: _InfoTile(
                      label: 'Ubicacion',
                      value: inmueble.location,
                      icon: Icons.location_on_outlined,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _InfoTile(
                      label: 'Operacion',
                      value: _operationLabel(inmueble),
                      subtitle: 'Estado: ${inmueble.status}',
                    ),
                  ),
                  if (hasSale)
                    SizedBox(
                      width: itemWidth,
                      child: _InfoTile(
                        label: 'Precio venta',
                        value: _formatMoney(inmueble.salePrice),
                      ),
                    ),
                  if (hasRent)
                    SizedBox(
                      width: itemWidth,
                      child: _InfoTile(
                        label: 'Canon esperado',
                        value: _formatMoney(inmueble.rentPrice),
                      ),
                    ),
                  if (!hasSale && !hasRent)
                    SizedBox(
                      width: itemWidth,
                      child: _InfoTile(
                        label: 'Valor',
                        value: inmueble.price,
                      ),
                    ),
                  SizedBox(
                    width: itemWidth,
                    child: _InfoTile(
                      label: 'Area',
                      value: inmueble.area,
                      subtitle:
                          '${inmueble.rooms} hab | ${inmueble.baths} banos',
                    ),
                  ),
                ];

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tiles,
                );
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 145,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PropertyDetailScreen(imagePath: inmueble.imagePath),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF0B61CE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text(
                  'Ver detalles',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<Inmueble> inmuebles) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Column(
              children: [
                _buildHero(),
                const SizedBox(height: 12),
                _buildSummary(inmuebles),
                const SizedBox(height: 12),
                for (final inmueble in inmuebles) ...[
                  _buildPropertyCard(context, inmueble),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          const CustomHeader(title: 'Inicio'),
          Expanded(
            child: FutureBuilder<List<Inmueble>>(
              future: _inmueblesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No se pudieron cargar los inmuebles',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _reload,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final inmuebles = snapshot.data ?? const [];
                if (inmuebles.isEmpty) {
                  return Center(
                    child: Text(
                      'No tienes inmuebles asignados',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    ),
                  );
                }

                return _buildContent(inmuebles);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromRGBO(0, 120, 206, 1),
        unselectedItemColor: const Color.fromRGBO(97, 138, 133, 1),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Reportes',
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color borderColor;
  final Color textColor;
  final IconData icon;
  final bool compact;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.borderColor,
    required this.icon,
    required this.textColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = compact ? 240.0 : 180.0;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: compact ? 18 : 28,
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData? icon;

  const _InfoTile({
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: const Color(0xFF64748B)),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: _isHovered
            ? Matrix4.translationValues(0, -4.0, 0)
            : Matrix4.identity(),
        child: widget.child,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'property_details.dart';

/// 📌 Pantalla que muestra la lista de inmuebles (sin menú)
class TusInmueblesScreen extends StatelessWidget {
  const TusInmueblesScreen({Key? key}) : super(key: key);

  Widget _buildPropertyCard(
    BuildContext context, {
    required String image,
    required String title,
    required String price,
    required String area,
    required String rooms,
    required String baths,
    required bool featured,
  }) {
    return _HoverCard(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Image.asset(
                    image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.home, size: 50, color: Colors.grey),
                      );
                    },
                  ),
                ),
                if (featured)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Destacado',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'El Poblado, Medellín',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIconText(Icons.square_foot, area),
                      _buildIconText(Icons.bed_outlined, rooms),
                      _buildIconText(Icons.bathroom_outlined, baths),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PropertyDetailScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Ver detalles',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Inmuebles',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Fila 1
                  Row(
                    children: [
                      Expanded(
                        child: _buildPropertyCard(
                          context,
                          image: 'assets/images/casa1.jpg',
                          title: 'Apartamento Amoblado',
                          price: '\$2,300/mes',
                          area: '60 m²',
                          rooms: '2 hab',
                          baths: '1 baño',
                          featured: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPropertyCard(
                          context,
                          image: 'assets/images/casa2.jpg',
                          title: 'Apartamento Amoblado',
                          price: '\$2,300/mes',
                          area: '60 m²',
                          rooms: '2 hab',
                          baths: '1 baño',
                          featured: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Fila 2
                  Row(
                    children: [
                      Expanded(
                        child: _buildPropertyCard(
                          context,
                          image: 'assets/images/casa3.jpg',
                          title: 'Casa Familiar',
                          price: '\$3,000/mes',
                          area: '90 m²',
                          rooms: '3 hab',
                          baths: '2 baños',
                          featured: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPropertyCard(
                          context,
                          image: 'assets/images/casa3.jpg',
                          title: 'Apartamento Moderno',
                          price: '\$2,800/mes',
                          area: '70 m²',
                          rooms: '2 hab',
                          baths: '2 baños',
                          featured: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Fila 3
                  Row(
                    children: [
                      Expanded(
                        child: _buildPropertyCard(
                          context,
                          image: 'assets/images/casa5.jpg',
                          title: 'Penthouse de Lujo',
                          price: '\$4,500/mes',
                          area: '120 m²',
                          rooms: '3 hab',
                          baths: '3 baños',
                          featured: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPropertyCard(
                          context,
                          image: 'assets/images/casa6.jpg',
                          title: 'Apartamento Económico',
                          price: '\$1,800/mes',
                          area: '55 m²',
                          rooms: '1 hab',
                          baths: '1 baño',
                          featured: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🌟 Widget que agrega animación de hover (selección al pasar el cursor)
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: _isHovered ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        decoration: BoxDecoration(
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}
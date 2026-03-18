import 'package:flutter/material.dart';

class PropertyDetailScreen extends StatelessWidget {
  final String imagePath; // ✅ Recibe la imagen desde la carta

  const PropertyDetailScreen({Key? key, required this.imagePath}) : super(key: key);

  Widget _buildStatItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color.fromRGBO(0, 120, 206, 1), size: 28),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline,
            color: Color.fromRGBO(0, 120, 206, 1), size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Inmueble'),
        backgroundColor: const Color.fromRGBO(0, 120, 206, 1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ Imagen dinámica recibida desde la carta
            Image.asset(
              imagePath,
              height: 320,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 240,
                color: Colors.grey[300],
                child: const Icon(Icons.home, size: 80, color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Apartamento Amoblado - El Poblado, Medellín',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '\$2,300/mes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(0, 120, 206, 1),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(Icons.home_outlined, 'Área', '96 m²'),
                      _buildStatItem(Icons.door_back_door_outlined, 'Habitaciones', '3'),
                      _buildStatItem(Icons.bathtub_outlined, 'Baños', '2'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(Icons.directions_car_outlined, 'Parqueaderos', '1'),
                      _buildStatItem(Icons.schedule_outlined, 'Antigüedad', '5 años'),
                      _buildStatItem(Icons.account_balance_outlined, 'Tipo', 'Apartamento'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Descripción',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(97, 138, 133, 1)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hermoso apartamento amoblado en zona exclusiva de El Poblado, '
                    'con amplios espacios, excelente iluminación natural, '
                    'y acceso a múltiples vías principales.',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Características destacadas',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(97, 138, 133, 1)),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureItem('Vista panorámica a la ciudad'),
                      const SizedBox(height: 6),
                      _buildFeatureItem('Suite principal con vestidor'),
                      const SizedBox(height: 6),
                      _buildFeatureItem('Cocina integral con isla'),
                      const SizedBox(height: 6),
                      _buildFeatureItem('Sistema de seguridad 24/7'),
                      const SizedBox(height: 6),
                      _buildFeatureItem('Garaje para 2 vehículos'),
                      const SizedBox(height: 6),
                      _buildFeatureItem('Terraza con jacuzzi'),
                    ],
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text(
                        'Volver a tus inmuebles',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(0, 120, 206, 1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
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
}

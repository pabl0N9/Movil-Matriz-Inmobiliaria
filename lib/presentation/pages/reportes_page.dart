import 'package:flutter/material.dart';
import '../../data/models/reporte_model.dart';
import '../../data/repositories/reporte_repository.dart';
import 'nuevo_reporte_page.dart';
import 'detalle_reporte_page.dart';
import '../widgets/menu.dart';
import '../widgets/header.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/citas');
    }
  }

  String searchQuery = '';
  String selectedEstado = 'Todos';
  String selectedTipo = 'Todos';
  String selectedPrioridad = 'Todos';

  final List<String> estados = ['Todos', 'En proceso', 'Cotizando', 'Iniciado', 'Sin novedades', 'Pendiente', 'Completado'];
  final List<String> tipos = ['Todos', 'Casa', 'Apartamento', 'Edificio', 'Local Comercial', 'Oficina', 'Bodega', 'Terreno'];
  final List<String> prioridades = ['Todos', 'Alta', 'Media', 'Baja'];



  String _getPrioridad(dynamic reporte) {
    // Calculamos prioridad basada en el estado
    switch (reporte.estado.toLowerCase()) {
      case 'pendiente':
      case 'sin novedades':
        return 'Alta';
      case 'en proceso':
      case 'iniciado':
        return 'Media';
      default:
        return 'Baja';
    }
  }

  List<dynamic> get filteredReportes {
    final allReportes = ReporteRepository.getAllReportes();
    
    return allReportes.where((reporte) {
      bool matchesEstado = selectedEstado == 'Todos' || reporte.estado == selectedEstado;


      bool matchesTipo = selectedTipo == 'Todos' || reporte.tipoInmueble == selectedTipo;
      bool matchesPrioridad = selectedPrioridad == 'Todos' || _getPrioridad(reporte) == selectedPrioridad;
      bool matchesSearch = searchQuery.isEmpty || 
          (reporte.id != null && reporte.id!.toLowerCase().contains(searchQuery.toLowerCase())) ||
          reporte.titulo.toLowerCase().contains(searchQuery.toLowerCase()) ||
          reporte.ubicacion.toLowerCase().contains(searchQuery.toLowerCase());
      
      return matchesEstado && matchesTipo && matchesPrioridad && matchesSearch;
    }).toList();
  }

  Color getEstadoColor(String estado) {
    switch (estado) {
      case 'En proceso':
        return const Color(0xFF0078CE); // Nuevo color
      case 'Cotizando':
        return Colors.orange;
      case 'Iniciado':
        return Colors.green;
      case 'Sin novedades':
        return Colors.grey;
      case 'Pendiente':
        return Colors.red;
      case 'Completado':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          const CustomHeader(title: 'Reportes'),
          // Header con búsqueda (sin título duplicado)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // Barra de búsqueda
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Buscar reportes...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                
                // Filtros
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Estado', selectedEstado, estados, (value) {
                        setState(() {
                          selectedEstado = value;
                        });
                      }),
                      const SizedBox(width: 10),
                      _buildFilterChip('Tipo', selectedTipo, tipos, (value) {
                        setState(() {
                          selectedTipo = value;
                        });
                      }),
                      const SizedBox(width: 10),
                      _buildFilterChip('Prioridad', selectedPrioridad, prioridades, (value) {
                        setState(() {
                          selectedPrioridad = value;
                        });
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de reportes
          Expanded(
            child: filteredReportes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay reportes disponibles',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredReportes.length,
                    itemBuilder: (context, index) {
                      return _buildReporteCard(filteredReportes[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NuevoReportePage()),
          );

          // Si se creó un reporte exitosamente, refrescar la lista
          if (result == true) {
            setState(() {
              // Esto forzará la reconstrucción del widget y actualizará la lista
            });
          }
        },
        backgroundColor: const Color(0xFF0078CE), // Nuevo color
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
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

  Widget _buildFilterChip(String label, String selectedValue, List<String> options, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                '$label: $value',
                style: TextStyle(
                  fontSize: 12,
                  color: value == 'Todos' ? Colors.grey[600] : const Color(0xFF0078CE), // Nuevo color
                  fontWeight: value == 'Todos' ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          style: const TextStyle(fontSize: 12),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildReporteCard(Reporte reporte) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleReportePage(reporte: reporte),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              
              // Información del reporte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID y Estado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ID: ${reporte.id}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: getEstadoColor(reporte.estado).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: getEstadoColor(reporte.estado).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            reporte.estado,
                            style: TextStyle(
                              fontSize: 10,
                              color: getEstadoColor(reporte.estado),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Título
                    Text(
                      reporte.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Ubicación
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            reporte.ubicacion,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Tipo de inmueble
                    Row(
                      children: [
                        const Icon(Icons.home, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          reporte.tipoInmueble,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Responsable y resumen de rubros
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Responsable: ${reporte.responsable}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${reporte.rubrosCompletados}/${reporte.rubros.length} rubros',
                          style: const TextStyle(
                            fontSize: 11,
                            color: const Color(0xFF0078CE), // Nuevo color
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

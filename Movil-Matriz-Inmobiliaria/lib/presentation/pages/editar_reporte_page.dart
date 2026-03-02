import 'package:flutter/material.dart';
import '../../data/models/reporte_model.dart';
import '../../data/repositories/reporte_repository.dart';

class EditarReportePage extends StatefulWidget {
  final Reporte reporte;

  const EditarReportePage({
    super.key,
    required this.reporte,
  });

  @override
  State<EditarReportePage> createState() => _EditarReportePageState();
}

class _EditarReportePageState extends State<EditarReportePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controladores para los formularios
  late TextEditingController _ubicacionController;
  late TextEditingController _referenciaController;
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _responsableController;
  late TextEditingController _seguimientoController;

  late String _selectedTipoInmueble;
  late String _selectedEstado;
  late String _selectedPrioridad;
  late List<RubroProyecto> _rubros;
  late List<String> _archivos;

  final List<String> _tiposInmueble = [
    'Casa',
    'Apartamento',
    'Edificio',
    'Local Comercial',
    'Oficina',
    'Bodega',
    'Terreno',
  ];

  final List<String> _estados = [
    'Pendiente',
    'En proceso',
    'Cotizando',
    'Iniciado',
    'Sin novedades',
    'Completado',
  ];

  final List<String> _prioridades = [
    'Alto',
    'Medio',
    'Bajo',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Inicializar controladores con datos del reporte
    _ubicacionController = TextEditingController(text: widget.reporte.ubicacion);
    _referenciaController = TextEditingController(text: widget.reporte.referencia);
    _tituloController = TextEditingController(text: widget.reporte.titulo);
    _descripcionController = TextEditingController(text: widget.reporte.descripcion);
    _responsableController = TextEditingController(text: widget.reporte.responsable);
    _seguimientoController = TextEditingController(text: _getSeguimientoGeneral());
    
    _selectedTipoInmueble = widget.reporte.tipoInmueble;
    _selectedEstado = widget.reporte.estado;
    _selectedPrioridad = _getPrioridad();
    _rubros = List.from(widget.reporte.rubros);
    _archivos = List.from(widget.reporte.archivos);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ubicacionController.dispose();
    _referenciaController.dispose();
    _tituloController.dispose();
    _descripcionController.dispose();
    _responsableController.dispose();
    _seguimientoController.dispose();
    super.dispose();
  }

  String _getPrioridad() {
    switch (widget.reporte.estado) {
      case 'Pendiente': // Cambiado de 'Pendiente'
      case 'Sin novedades':
        return 'Alto';
      case 'En proceso':
      case 'Iniciado':
        return 'Medio';
      default:
        return 'Bajo';
    }
  }

  String _getSeguimientoGeneral() {
    switch (widget.reporte.estado) {
      case 'En proceso':
        return 'Se ha iniciado la inspección preliminar. Pendiente coordinación con proveedores para materiales especializados.';
      case 'Pendiente': // Cambiado de 'Pendiente'
        return 'Reporte recibido y en espera de asignación de técnico especializado.';
      case 'Completado': // Cambiado de 'Completado'
        return 'Trabajo finalizado satisfactoriamente. Cliente notificado y conforme.';
      default:
        return 'Seguimiento en proceso. Se actualizará próximamente.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Editar Reporte',
          style: TextStyle(
            color: Color(0xFF0078CE),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFF0078CE),
          indicator: BoxDecoration(
            color: const Color(0xFF0078CE),
            borderRadius: BorderRadius.circular(8),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          isScrollable: false,
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          tabs: const [
            Tab(text: 'Información'),
            Tab(text: 'Detalles'),
            Tab(text: 'Rubros'),
            Tab(text: 'Adjuntos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInformacionTab(),
          _buildDetallesTab(),
          _buildRubrosTab(),
          _buildAdjuntosTab(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0078CE),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Guardar Cambios',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Reporte',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          _buildTextField(
            label: 'Dirección',
            controller: _ubicacionController,
            hint: 'Ubicación del inmueble',
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: 'Fecha',
            controller: TextEditingController(
              text: "${widget.reporte.fechaCreacion.year.toString().padLeft(4, '0')}-${widget.reporte.fechaCreacion.month.toString().padLeft(2, '0')}-${widget.reporte.fechaCreacion.day.toString().padLeft(2, '0')}"
            ),
            enabled: false,
          ),
          const SizedBox(height: 20),

          _buildDropdown(
            label: 'Estado',
            value: _selectedEstado,
            items: _estados,
            onChanged: (value) {
              setState(() {
                _selectedEstado = value!;
              });
            },
          ),
          const SizedBox(height: 20),

          _buildDropdown(
            label: 'Tipo',
            value: _selectedTipoInmueble,
            items: _tiposInmueble,
            onChanged: (value) {
              setState(() {
                _selectedTipoInmueble = value!;
              });
            },
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: 'Título',
            controller: _tituloController,
            hint: 'Título del reporte',
          ),
        ],
      ),
    );
  }

  Widget _buildDetallesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles del Reporte',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          _buildTextField(
            label: 'Descripción',
            controller: _descripcionController,
            hint: 'Descripción detallada del reporte',
            maxLines: 4,
          ),
          const SizedBox(height: 20),

          _buildDropdown(
            label: 'Prioridad',
            value: _selectedPrioridad,
            items: _prioridades,
            onChanged: (value) {
              setState(() {
                _selectedPrioridad = value!;
              });
            },
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: 'Asignado a',
            controller: _responsableController,
            hint: 'Nombre del responsable',
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: 'Seguimiento General',
            controller: _seguimientoController,
            hint: 'Seguimiento del reporte',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildRubrosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rubros del Proyecto',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          ..._rubros.asMap().entries.map((entry) {
            final index = entry.key;
            final rubro = entry.value;
            return _buildRubroCard(rubro, index);
          }),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _agregarRubro,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: Color(0xFF0078CE)),
              ),
              child: const Text(
                '+ Agregar Rubro',
                style: TextStyle(
                  color: Color(0xFF0078CE),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjuntosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adjuntos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Imágenes existentes
          Row(
            children: [
              Expanded(child: _buildImagePlaceholder()),
              const SizedBox(width: 16),
              Expanded(child: _buildImagePlaceholder()),
            ],
          ),
          const SizedBox(height: 20),

          // Botón para agregar imágenes
          _buildAddButton(
            'Agregar imágenes',
            'Arrastra archivos aquí o haz clic para seleccionar',
            () {
              // Implementar selección de imágenes
            },
          ),
          const SizedBox(height: 20),

          // Archivo PDF existente
          _buildFileCard(
            'presupuesto_materiales.pdf',
            '2.3 MB',
            Icons.picture_as_pdf,
          ),
          const SizedBox(height: 20),

          // Botón para agregar documentos
          _buildAddButton(
            'Agregar documentos',
            'PDF, DOC, XLS',
            () {
              // Implementar selección de documentos
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0078CE)),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0096D4)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildRubroCard(RubroProyecto rubro, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Rubro ${index + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _editarRubro(index),
                child: const Text(
                  'Editar',
                  style: TextStyle(color: Color(0xFF0078CE)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Nombre del rubro',
            style: TextStyle(
              fontSize: 14,
              color: const Color.fromARGB(255, 117, 117, 117),
            ),
          ),
          Text(
            rubro.nombre,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Descripción',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            rubro.descripcion,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getEstadoColor(rubro.estado).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        rubro.estado,
                        style: TextStyle(
                          color: _getEstadoColor(rubro.estado),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seguimientos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${rubro.cantidadSeguimientos}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Última actualización',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                // Implementar eliminación de imagen
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF0078CE),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.add,
              color: Color(0xFF0078CE),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0078CE),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard(String fileName, String size, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.red),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  size,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Implementar eliminación de archivo
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _agregarRubro() {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    String selectedEstado = 'Pendiente';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Rubro'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del rubro',
                    hintText: 'Ej: Plomería, Electricidad...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Descripción detallada del rubro...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedEstado,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Pendiente', 'En proceso', 'Completado']
                      .map((estado) => DropdownMenuItem(
                            value: estado,
                            child: Text(estado),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedEstado = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nombreController.text.trim().isNotEmpty &&
                    descripcionController.text.trim().isNotEmpty) {
                  setState(() {
                    _rubros.add(RubroProyecto(
                      id: 'rubro_${DateTime.now().millisecondsSinceEpoch}',
                      nombre: nombreController.text.trim(),
                      descripcion: descripcionController.text.trim(),
                      estado: selectedEstado,
                      listaSeguimientos: const [],
                    ));
                  });
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rubro agregado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0078CE),
              ),
              child: const Text(
                'Agregar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editarRubro(int index) {
    final rubro = _rubros[index];
    final nombreController = TextEditingController(text: rubro.nombre);
    final descripcionController = TextEditingController(text: rubro.descripcion);
    String selectedEstado = rubro.estado;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Rubro'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del rubro',
                    hintText: 'Ej: Plomería, Electricidad...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Descripción detallada del rubro...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedEstado,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Pendiente', 'En proceso', 'Completado']
                      .map((estado) => DropdownMenuItem(
                            value: estado,
                            child: Text(estado),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedEstado = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nombreController.text.trim().isNotEmpty &&
                    descripcionController.text.trim().isNotEmpty) {
                  setState(() {
                    _rubros[index] = rubro.copyWith(
                      nombre: nombreController.text.trim(),
                      descripcion: descripcionController.text.trim(),
                      estado: selectedEstado,
                    );
                  });
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rubro actualizado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0078CE),
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _guardarCambios() {
    try {
      // Validar campos requeridos
      if (_ubicacionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La ubicación es requerida'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_tituloController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El título es requerido'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Crear reporte actualizado
      final reporteActualizado = Reporte(
        id: widget.reporte.id,
        ubicacion: _ubicacionController.text.trim(),
        tipoInmueble: _selectedTipoInmueble,
        referencia: _referenciaController.text.trim(),
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        estado: _selectedEstado,
        responsable: _responsableController.text.trim(),
        rubros: _rubros,
        fechaCreacion: widget.reporte.fechaCreacion,
        archivos: _archivos,
      );

      // Actualizar en el repositorio
      final success = ReporteRepository.updateReporte(widget.reporte.id, reporteActualizado);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Retorna true para indicar que se guardaron cambios
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar el reporte: No se encontró el reporte'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getNotasRubro(String nombreRubro) {
    switch (nombreRubro.toLowerCase()) {
      case 'baños':
        return 'Revisión de tuberías completada. Pendiente cambio de grifería.';
      case 'cocina':
        return 'Grifería instalada correctamente. Trabajo finalizado.';
      case 'ventanas':
        return 'Marcos identificados con deterioro. Pendiente cotización.';
      default:
        return 'Sin notas adicionales.';
    }
  }
  
  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Completado':
        return Colors.green;
      case 'En proceso':
        return const Color(0xFF0078CE);
      case 'Pendiente':
      default:
        return Colors.orange;
    }
  }
}
import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/reporte_model.dart';
import '../../data/repositories/reporte_repository.dart';

class NuevoReportePage extends StatefulWidget {
  const NuevoReportePage({super.key});

  @override
  State<NuevoReportePage> createState() => _NuevoReportePageState();
}

class _NuevoReportePageState extends State<NuevoReportePage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Controladores para los formularios
  final _ubicacionController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _responsableController = TextEditingController();
  final _seguimientoController = TextEditingController();

  String _selectedTipoInmueble = '';
  String _selectedEstado = 'Pendiente';
  List<RubroProyecto> _rubros = [];
  List<String> _archivos = [];
  bool _isStep1Valid = false;

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

  @override
  void initState() {
    super.initState();
    // Agregar listeners para validación en tiempo real
    _ubicacionController.addListener(_validateStep1);
    _referenciaController.addListener(_validateStep1);
    _tituloController.addListener(_validateStep1);
    _descripcionController.addListener(_validateStep1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ubicacionController.dispose();
    _referenciaController.dispose();
    _tituloController.dispose();
    _descripcionController.dispose();
    _responsableController.dispose();
    _seguimientoController.dispose();
    super.dispose();
  }
  
  void _validateStep1() {
    final isValid = _ubicacionController.text.trim().isNotEmpty &&
                   _selectedTipoInmueble.isNotEmpty &&
                   _referenciaController.text.trim().isNotEmpty &&
                   _tituloController.text.trim().isNotEmpty &&
                   _descripcionController.text.trim().isNotEmpty;
    
    if (_isStep1Valid != isValid) {
      setState(() {
        _isStep1Valid = isValid;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _isStep1Valid;
      case 1:
        return true; // Los archivos son opcionales
      case 2:
        return _selectedEstado.isNotEmpty && _responsableController.text.trim().isNotEmpty;
      case 3:
        return true; // Los rubros son opcionales
      default:
        return false;
    }
  }

  void _createReporte() {
    if (!_validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nuevoReporte = Reporte(
      id: '', // Se generará automáticamente
      ubicacion: _ubicacionController.text.trim(),
      tipoInmueble: _selectedTipoInmueble,
      referencia: _referenciaController.text.trim(),
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      estado: _selectedEstado,
      responsable: _responsableController.text.trim(),
      rubros: _rubros,
      archivos: _archivos,
    );

    try {
      final reporteId = ReporteRepository.createReporte(nuevoReporte);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Reporte $reporteId creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true); // Retornar true para indicar éxito
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al crear reporte: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
          'Nuevo Reporte',
          style: TextStyle(
            color: Color(0xFF0078CE),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Indicador de pasos
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index <= _currentStep ? const Color(0xFF0078CE) : Colors.grey[300],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: index <= _currentStep ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (index < 3)
                        Container(
                          width: 40,
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: index < _currentStep ? const Color(0xFF0078CE) : Colors.grey[300],
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),

          // Contenido de los pasos
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(), // Información del Reporte
                _buildStep2(), // Archivos
                _buildStep3(), // Estado y Seguimiento
                _buildStep4(), // Rubros del Proyecto
              ],
            ),
          ),

          // Botones de navegación
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text(
                        'Anterior',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep == 3 ? _createReporte : 
                        (_validateCurrentStep() ? _nextStep : null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078CE),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      _currentStep == 3 ? 'Crear Reporte' : 'Siguiente',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
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
            label: 'Ubicación',
            controller: _ubicacionController,
            hint: 'Seleccionar ubicación',
            required: true,
          ),
          const SizedBox(height: 20),

          _buildDropdownField(
            label: 'Tipo de Inmueble',
            value: _selectedTipoInmueble,
            items: _tiposInmueble,
            onChanged: (value) {
              setState(() {
                _selectedTipoInmueble = value!;
                _validateStep1(); // Validar después del cambio
              });
            },
            required: true,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: 'Referencia',
            controller: _referenciaController,
            hint: 'Ej. Apto 502',
            required: true,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: 'Título del reporte',
            controller: _tituloController,
            hint: 'Ej. Reparación integral apartamento',
            required: true,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: 'Descripción',
            controller: _descripcionController,
            hint: 'Descripción detallada del reporte',
            maxLines: 4,
            required: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Archivos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildFileUploadCard(
                  icon: Icons.add,
                  title: 'Subir imágenes',
                  subtitle: 'Formatos permitidos: JPG, PNG, PDF, DOC, DOCX\nTamaño máximo: 10MB por archivo',
                  onTap: _selectImages,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFileUploadCard(
                  icon: Icons.description,
                  title: 'Subir documentos',
                  subtitle: 'Formatos permitidos: JPG, PNG, PDF, DOC, DOCX\nTamaño máximo: 10MB por archivo',
                  onTap: _selectDocuments,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_archivos.isNotEmpty) ...[
            const Text(
              'Archivos seleccionados:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...(_archivos.map((archivo) => _buildFileItem(archivo))),
          ],
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado y Seguimiento',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          _buildDropdownField(
            label: 'Estado del reporte',
            value: _selectedEstado,
            items: _estados,
            onChanged: (value) {
              setState(() {
                _selectedEstado = value!;
              });
            },
            required: true,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: 'Seguimiento general',
            controller: _seguimientoController,
            hint: 'Información adicional sobre el seguimiento',
            maxLines: 3,
          ),
          const SizedBox(height: 32),

          const Text(
            'Responsable',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          _buildTextField(
            label: 'Nombre del responsable del reporte',
            controller: _responsableController,
            hint: 'Nombre completo',
            required: true,
          ),
          const SizedBox(height: 12),

          Text(
            'Persona encargada de la elaboración y seguimiento del reporte',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF0078CE),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
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

          // Lista de rubros
          ..._rubros.map((rubro) => _buildRubroCard(rubro)),

          // Botón agregar rubro
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: OutlinedButton.icon(
              onPressed: _showAddRubroDialog,
              icon: const Icon(Icons.add, color: Colors.teal),
              label: const Text(
                'Agregar rubro',
                style: TextStyle(color: Colors.teal),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: Colors.teal),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Resumen del proyecto
          const Text(
            'Resumen del Proyecto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: _rubros.length.toString(),
                  subtitle: 'Total rubros',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: _rubros.fold(0, (sum, r) => sum + r.listaSeguimientos.length).toString(),
                  subtitle: 'Seguimientos',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: _rubros.where((r) => r.estado == 'Completado').length.toString(),
                  subtitle: 'Completados',
                  // color: Colors.blue, // removed invalid named parameter
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: _rubros.where((r) => r.estado == 'En proceso').length.toString(),
                  subtitle: 'En proceso',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: _rubros.where((r) => r.estado == 'Pendiente').length.toString(),
                  subtitle: 'Pendientes',
                ),
              ),
            ],
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
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: required ? [
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ] : null,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
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
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: required ? [
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ] : null,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.isEmpty ? null : value,
              hint: Text('Seleccionar $label'),
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.teal),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(String fileName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              setState(() {
                _archivos.remove(fileName);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRubroCard(RubroProyecto rubro) {
    Color estadoColor;
    switch (rubro.estado) {
      case 'En proceso':
        estadoColor = Colors.green;
        break;
      case 'Pendiente':
        estadoColor = Colors.orange;
        break;
      case 'Completado':
        estadoColor = Colors.blue;
        break;
      default:
        estadoColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () => _editRubro(rubro),
      child: Container(
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
                Expanded(
                  child: Text(
                    rubro.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _anularRubro(rubro),
                  child: const Text(
                    'Anular',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            Text(
              rubro.descripcion,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: estadoColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rubro.estado,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0078CE),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _selectImages() {
    // Simular selección de imágenes
    setState(() {
      _archivos.add('imagen_${DateTime.now().millisecondsSinceEpoch}.jpg');
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Imagen agregada (simulación)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _selectDocuments() {
    // Simular selección de documentos
    setState(() {
      _archivos.add('documento_${DateTime.now().millisecondsSinceEpoch}.pdf');
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Documento agregado (simulación)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddRubroDialog() {
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
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
                if (nombreController.text.isNotEmpty) {
                  final nuevoRubro = RubroProyecto(
                    id: 'rubro_${DateTime.now().millisecondsSinceEpoch}',
                    nombre: nombreController.text,
                    descripcion: descripcionController.text,
                    estado: selectedEstado,
                    listaSeguimientos: const [],
                  );
                  
                  setState(() {
                    _rubros.add(nuevoRubro);
                  });
                  
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _editRubro(RubroProyecto rubro) {
    final nombreController = TextEditingController(text: rubro.nombre);
    final descripcionController = TextEditingController(text: rubro.descripcion);
    String selectedEstado = rubro.estado;
    List<Seguimiento> seguimientos = List.from(rubro.listaSeguimientos);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Editar ${rubro.nombre}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del Rubro
                  const Text(
                    'Nombre del Rubro',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Plomería, Electricidad...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descripcionController,
                    decoration: const InputDecoration(
                      hintText: 'Descripción detallada del rubro...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Estado
                  const Text(
                    'Estado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedEstado,
                    decoration: const InputDecoration(
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
                  const SizedBox(height: 24),

                  // Seguimientos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Seguimientos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _agregarSeguimiento(seguimientos, setDialogState),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Agregar'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0078CE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Lista de seguimientos
                  if (seguimientos.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'No hay seguimientos agregados',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...seguimientos.map((seguimiento) => 
                      _buildSeguimientoCard(seguimiento, seguimientos, setDialogState)
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nombreController.text.isNotEmpty) {
                  final rubroActualizado = rubro.copyWith(
                    nombre: nombreController.text,
                    descripcion: descripcionController.text,
                    estado: selectedEstado,
                    listaSeguimientos: seguimientos,
                  );
                  
                  setState(() {
                    final index = _rubros.indexWhere((r) => r.id == rubro.id);
                    if (index != -1) {
                      _rubros[index] = rubroActualizado;
                    }
                  });
                  
                  Navigator.of(context).pop();
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

  Widget _buildSeguimientoCard(Seguimiento seguimiento, List<Seguimiento> seguimientos, StateSetter setDialogState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cambio Row por Wrap para evitar overflow
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${seguimiento.fecha.day.toString().padLeft(2, '0')}/${seguimiento.fecha.month.toString().padLeft(2, '0')}/${seguimiento.fecha.year}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: seguimiento.estado == 'Pendiente' 
                            ? Colors.orange 
                            : seguimiento.estado == 'En proceso'
                                ? Colors.blue
                                : Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        seguimiento.estado,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  seguimiento.descripcion,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: () {
              setDialogState(() {
                seguimientos.remove(seguimiento);
              });
            },
          ),
        ],
      ),
    );
  }

  void _agregarSeguimiento(List<Seguimiento> seguimientos, StateSetter setDialogState) {
    final descripcionController = TextEditingController();
    String selectedEstado = 'Pendiente';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setInnerDialogState) => AlertDialog(
          title: const Text('Agregar Seguimiento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fecha
              ListTile(
                title: const Text('Fecha'),
                subtitle: Text(
                  '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setInnerDialogState(() {
                      selectedDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Estado
              DropdownButtonFormField<String>(
                value: selectedEstado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: ['Pendiente', 'Completado']
                    .map((estado) => DropdownMenuItem(
                          value: estado,
                          child: Text(estado),
                        ))
                    .toList(),
                onChanged: (value) {
                  setInnerDialogState(() {
                    selectedEstado = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción del seguimiento',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (descripcionController.text.isNotEmpty) {
                  final nuevoSeguimiento = Seguimiento(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    fecha: selectedDate,
                    estado: selectedEstado,
                    descripcion: descripcionController.text,
                  );
                  
                  setDialogState(() {
                    seguimientos.add(nuevoSeguimiento);
                  });
                  
                  Navigator.of(context).pop();
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

  void _removeRubro(RubroProyecto rubro) {
    _anularRubro(rubro);
  }

  void _anularRubro(RubroProyecto rubro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anular Rubro'),
        content: Text('¿Estás seguro de que deseas anular el rubro "${rubro.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _rubros.removeWhere((r) => r.id == rubro.id);
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Anular',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
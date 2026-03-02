import 'package:flutter/material.dart';
import '../../data/models/reporte_model.dart';

class EditarRubroPage extends StatefulWidget {
  final RubroProyecto rubro;
  final Function(RubroProyecto) onRubroUpdated;

  const EditarRubroPage({
    super.key,
    required this.rubro,
    required this.onRubroUpdated,
  });

  @override
  State<EditarRubroPage> createState() => _EditarRubroPageState();
}

class _EditarRubroPageState extends State<EditarRubroPage> {
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late String _selectedEstado;
  late List<Seguimiento> _seguimientos;

  final List<String> _estados = [
    'Pendiente',
    'En proceso',
    'Completado',
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.rubro.nombre);
    _descripcionController = TextEditingController(text: widget.rubro.descripcion);
    _selectedEstado = widget.rubro.estado;
    _seguimientos = List.from(widget.rubro.listaSeguimientos);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
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
          'Editar Rubro',
          style: TextStyle(
            color: Color(0xFF0078CE),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'Nombre del Rubro',
              controller: _nombreController,
              hint: 'Ej: Plomería, Electricidad...',
              required: true,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: 'Descripción',
              controller: _descripcionController,
              hint: 'Descripción detallada del rubro...',
              maxLines: 3,
              required: true,
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
            const SizedBox(height: 32),

            const Text(
              'Seguimientos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            if (_seguimientos.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Center(
                  child: Text(
                    'No hay seguimientos registrados',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ..._seguimientos.map((seguimiento) => _buildSeguimientoCard(seguimiento)),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _agregarSeguimiento,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Color(0xFF0078CE)),
                ),
                child: const Text(
                  '+ Agregar Seguimiento',
                  style: TextStyle(
                    color: Color(0xFF0078CE),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
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
            children: required
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0078CE)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
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
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0078CE)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSeguimientoCard(Seguimiento seguimiento) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getEstadoColor(seguimiento.estado).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getSeguimientoIcon(seguimiento.estado),
                color: _getEstadoColor(seguimiento.estado),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getEstadoColor(seguimiento.estado).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          seguimiento.estado,
                          style: TextStyle(
                            color: _getEstadoColor(seguimiento.estado),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(seguimiento.fecha),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    seguimiento.descripcion,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
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

  IconData _getSeguimientoIcon(String estado) {
    switch (estado) {
      case 'Completado':
        return Icons.check_circle;
      case 'En proceso':
        return Icons.access_time;
      case 'Pendiente':
      default:
        return Icons.pending;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _agregarSeguimiento() {
    final descripcionController = TextEditingController();
    String selectedEstado = 'Pendiente';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Seguimiento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Descripción del seguimiento...',
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
                  items: _estados
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
                if (descripcionController.text.trim().isNotEmpty) {
                  setState(() {
                    _seguimientos.add(Seguimiento(
                      id: 'seg_${DateTime.now().millisecondsSinceEpoch}',
                      fecha: DateTime.now(),
                      estado: selectedEstado,
                      descripcion: descripcionController.text.trim(),
                    ));
                  });
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Seguimiento agregado exitosamente'),
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

  void _guardarCambios() {
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre del rubro es requerido'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La descripción es requerida'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final rubroActualizado = widget.rubro.copyWith(
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      estado: _selectedEstado,
      listaSeguimientos: _seguimientos,
    );

    widget.onRubroUpdated(rubroActualizado);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rubro actualizado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop(true);
  }
}
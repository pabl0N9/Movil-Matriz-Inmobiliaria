import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../models/cita_model.dart';

class CrearCitaDialog extends StatefulWidget {
  const CrearCitaDialog({super.key});

  @override
  State<CrearCitaDialog> createState() => _CrearCitaDialogState();
}

class _CrearCitaDialogState extends State<CrearCitaDialog> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Paso 1: Datos personales
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _numeroDocumentoController = TextEditingController();
  TipoDocumento _tipoDocumento = TipoDocumento.cedula;

  // Paso 2: Fecha y hora
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  // Paso 3: Servicio y detalles
  // final _servicioController = TextEditingController();
  final _detallesController = TextEditingController();
  EstadoCita _estado = EstadoCita.programada;

  String? _servicioSeleccionado;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _numeroDocumentoController.dispose();
    // _servicioController.dispose();
    _detallesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stepper(
                currentStep: _currentStep,
                onStepContinue: _onStepContinue,
                onStepCancel: _onStepCancel,
                controlsBuilder: _buildControls,
                steps: [
                  Step(
                    title: const Text('Datos Personales'),
                    content: _buildPaso1(),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Fecha y Hora'),
                    content: _buildPaso2(),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Servicio y Detalles'),
                    content: _buildPaso3(),
                    isActive: _currentStep >= 2,
                    state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF0A4B84),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Nueva Cita',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPaso1() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre Completo *',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _telefonoController,
            decoration: const InputDecoration(
              labelText: 'Teléfono *',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El teléfono es requerido';
              }
              if (value.length < 7) {
                return 'Teléfono inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _correoController,
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico *',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El correo es requerido';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Correo inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TipoDocumento>(
            value: _tipoDocumento,
            decoration: const InputDecoration(
              labelText: 'Tipo de Documento *',
              prefixIcon: Icon(Icons.badge),
            ),
            items: TipoDocumento.values.map((tipo) {
              return DropdownMenuItem(
                value: tipo,
                child: Text(_getTipoDocumentoTexto(tipo)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _tipoDocumento = value);
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _numeroDocumentoController,
            decoration: const InputDecoration(
              labelText: 'Número de Documento *',
              prefixIcon: Icon(Icons.numbers),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El número de documento es requerido';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaso2() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_today, color: Color(0xFF0A4B84)),
          title: Text(
            _fechaSeleccionada != null
                ? DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!)
                : 'Seleccionar Fecha',
            style: TextStyle(
              color: _fechaSeleccionada != null ? Colors.black87 : Colors.black38,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _seleccionarFecha,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _fechaSeleccionada != null
                  ? const Color(0xFF0A4B84)
                  : Colors.black12,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.access_time, color: Color(0xFF0A4B84)),
          title: Text(
            _horaSeleccionada != null
                ? _horaSeleccionada!.format(context)
                : 'Seleccionar Hora',
            style: TextStyle(
              color: _horaSeleccionada != null ? Colors.black87 : Colors.black38,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _seleccionarHora,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _horaSeleccionada != null
                  ? const Color(0xFF0A4B84)
                  : Colors.black12,
            ),
          ),
        ),
        if (_fechaSeleccionada != null && _horaSeleccionada != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A4B84).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF0A4B84)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cita agendada para ${DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!)} a las ${_horaSeleccionada!.format(context)}',
                    style: const TextStyle(
                      color: Color(0xFF0A4B84),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaso3() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _servicioSeleccionado,
          decoration: const InputDecoration(
            labelText: 'Servicio *',
            prefixIcon: Icon(Icons.medical_services),
          ),
          items: const [
            DropdownMenuItem(value: 'avaluos', child: Text('Avaluos')),
            DropdownMenuItem(value: 'gestion de alquileres', child: Text('Gestion de Alquileres')),
            DropdownMenuItem(value: 'asesoria legal', child: Text('Asesoria Legal')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El servicio es requerido';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _servicioSeleccionado = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _detallesController,
          decoration: const InputDecoration(
            labelText: 'Detalles Adicionales',
            prefixIcon: Icon(Icons.notes),
            hintText: 'Información adicional sobre la cita...',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<EstadoCita>(
          value: _estado,
          decoration: const InputDecoration(
            labelText: 'Estado Inicial',
            prefixIcon: Icon(Icons.flag),
          ),
          items: [
            DropdownMenuItem(
              value: EstadoCita.programada,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFA726),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Programada'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: EstadoCita.confirmada,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF42A5F5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Confirmada'),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _estado = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: details.onStepCancel,
              child: const Text('Atrás'),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: details.onStepContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A4B84),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(_currentStep == 2 ? 'Crear Cita' : 'Siguiente'),
          ),
        ],
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_fechaSeleccionada == null || _horaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona fecha y hora'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 2) {
      if (_servicioSeleccionado == null || _servicioSeleccionado!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona el servicio'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      _crearCita();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0A4B84),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _fechaSeleccionada = picked);
    }
  }

  void _seleccionarHora() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0A4B84),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _horaSeleccionada = picked);
    }
  }

  void _crearCita() {
    final fechaHora = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      _horaSeleccionada!.hour,
      _horaSeleccionada!.minute,
    );

    final cita = Cita(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombreCompleto: _nombreController.text,
      telefono: _telefonoController.text,
      correo: _correoController.text,
      tipoDocumento: _tipoDocumento,
      numeroDocumento: _numeroDocumentoController.text,
      fechaHora: fechaHora,
      servicio: _servicioSeleccionado ?? '',
      detalles: _detallesController.text,
      estado: _estado,
      fechaCreacion: DateTime.now(),
    );

    Navigator.pop(context, cita);
  }

  String _getTipoDocumentoTexto(TipoDocumento tipo) {
    switch (tipo) {
      case TipoDocumento.cedula:
        return 'Cédula';
      case TipoDocumento.pasaporte:
        return 'Pasaporte';
      case TipoDocumento.tarjetaIdentidad:
        return 'Tarjeta de Identidad';
      case TipoDocumento.registroCivil:
        return 'Registro Civil';
    }
  }
}

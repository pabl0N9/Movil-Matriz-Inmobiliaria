import 'package:flutter/material.dart';


import '../../models/cita_model.dart';
import '../../services/citas_service.dart';
import '../widgets/citas/estadisticas_cards.dart';
import '../widgets/citas/barra_busqueda.dart';
import '../widgets/citas/filtros_bar.dart';
import '../widgets/citas/calendario_widget.dart';
import '../widgets/citas/lista_citas_dia.dart';
import '../widgets/citas/crear_cita_dialog.dart';
import '../widgets/citas/editar_cita_dialog.dart';
import '../widgets/citas/ver_cita_dialog.dart';
import '../widgets/citas/lista_vista_widget.dart';
import '../widgets/header.dart';

class CitasPage extends StatefulWidget {
  const CitasPage({super.key});

  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushNamed(context, '/home');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/reports');
    }
  }

  final CitasService _citasService = CitasService();
  final TextEditingController _busquedaController = TextEditingController();

  List<Cita> _todasLasCitas = [];
  List<Cita> _citasFiltradas = [];
  Map<DateTime, List<Cita>> _citasPorFecha = {};
  Map<EstadoCita, int> _estadisticas = {};

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  EstadoCita? _estadoFiltro;
  DateTime? _fechaInicioFiltro;
  DateTime? _fechaFinFiltro;
  bool _vistaCalendario = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _cargarCitas();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarCitas() async {
    final citas = await _citasService.obtenerCitas();
    final estadisticas = await _citasService.obtenerEstadisticas();

    setState(() {
      _todasLasCitas = citas;
      _citasFiltradas = citas;
      _estadisticas = estadisticas;
      _actualizarCitasPorFecha();
    });
  }

  void _actualizarCitasPorFecha() {
    _citasPorFecha.clear();
    for (var cita in _citasFiltradas) {
      final fecha = DateTime(cita.fechaHora.year, cita.fechaHora.month, cita.fechaHora.day);
      _citasPorFecha.putIfAbsent(fecha, () => []).add(cita);
    }
  }

  void _aplicarFiltros() {
    List<Cita> resultado = List.from(_todasLasCitas);

    // Filtro por búsqueda
    if (_busquedaController.text.isNotEmpty) {
      final query = _busquedaController.text.toLowerCase();
      resultado = resultado.where((c) {
        return c.nombreCompleto.toLowerCase().contains(query) ||
               c.telefono.contains(query) ||
               c.correo.toLowerCase().contains(query) ||
               c.numeroDocumento.contains(query) ||
               c.servicio.toLowerCase().contains(query);
      }).toList();
    }

    // Filtro por estado
    if (_estadoFiltro != null) {
      resultado = resultado.where((c) => c.estado == _estadoFiltro).toList();
    }

    // Filtro por rango de fechas
    if (_fechaInicioFiltro != null && _fechaFinFiltro != null) {
      resultado = resultado.where((c) {
        return c.fechaHora.isAfter(_fechaInicioFiltro!) &&
               c.fechaHora.isBefore(_fechaFinFiltro!.add(const Duration(days: 1)));
      }).toList();
    }

    setState(() {
      _citasFiltradas = resultado;
      _actualizarCitasPorFecha();
    });
  }

  List<Cita> _obtenerCitasDelDia(DateTime dia) {
    final fecha = DateTime(dia.year, dia.month, dia.day);
    return _citasPorFecha[fecha] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final citasDelDiaSeleccionado = _obtenerCitasDelDia(_selectedDay ?? _focusedDay);

    return DragTarget<Cita>(
      onWillAccept: (data) => true,
      onAccept: (cita) {
        // Cuando se suelta una cita en el área general, no hacemos nada
      },
      builder: (context, candidateData, rejectedData) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: Column(
            children: [
              const CustomHeader(title: 'Citas'),
              // Estadísticas
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: EstadisticasCards(
                  estadisticas: _estadisticas,
                  total: _todasLasCitas.length,
                  onEstadoTap: (estado) {
                    setState(() {
                      _estadoFiltro = estado;
                      _aplicarFiltros();
                    });
                  },
                ),
              ),

              // Barra de búsqueda
              BarraBusqueda(
                controller: _busquedaController,
                onChanged: (value) {
                  setState(() {
                    _aplicarFiltros();
                  });
                },
                onClear: () {
                  _busquedaController.clear();
                  setState(() {
                    _aplicarFiltros();
                  });
                },
              ),

              // Filtros
              FiltrosBar(
                estadoSeleccionado: _estadoFiltro,
                fechaInicio: _fechaInicioFiltro,
                fechaFin: _fechaFinFiltro,
                onEstadoChanged: (estado) {
                  setState(() {
                    _estadoFiltro = estado;
                    _aplicarFiltros();
                  });
                },
                onFechasChanged: (inicio, fin) {
                  setState(() {
                    _fechaInicioFiltro = inicio;
                    _fechaFinFiltro = fin;
                    _aplicarFiltros();
                  });
                },
                onLimpiarFiltros: () {
                  setState(() {
                    _estadoFiltro = null;
                    _fechaInicioFiltro = null;
                    _fechaFinFiltro = null;
                    _busquedaController.clear();
                    _aplicarFiltros();
                  });
                },
              ),

              // Botón cambiar vista
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: true,
                            label: Text('Calendario'),
                            icon: Icon(Icons.calendar_month),
                          ),
                          ButtonSegment(
                            value: false,
                            label: Text('Lista'),
                            icon: Icon(Icons.list),
                          ),
                        ],
                        selected: {_vistaCalendario},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            _vistaCalendario = newSelection.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Contenido principal
              Expanded(
                child: _vistaCalendario ? _buildVistaCalendario(citasDelDiaSeleccionado) : _buildVistaLista(),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _mostrarDialogoCrearCita,
            backgroundColor: const Color(0xFF0A4B84),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Nueva Cita', style: TextStyle(color: Colors.white)),
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
      },
    );
  }

  Widget _buildVistaCalendario(List<Cita> citasDelDia) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Calendario con drag target
          DragTarget<Cita>(
            onWillAccept: (data) => true,
            onAccept: (cita) {
              // No hacemos nada aquí, el drag se maneja en los días individuales
            },
            builder: (context, candidateData, rejectedData) {
              return CalendarioWidget(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                citasPorFecha: _citasPorFecha,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                onCitaDraggedToNewDate: _reagendarCita,
              );
            },
          ),

          const SizedBox(height: 16),

          // Lista de citas del día con drag target
          DragTarget<Cita>(
            onWillAccept: (data) => true,
            onAccept: (cita) {
              if (_selectedDay != null) {
                _reagendarCita(cita, _selectedDay!);
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                decoration: candidateData.isNotEmpty
                    ? BoxDecoration(
                        color: const Color(0xFF0A4B84).withOpacity(0.1),
                        border: Border.all(color: const Color(0xFF0A4B84), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: ListaCitasDia(
                  citas: citasDelDia,
                  onCitaTap: _mostrarDialogoVerCita,
                  onEstadoChange: _cambiarEstadoCita,
                  onEdit: _mostrarDialogoEditarCita,
                  onDelete: _eliminarCita,
                  onDragToNewDate: _reagendarCita,
                ),
              );
            },
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildVistaLista() {
    return ListaVistaWidget(
      citas: _citasFiltradas,
      onCitaTap: _mostrarDialogoVerCita,
      onEstadoChange: _cambiarEstadoCita,
      onEdit: _mostrarDialogoEditarCita,
      onDelete: _eliminarCita,
    );
  }

  // CRUD Operations

  Future<void> _mostrarDialogoCrearCita() async {
    final Cita? nuevaCita = await showGeneralDialog<Cita>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const CrearCitaDialog(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );

    if (nuevaCita != null) {
      final exito = await _citasService.crearCita(nuevaCita);
      if (exito && mounted) {
        _mostrarMensaje('Cita creada exitosamente', Colors.green);
        _cargarCitas();
      } else if (mounted) {
        _mostrarMensaje('Error al crear la cita', Colors.red);
      }
    }
  }

  Future<void> _mostrarDialogoEditarCita(Cita cita) async {
    final bool? confirmar = await _mostrarDialogoConfirmacion(
      '¿Editar cita?',
      '¿Estás seguro de que deseas editar esta cita?',
    );

    if (confirmar != true) return;

    if (!mounted) return;

    final Cita? citaEditada = await showGeneralDialog<Cita>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => EditarCitaDialog(cita: cita),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );

    if (citaEditada != null) {
      final exito = await _citasService.actualizarCita(citaEditada);
      if (exito && mounted) {
        _mostrarMensaje('Cita actualizada exitosamente', Colors.green);
        _cargarCitas();
      } else if (mounted) {
        _mostrarMensaje('Error al actualizar la cita', Colors.red);
      }
    }
  }

  Future<void> _mostrarDialogoVerCita(Cita cita) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => VerCitaDialog(cita: cita),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _eliminarCita(Cita cita) async {
    final bool? confirmar = await _mostrarDialogoConfirmacion(
      '¿Eliminar cita?',
      '¿Estás seguro de que deseas eliminar esta cita? Esta acción no se puede deshacer.',
    );

    if (confirmar != true) return;

    final exito = await _citasService.eliminarCita(cita.id);
    if (exito && mounted) {
      _mostrarMensaje('Cita eliminada exitosamente', Colors.green);
      _cargarCitas();
    } else if (mounted) {
      _mostrarMensaje('Error al eliminar la cita', Colors.red);
    }
  }

  Future<void> _cambiarEstadoCita(Cita cita) async {
    final EstadoCita? nuevoEstado = await showDialog<EstadoCita>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: EstadoCita.values.map((estado) {
            return ListTile(
              leading: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: cita.copyWith(estado: estado).estadoColor,
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(cita.copyWith(estado: estado).estadoTexto),
              onTap: () => Navigator.pop(context, estado),
            );
          }).toList(),
        ),
      ),
    );

    if (nuevoEstado == null || nuevoEstado == cita.estado) return;

    final bool? confirmar = await _mostrarDialogoConfirmacion(
      '¿Cambiar estado?',
      '¿Estás seguro de que deseas cambiar el estado de esta cita?',
    );

    if (confirmar != true) return;

    final citaActualizada = cita.copyWith(estado: nuevoEstado);
    final exito = await _citasService.actualizarCita(citaActualizada);

    if (exito && mounted) {
      _mostrarMensaje('Estado actualizado exitosamente', Colors.green);
      _cargarCitas();
    } else if (mounted) {
      _mostrarMensaje('Error al actualizar el estado', Colors.red);
    }
  }

  Future<void> _reagendarCita(Cita cita, DateTime nuevaFecha) async {
    final bool? confirmar = await _mostrarDialogoConfirmacion(
      '¿Reagendar cita?',
      '¿Deseas mover esta cita a la nueva fecha?',
    );

    if (confirmar != true) return;

    final nuevaFechaHora = DateTime(
      nuevaFecha.year,
      nuevaFecha.month,
      nuevaFecha.day,
      cita.fechaHora.hour,
      cita.fechaHora.minute,
    );

    final citaActualizada = cita.copyWith(fechaHora: nuevaFechaHora);
    final exito = await _citasService.actualizarCita(citaActualizada);

    if (exito && mounted) {
      _mostrarMensaje('Cita reagendada exitosamente', Colors.green);
      _cargarCitas();
      setState(() {
        _selectedDay = nuevaFecha;
      });
    } else if (mounted) {
      _mostrarMensaje('Error al reagendar la cita', Colors.red);
    }
  }

  // Helpers

  Future<bool?> _mostrarDialogoConfirmacion(String titulo, String mensaje) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A4B84),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}


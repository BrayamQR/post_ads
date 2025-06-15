import 'package:flutter/material.dart';
import 'package:post_ads/models/generic_list.dart';
import 'package:post_ads/services/genericList_service.dart';

class FilterUserView extends StatefulWidget {
  final String? initialNombre;
  final GenericList? initialTipoUsuario;
  final String? initialUsuarioOEmail;

  const FilterUserView({
    super.key,
    this.initialNombre,
    this.initialTipoUsuario,
    this.initialUsuarioOEmail,
  });

  @override
  State<FilterUserView> createState() => _FilterUserViewState();
}

class _FilterUserViewState extends State<FilterUserView> {
  final _formKey = GlobalKey<FormState>();
  String? _nombre;
  String? _usuarioOEmail;
  GenericList? _tipoUsuario;
  final GenericListService _genericListService = GenericListService();
  List<GenericList> tiposUsuario = [];

  @override
  void initState() {
    super.initState();
    _nombre = widget.initialNombre;
    _usuarioOEmail = widget.initialUsuarioOEmail;
    _tipoUsuario = widget.initialTipoUsuario;

    Future.wait([cargarTiposUsuario()]).then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> cargarTiposUsuario() async {
    tiposUsuario = await _genericListService.fetchTiposUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return _buildFilterUserView();
  }

  Widget _buildFilterUserView() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Card(
            color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle visual para modal
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtrar usuarios',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _nombre,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Nombre',
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.indigo.shade400,
                            ),
                          ),
                          onChanged: (value) {
                            _nombre = value.trim();
                          },
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<GenericList>(
                          value: _tipoUsuario,
                          items:
                              tiposUsuario
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item.description ?? ''),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _tipoUsuario = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Tipo de usuario',
                            prefixIcon: Icon(
                              Icons.verified_user,
                              color: Colors.teal.shade400,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        TextFormField(
                          initialValue: _usuarioOEmail,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Usuario o Email',
                            prefixIcon: Icon(
                              Icons.alternate_email,
                              color: Colors.orange.shade400,
                            ),
                          ),
                          onChanged: (value) {
                            _usuarioOEmail = value.trim();
                          },
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: () {
                                  final filtros = {
                                    'nombre': _nombre,
                                    'tipoUsuario': _tipoUsuario,
                                    'usuarioOEmail': _usuarioOEmail,
                                  };
                                  Navigator.pop(context, filtros);
                                },
                                icon: const Icon(Icons.search),
                                label: const Text('Aplicar filtros'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.red.shade400,
                              ),
                              tooltip: 'Limpiar filtros',
                              onPressed: () {
                                setState(() {
                                  _nombre = null;
                                  _tipoUsuario = null;
                                  _usuarioOEmail = null;
                                });
                                Navigator.pop(context, true);
                              },
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
        ),
      ),
    );
  }
}

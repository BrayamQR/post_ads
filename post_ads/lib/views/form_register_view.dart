import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:post_ads/models/generic_list.dart';
import 'package:post_ads/models/usuario.dart';
import 'package:post_ads/services/genericList_service.dart';
import 'package:post_ads/services/session_manager.dart';
import 'package:post_ads/services/usuario_service.dart';
import 'package:lottie/lottie.dart';

class FormRegisterView extends StatefulWidget {
  const FormRegisterView({super.key});

  @override
  State<FormRegisterView> createState() => _FormRegisterViewState();
}

class _FormRegisterViewState extends State<FormRegisterView> {
  final UsuarioService _usuarioService = UsuarioService();

  Usuario? usuario;

  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  final _nomUsuarioKey = GlobalKey<FormFieldState>();
  final _apeUsuarioKey = GlobalKey<FormFieldState>();
  final _userNameKey = GlobalKey<FormFieldState>();
  final _emailUsuarioKey = GlobalKey<FormFieldState>();
  final _passUsuarioKey = GlobalKey<FormFieldState>();
  final _confirmPassUsuarioKey = GlobalKey<FormFieldState>();
  final _tipoUsuarioKey = GlobalKey<FormFieldState>();

  final TextEditingController _nomUsuarioController = TextEditingController();
  final TextEditingController _apeUsuarioController = TextEditingController();
  final TextEditingController _emailUsuarioController = TextEditingController();
  final TextEditingController _passUsuarioController = TextEditingController();
  final TextEditingController _confirmPassUsuarioController =
      TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  GenericList? _tipoUsuario;
  final GenericListService _genericListService = GenericListService();
  List<GenericList> tiposUsuario = [];
  bool _loading = true;

  @override
  void initState() {
    _loading = true;
    _confirmPassUsuarioController.addListener(() {
      _confirmPassUsuarioKey.currentState?.validate();
      setState(() {});
    });

    _passUsuarioController.addListener(() {
      _confirmPassUsuarioKey.currentState?.validate();
    });
    Future.wait([cargarTiposUsuario(), _loadUser()]).then((_) {
      setState(() {
        _loading = false;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _nomUsuarioController.dispose();
    _apeUsuarioController.dispose();
    _emailUsuarioController.dispose();
    _passUsuarioController.dispose();
    _confirmPassUsuarioController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final u = await SessionManager.getUsuario();
    setState(() {
      usuario = u;
    });
  }

  Future<void> cargarTiposUsuario() async {
    tiposUsuario = await _genericListService.fetchTiposUsuario();

    if (_tipoUsuario != null) {
      final match = tiposUsuario.where((cat) => cat.id == _tipoUsuario!.id);
      if (match.isNotEmpty) {
        setState(() {
          _tipoUsuario = match.first;
        });
      }
    }
    setState(() {});
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'nomUsuario': _nomUsuarioController.text.trim(),
      'apeUsuario': _apeUsuarioController.text.trim(),
      'userName': _userNameController.text.trim(),
      'emailUsuario': _emailUsuarioController.text.trim(),
      'passUsuario': _passUsuarioController.text.trim(),
      'idTipoUsuario': _tipoUsuario?.id,
    };

    try {
      final result = await _usuarioService.registerUsuario(data);
      final mensaje = result['message'] ?? 'Usuario registrado';
      if (result['user'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        // Si es un error, muestra el mensaje en rojo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar: $e'),
          backgroundColor: Colors.red, // Error: rojo
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFormRegisterView();
  }

  Widget _buildFormRegisterView() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Lottie.asset(
                              'assets/lottie/register.json',
                              height: 150,
                              reverse: true,
                              repeat: true,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Registro de usuario',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Colors.indigo.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              key: _nomUsuarioKey,
                              controller: _nomUsuarioController,
                              decoration: InputDecoration(
                                labelText: 'Nombres *',
                                border: OutlineInputBorder(),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              key: _apeUsuarioKey,
                              controller: _apeUsuarioController,
                              decoration: InputDecoration(
                                labelText: 'Apellidos *',
                                border: OutlineInputBorder(),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 20),
                            TextFormField(
                              key: _userNameKey,
                              controller: _userNameController,
                              decoration: InputDecoration(
                                labelText: 'Usuario *',
                                border: OutlineInputBorder(),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              key: _passUsuarioKey,
                              controller: _passUsuarioController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña *',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              key: _confirmPassUsuarioKey,
                              controller: _confirmPassUsuarioController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Confirmar contraseña *',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                if (value != _passUsuarioController.text) {
                                  return 'Las contraseñas no coinciden';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _confirmPassUsuarioKey.currentState?.validate();
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              key: _emailUsuarioKey,
                              controller: _emailUsuarioController,
                              decoration: InputDecoration(
                                labelText: 'Correo electrónico *',
                                hintText: 'Ej. ejemplo@gmail.com',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Este campo es obligatorio';
                                }

                                final emailRegex = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Correo inválido';
                                }

                                return null;
                              },
                            ),
                            if (usuario != null &&
                                usuario?.idTipoUsuario == 1) ...[
                              const SizedBox(height: 20),

                              DropdownButtonFormField<GenericList>(
                                key: _tipoUsuarioKey,
                                value: _tipoUsuario,

                                items:
                                    tiposUsuario
                                        .map(
                                          (item) =>
                                              DropdownMenuItem<GenericList>(
                                                value: item,
                                                child: Text(
                                                  item.description ?? '',
                                                ),
                                              ),
                                        )
                                        .toList(),
                                onChanged: (GenericList? value) async {
                                  _tipoUsuario = value;
                                  _tipoUsuarioKey.currentState?.validate();
                                  setState(() {});
                                },

                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Tipo de usuario *',
                                ),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Este campo es obligatorio';
                                  }
                                  return null;
                                },
                              ),
                            ],

                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '* Campos obligatorios',
                                style: TextStyle(color: Colors.red.shade900),
                                textAlign: TextAlign.left,
                              ),
                            ),

                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: MaterialButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _handleRegister();
                                  }
                                  setState(() {});
                                },
                                color: Colors.indigo.shade800,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Registrar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
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
                ),
              ),
    );
  }
}

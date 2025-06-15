import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:post_ads/models/usuario.dart';
import 'package:post_ads/services/auth_service.dart';
import 'dart:convert';
import 'package:post_ads/services/session_manager.dart';
import 'package:post_ads/services/usuario_service.dart';
import 'package:post_ads/views/forgot_password_view.dart';
import 'package:post_ads/views/form_register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final storage = FlutterSecureStorage();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final UsuarioService _usuarioService = UsuarioService();

  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  late final AppLinks _appLinks;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.scheme == 'yourapp' && uri.host == 'callback') {
        final token = uri.queryParameters['token'];
        final userJson = uri.queryParameters['user'];
        if (token != null && userJson != null) {
          final usuario = Usuario.fromJson(jsonDecode(userJson));

          await SessionManager.saveUsuario(usuario);
          await SessionManager.saveToken(token);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido, ${usuario.nomUsuario}!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión: $e'),
          backgroundColor: Colors.red, // Error: rojo
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final result = await _usuarioService.login(
        _userController.text.trim(),
        _passController.text.trim(),
      );
      final mensaje = result['message'] ?? '¡Bienvenido!';
      if (result['user'] != null && result['token'] != null) {
        final usuario = Usuario.fromJson(result['user']);
        final token = result['token'];
        await SessionManager.saveUsuario(usuario);
        await SessionManager.saveToken(token);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
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
          content: Text('Error al iniciar sesión: $e'),
          backgroundColor: Colors.red, // Error: rojo
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildLoginView();
  }

  Widget _buildLoginView() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Lottie.asset(
                      'assets/lottie/user.json',
                      height: 150,
                      reverse: true,
                      repeat: true,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _userController,
                      decoration: const InputDecoration(
                        labelText: 'Usuario o correo electronico',
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
                      controller: _passController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
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
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordView(),
                            ),
                          );
                        },
                        child: Text(
                          "¿Olvidaste tu contraseña?",
                          style: TextStyle(
                            color: Colors.deepPurple.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    SizedBox(
                      width: double.infinity,
                      child: MaterialButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () {
                                  if (_formKey.currentState!.validate()) {
                                    _handleLogin();
                                  }
                                },
                        color: Colors.indigo.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Ingresar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('O'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Image.asset('assets/logo_google.png', height: 20),
                        label: const Text(
                          'Iniciar sesión con Google',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                      ),
                    ),

                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("¿No tienes una cuenta? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FormRegisterView(),
                              ),
                            );
                          },
                          child: Text(
                            "Regístrate aquí",
                            style: TextStyle(
                              color: Colors.deepPurple.shade900,
                              fontWeight: FontWeight.bold,
                            ),
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

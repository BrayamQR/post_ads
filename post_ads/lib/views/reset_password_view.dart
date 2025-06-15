import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:post_ads/services/usuario_service.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;
  final String code;
  const ResetPasswordView({super.key, required this.email, required this.code});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  bool _isLoading = false;
  final UsuarioService _usuarioService = UsuarioService();

  @override
  Widget build(BuildContext context) {
    return _buildResetPasswordView();
  }

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final result = await _usuarioService.resetPassword(
        email: widget.email,
        code: widget.code,
        newPassword: _passController.text.trim(),
      );
      final mensaje = result['message'] ?? 'Contraseña actualizada';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor:
              result['success'] ? Colors.green : Colors.red.shade700,
        ),
      );

      if (result['success']) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildResetPasswordView() {
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Lottie.asset(
                    'assets/lottie/restore_password.json',
                    height: 150,
                    reverse: true,
                    repeat: true,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    'Ingresa tu nueva contraseña',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nueva contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (value.length < 6) {
                      return 'Debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _confirmPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (value != _passController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save, color: Colors.white),
                    label:
                        _isLoading
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'Guardar nueva contraseña',
                              style: TextStyle(color: Colors.white),
                            ),
                    onPressed: _isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

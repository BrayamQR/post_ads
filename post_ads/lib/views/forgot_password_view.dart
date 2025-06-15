import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:post_ads/services/usuario_service.dart';
import 'package:post_ads/views/verify_code_view.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  final UsuarioService _usuarioService = UsuarioService();

  @override
  Widget build(BuildContext context) {
    return _buildForgotPasswordView();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    try {
      final result = await _usuarioService.sendRecoveryCode(email);
      final mensaje = result['message'] ?? 'Revisa tu correo';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor:
              result['success'] ? Colors.green : Colors.red.shade700,
        ),
      );

      if (result['success']) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VerifyCodeView(email: email)),
        );
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

  Widget _buildForgotPasswordView() {
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
                const SizedBox(height: 10),
                Center(
                  child: Lottie.asset(
                    'assets/lottie/forgot_password.json',
                    height: 200,
                    reverse: true,
                    repeat: true,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Ingresa tu correo electrónico registrado y te enviaremos un código para restablecer tu contraseña.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Correo no válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send, color: Colors.white),
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
                              'Enviar código',
                              style: TextStyle(color: Colors.white),
                            ),
                    onPressed: _isLoading ? null : _handleSendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

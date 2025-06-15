import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:post_ads/services/usuario_service.dart';
import 'package:post_ads/utils/get_styles.dart';
import 'package:post_ads/views/reset_password_view.dart';

class VerifyCodeView extends StatefulWidget {
  final String email;
  const VerifyCodeView({super.key, required this.email});

  @override
  State<VerifyCodeView> createState() => _VerifyCodeViewState();
}

class _VerifyCodeViewState extends State<VerifyCodeView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  final UsuarioService _usuarioService = UsuarioService();

  int _secondsLeft = 900;
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleVerifyCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final result = await _usuarioService.verifyRecoveryCode(
        email: widget.email,
        code: _codeController.text.trim(),
      );
      final mensaje = result['message'] ?? 'Verificación realizada';

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
          MaterialPageRoute(
            builder:
                (_) => ResetPasswordView(
                  email: widget.email,
                  code: _codeController.text.trim(),
                ),
          ),
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

  String get _formattedTime {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return _buildVerifyCodeView();
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Widget _buildVerifyCodeView() {
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
                    'assets/lottie/verified_email.json',
                    height: 150,
                    reverse: true,
                    repeat: true,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'Se envió un código a:',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    maskEmail(widget.email),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Tiempo restante: $_formattedTime',
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Código de verificación',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa el código';
                    }
                    if (value.length < 4) {
                      return 'El código es muy corto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.verified, color: Colors.white),
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
                              'Verificar código',
                              style: TextStyle(color: Colors.white),
                            ),
                    onPressed: _isLoading ? null : _handleVerifyCode,
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

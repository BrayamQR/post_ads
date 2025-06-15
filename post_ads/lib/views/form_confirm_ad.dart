import 'package:flutter/material.dart';
import 'package:post_ads/models/usuario.dart';
import 'package:post_ads/services/anuncio_service.dart';
import 'package:post_ads/services/session_manager.dart';
import 'package:post_ads/views/all_ads_view.dart';
import 'package:lottie/lottie.dart';

class FormConfirmAd extends StatefulWidget {
  final int idAnuncio;
  const FormConfirmAd({super.key, required this.idAnuncio});

  @override
  State<FormConfirmAd> createState() => _FormConfirmAdState();
}

class _FormConfirmAdState extends State<FormConfirmAd> {
  bool _loading = true;
  Usuario? usuario;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _observacionesController =
      TextEditingController();
  int? _estadoSeleccionado;
  final AnuncioService _anuncioService = AnuncioService();

  Future<void> _loadUser() async {
    final u = await SessionManager.getUsuario();
    setState(() {
      usuario = u;
    });
  }

  @override
  void initState() {
    super.initState();
    _loading = true;
    Future.wait([_loadUser()]).then((_) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _observacionesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildFormConfirmAd();
  }

  Future<void> _enviarConfirmacion() async {
    try {
      await _anuncioService.updateEstadoAnuncio(
        idAnuncio: widget.idAnuncio,
        idEstado: _estadoSeleccionado!,
        motivoEstado:
            _observacionesController.text.trim().isEmpty
                ? null
                : _observacionesController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AllAdsView()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFormConfirmAd() {
    return Scaffold(
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
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Lottie.asset(
                              'assets/lottie/confirm_ad.json',
                              height: 150,
                              reverse: true,
                              repeat: true,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Confirmar anuncio',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                color: Colors.indigo.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FormField<int>(
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Selecciona un estado';
                                        }
                                        return null;
                                      },
                                      builder: (field) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: RadioListTile<int>(
                                                    title: const Text(
                                                      'Publicar',
                                                    ),
                                                    value: 1,
                                                    groupValue:
                                                        _estadoSeleccionado,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _estadoSeleccionado =
                                                            value;
                                                        field.didChange(value);
                                                      });
                                                    },
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: RadioListTile<int>(
                                                    title: const Text('Anular'),
                                                    value: 5,
                                                    groupValue:
                                                        _estadoSeleccionado,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _estadoSeleccionado =
                                                            value;
                                                        field.didChange(value);
                                                      });
                                                    },
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (field.hasError)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 12.0,
                                                ),
                                                child: Text(
                                                  field.errorText!,
                                                  style: TextStyle(
                                                    color: Colors.red.shade900,
                                                    fontStyle: FontStyle.normal,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                    SizedBox(height: 20),
                                    TextFormField(
                                      controller: _observacionesController,
                                      maxLines: 5,
                                      maxLength: 255,
                                      decoration: InputDecoration(
                                        labelText: 'Descripción',
                                        alignLabelWithHint: true,
                                        border: OutlineInputBorder(),
                                      ),
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      validator: (value) {
                                        if (_estadoSeleccionado == 5) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'La descripción es obligatoria para anular';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            MaterialButton(
                              minWidth: double.infinity,
                              color: Colors.indigo,
                              textColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _enviarConfirmacion();
                                }
                              },
                              child: const Text(
                                'Confirmar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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

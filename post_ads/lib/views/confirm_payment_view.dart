import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:post_ads/config/config.dart';
import 'package:post_ads/models/ad.dart';
import 'package:post_ads/models/usuario.dart';
import 'package:post_ads/services/anuncio_service.dart';
import 'package:post_ads/services/session_manager.dart';
import 'package:post_ads/utils/get_styles.dart';

class ConfirmPaymentView extends StatefulWidget {
  final int idAnuncio;
  const ConfirmPaymentView({super.key, required this.idAnuncio});

  @override
  State<ConfirmPaymentView> createState() => _ConfirmPaymentViewState();
}

class _ConfirmPaymentViewState extends State<ConfirmPaymentView> {
  final _formKey = GlobalKey<FormState>();
  String? _medioPago;
  final _operacionController = TextEditingController();
  final _nomTitularController = TextEditingController();
  File? _comprobante;
  String? _comprobanteError;
  final AnuncioService _anuncioService = AnuncioService();
  late Anuncio _anuncio;

  Usuario? usuario;
  bool _loading = true;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _comprobante = File(picked.path);
      });
    }
  }

  Future<void> _loadUser() async {
    final u = await SessionManager.getUsuario();
    setState(() {
      usuario = u;
    });
  }

  Future<void> _fetchAnuncio() async {
    final anuncio = await _anuncioService.fetchAnuncioById(widget.idAnuncio);
    anuncio.montoPago = anuncio.tiempoPublicacion * tarifaDiaria;
    setState(() {
      _anuncio = anuncio;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _loading = true;
    Future.wait([_loadUser(), _fetchAnuncio()]).then((_) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildConfirmPaymentView();
  }

  Widget buildConfirmPaymentView() {
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
              : RefreshIndicator(
                onRefresh: _fetchAnuncio,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Lottie.asset(
                                'assets/lottie/confirm_payment.json',
                                height: 200,
                                reverse: true,
                                repeat: true,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Confirmar pago',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                infoRow(
                                  'Fecha de creación:',
                                  _anuncio.fechaCreacion != null
                                      ? '${_anuncio.fechaCreacion!.day.toString().padLeft(2, '0')}/${_anuncio.fechaCreacion!.month.toString().padLeft(2, '0')}/${_anuncio.fechaCreacion!.year}'
                                      : '-',
                                ),
                                infoRow('Anunciante:', _anuncio.nomAnunciante),
                                infoRow(
                                  'Descripción:',
                                  _anuncio.descCorta,
                                  isEllipsis: true,
                                  maxLines: 2,
                                ),
                                const Divider(height: 24),
                                infoRow(
                                  'Monto diario:',
                                  'S/ ${tarifaDiaria.toStringAsFixed(2)}',
                                ),
                                infoRow(
                                  'Días publicados:',
                                  '${_anuncio.tiempoPublicacion} dias',
                                ),
                                infoRow(
                                  'Monto total:',
                                  'S/ ${_anuncio.montoPago?.toStringAsFixed(2) ?? '-'}',
                                  color: Colors.indigo,
                                  isBold: true,
                                  fontSize: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Una vez confirmado el pago, el anuncio no podrá ser eliminado ni modificado.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FormField<String>(
                                        validator: (value) {
                                          if (value == null) {
                                            return 'Selecciona un medio de pago';
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
                                                    child: RadioListTile<
                                                      String
                                                    >(
                                                      title: const Text('Yape'),
                                                      value: 'yape',
                                                      groupValue: _medioPago,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _medioPago = value;
                                                          field.didChange(
                                                            value,
                                                          );
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: RadioListTile<
                                                      String
                                                    >(
                                                      title: const Text('Plin'),
                                                      value: 'plin',
                                                      groupValue: _medioPago,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _medioPago = value;
                                                          field.didChange(
                                                            value,
                                                          );
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              if (field.hasError)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 16.0,
                                                      ),
                                                  child: Text(
                                                    field.errorText!,
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),

                                      if (_medioPago != null) ...[
                                        const SizedBox(height: 5),
                                        Image.asset(
                                          _medioPago == 'yape'
                                              ? 'assets/qryape.jpg'
                                              : 'assets/qryape.jpg',
                                          height: 300,
                                        ),
                                        const SizedBox(height: 20),
                                        TextFormField(
                                          controller: _nomTitularController,
                                          decoration: const InputDecoration(
                                            labelText: 'Nombre del titular',
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Ingrese el nombre del titular';
                                            }
                                            return null;
                                          },
                                          textCapitalization:
                                              TextCapitalization.words,
                                        ),
                                        const SizedBox(height: 20),
                                        TextFormField(
                                          controller: _operacionController,
                                          decoration: const InputDecoration(
                                            labelText: 'Número de operación',
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Ingrese el número de operación';
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 20),
                                        Center(
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              icon: const Icon(
                                                Icons.upload,
                                                size: 20,
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.indigo.shade50,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                              ),
                                              label: const Text(
                                                'Subir comprobante',
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              onPressed: _pickImage,
                                            ),
                                          ),
                                        ),

                                        if (_comprobante != null) ...[
                                          const SizedBox(height: 16),
                                          Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (_) => Dialog(
                                                        child: Image.file(
                                                          _comprobante!,
                                                        ),
                                                      ),
                                                );
                                              },
                                              child: SizedBox(
                                                height: 150,
                                                child: Image.file(
                                                  _comprobante!,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (_comprobanteError != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2.0,
                                              left: 12.0,
                                            ),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                _comprobanteError!,
                                                style: TextStyle(
                                                  color: Colors.red.shade900,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        SizedBox(height: 20),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.monetization_on_outlined,
                                    size: 30,
                                  ),
                                  label: const Text(
                                    'Confirmar pago',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      _comprobanteError = null;
                                    });

                                    // Primero valida el comprobante
                                    if (_comprobante == null) {
                                      setState(() {
                                        _comprobanteError =
                                            'Sube el comprobante de pago';
                                      });
                                    }
                                    if (_formKey.currentState!.validate() &&
                                        _comprobante != null) {
                                      try {
                                        await _anuncioService.confirmarPago(
                                          idAnuncio: widget.idAnuncio,
                                          medioPago: _medioPago!,
                                          numeroOperacion:
                                              _operacionController.text.trim(),
                                          nomTitular:
                                              _nomTitularController.text.trim(),
                                          imgComprobante: _comprobante!,
                                          montoPago: _anuncio.montoPago!,
                                          idUsuario: usuario!.idUsuario,
                                        );
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Pago confirmado correctamente',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );

                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/userAds',
                                            (route) => false,
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error al confirmar pago: $e',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
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

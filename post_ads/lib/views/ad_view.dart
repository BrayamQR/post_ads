import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:post_ads/config/config.dart';
import 'package:post_ads/models/ad.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:post_ads/models/payment_info.dart';
import 'package:post_ads/models/usuario.dart';
import 'package:post_ads/services/anuncio_service.dart';
import 'package:post_ads/services/session_manager.dart';
import 'package:post_ads/utils/get_styles.dart';
import 'package:post_ads/views/confirm_payment_view.dart';
import 'package:post_ads/views/form_ad_view.dart';
import 'package:post_ads/views/form_confirm_ad.dart';
import 'package:post_ads/views/user_ads_view.dart';
import 'package:url_launcher/url_launcher.dart';

class AdView extends StatefulWidget {
  final int? idAnuncio;
  final Anuncio? anuncio;

  const AdView({super.key, this.idAnuncio, this.anuncio})
    : assert(
        idAnuncio != null || anuncio != null,
        'Debes enviar idAnuncio o anuncio',
      ),
      assert(
        idAnuncio == null || anuncio == null,
        'Solo puedes enviar uno: idAnuncio o anuncio',
      );
  @override
  State<AdView> createState() => _AdViewState();
}

class _AdViewState extends State<AdView> {
  late Anuncio _anuncio;
  late quill.QuillController _descripcionController;
  bool _loading = true;
  final AnuncioService _anuncioService = AnuncioService();
  Usuario? usuario;
  PaymentInfo? _paymentInfo;

  @override
  void initState() {
    super.initState();
    _loadUser();
    if (widget.anuncio != null) {
      _anuncio = widget.anuncio!;
      final delta = Delta.fromJson(jsonDecode(_anuncio.detallAnuncio));
      _descripcionController = quill.QuillController(
        document: quill.Document.fromDelta(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );
      _loading = false;
    } else {
      _fetchAnuncio();
    }
  }

  Future<void> _fetchAnuncio() async {
    final anuncio = await _anuncioService.fetchAnuncioById(widget.idAnuncio!);
    final delta = Delta.fromJson(jsonDecode(anuncio.detallAnuncio));
    setState(() {
      _anuncio = anuncio;
      _descripcionController = quill.QuillController(
        document: quill.Document.fromDelta(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );
      _loading = false;
    });
    if ((anuncio.estado?.id == 2 ||
            anuncio.estado?.id == 1 ||
            _anuncio.estado?.id == 5) &&
        (_anuncio.idUsuario == usuario?.idUsuario ||
            usuario?.idTipoUsuario == 1)) {
      _loadPaymentInfo();
    }
  }

  Future<void> _phoneCall(String phoneNumber) async {
    final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);

    final bool launcher = await launchUrl(telUri);
    if (!launcher && context.mounted) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay aplicación para llamadas disponible'),
          backgroundColor: Colors.red, // Error: rojo
        ),
      );
    }
  }

  Future<void> _openWhatsapp(String phoneNumber, {String? message}) async {
    String cleanPhone = phoneNumber.replaceAll('+', '').replaceAll(' ', '');
    final text = Uri.encodeComponent(
      message ?? "Hola, estoy interesado en tu anuncio",
    );
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$text');

    final success = await launchUrl(url);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir WhatsApp'),
          backgroundColor: Colors.red, // Error: rojo
        ),
      );
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);

    final bool launcher = await launchUrl(emailUri);

    if (!launcher) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir enlase al correo'),
          backgroundColor: Colors.red, // Error: rojo
        ),
      );
    }
  }

  Future<void> _openUrl(String url) async {
    final Uri urlRoute = Uri.parse(url);

    if (!await launchUrl(urlRoute, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo acceder al enlace'),
          backgroundColor: Colors.red, // Error: rojo
        ),
      );
    }
  }

  Future<void> _loadUser() async {
    final u = await SessionManager.getUsuario();
    setState(() {
      usuario = u;
    });
  }

  Future<void> _loadPaymentInfo() async {
    try {
      final info = await _anuncioService.fetchPaymentInfo(widget.idAnuncio!);
      setState(() {
        _paymentInfo = info;
      });
    } catch (e) {
      print('Error al obtener información de pago: $e');
      setState(() {
        _paymentInfo = null;
      });
    }
  }

  // Dentro de tu widget (por ejemplo, en AdView)
  Future<void> _eliminarAnuncio() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar este anuncio? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await _anuncioService.updateEstadoAnuncio(
          idAnuncio: _anuncio.idAnuncio!,
          idEstado: 0,
          motivoEstado: '',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anuncio eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserAdsView()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red, // Error: rojo
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _buidAdView();
  }

  Widget _buidAdView() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          icon: const Icon(Icons.close),
        ),
        actions: [
          if (usuario != null &&
              usuario!.idTipoUsuario == 1 &&
              _anuncio.estado!.id == 2)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            FormConfirmAd(idAnuncio: _anuncio.idAnuncio!),
                  ),
                );
              },
              icon: Icon(Icons.check),
            ),

          if (_anuncio.idUsuario == usuario?.idUsuario &&
              _anuncio.estado!.id == 3)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ConfirmPaymentView(idAnuncio: _anuncio.idAnuncio!),
                  ),
                );
              },
              icon: Icon(Icons.monetization_on_rounded),
            ),
          if (_anuncio.idUsuario == usuario?.idUsuario &&
              _anuncio.estado!.id == 3)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => FormAdView(idAnuncio: _anuncio.idAnuncio),
                  ),
                );
              },
              icon: Icon(Icons.edit),
            ),
          if (_anuncio.idUsuario == usuario?.idUsuario &&
              (_anuncio.estado!.id == 3 || _anuncio.estado!.id == 5))
            IconButton(
              onPressed: () {
                _eliminarAnuncio();
              },
              icon: Icon(Icons.delete),
            ),
        ],
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
                        if (_anuncio.nomAnunciante.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.co_present,
                                  color: Colors.indigo.shade400,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _anuncio.nomAnunciante,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.indigo.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_anuncio.descCorta.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _anuncio.descCorta.toUpperCase(),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple.shade900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        if (_anuncio.distrito != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.red.shade400,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_anuncio.distrito!.distrito}, ${_anuncio.distrito!.provincia.provincia}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_anuncio.tiempoPublicacion != 0 &&
                            _anuncio.fechaPublicacion != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.indigo.shade400,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Disponible del ${_anuncio.fechaPublicacion!.day.toString().padLeft(2, '0')}/'
                                  '${_anuncio.fechaPublicacion!.month.toString().padLeft(2, '0')}/'
                                  '${_anuncio.fechaPublicacion!.year} al '
                                  '${_anuncio.fechaVencimiento!.day.toString().padLeft(2, '0')}/'
                                  '${_anuncio.fechaVencimiento!.month.toString().padLeft(2, '0')}/'
                                  '${_anuncio.fechaVencimiento!.year}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_anuncio.categoria != null)
                          Row(
                            children: [
                              getIconCategory(_anuncio.categoria!.id),
                              const SizedBox(width: 5),
                              Text(
                                _anuncio.categoria!.description.toString(),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              if (_anuncio.jornada != null) ...[
                                const SizedBox(width: 5),
                                Text('-'),
                                const SizedBox(width: 5),
                                Text(
                                  _anuncio.jornada!.description.toString(),
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ],
                              if (_anuncio.tipo != null) ...[
                                const SizedBox(width: 5),
                                Text('-'),
                                const SizedBox(width: 5),
                                Text(
                                  _anuncio.tipo!.description.toString(),
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // QuillEditor sin modificar
                                IgnorePointer(
                                  child: quill.QuillEditor(
                                    focusNode: FocusNode(),
                                    scrollController: ScrollController(),
                                    controller: _descripcionController,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Contactos
                        const SizedBox(height: 18),
                        Text(
                          'Contactos',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_anuncio.telCelular != null &&
                                    _anuncio.telCelular!.isNotEmpty) ...[
                                  Column(
                                    children: [
                                      MaterialButton(
                                        onPressed:
                                            () => _phoneCall(
                                              _anuncio.telCelular!,
                                            ),
                                        color: Colors.blue.shade800,
                                        elevation: 4,
                                        minWidth: 60,
                                        height: 60,
                                        shape: const CircleBorder(),
                                        child: Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Llamar',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],

                                if (_anuncio.whatsappContacto != null &&
                                    _anuncio.whatsappContacto!.isNotEmpty) ...[
                                  SizedBox(width: 10),
                                  Column(
                                    children: [
                                      MaterialButton(
                                        onPressed:
                                            () => _openWhatsapp(
                                              _anuncio.whatsappContacto!,
                                            ),
                                        color: Colors.green,
                                        elevation: 4,
                                        minWidth: 60,
                                        height: 60,
                                        shape: const CircleBorder(),
                                        child: FaIcon(
                                          FontAwesomeIcons.whatsapp,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'WhatsApp',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],

                                if (_anuncio.emailContacto != null &&
                                    _anuncio.emailContacto!.isNotEmpty) ...[
                                  SizedBox(width: 10),
                                  Column(
                                    children: [
                                      MaterialButton(
                                        onPressed:
                                            () => _sendEmail(
                                              _anuncio.emailContacto!,
                                            ),
                                        color: Colors.red.shade700,
                                        elevation: 4,
                                        minWidth: 60,
                                        height: 60,
                                        shape: const CircleBorder(),
                                        child: Icon(
                                          Icons.email,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Correo',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                                if (_anuncio.linkReferencia != null &&
                                    _anuncio.linkReferencia!.isNotEmpty) ...[
                                  SizedBox(width: 10),
                                  Column(
                                    children: [
                                      MaterialButton(
                                        onPressed:
                                            () => _openUrl(
                                              _anuncio.linkReferencia!,
                                            ),
                                        color: Colors.purple.shade800,
                                        elevation: 4,
                                        minWidth: 60,
                                        height: 60,
                                        shape: const CircleBorder(),
                                        child: Icon(
                                          Icons.link,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Enlace',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Bloques de información adicional (estado, pago, advertencias, motivo de rechazo)
                        if ((_anuncio.estado?.id == 2 ||
                                _anuncio.estado?.id == 1 ||
                                _anuncio.estado?.id == 5) &&
                            (_anuncio.idUsuario == usuario?.idUsuario ||
                                usuario?.idTipoUsuario == 1)) ...[
                          const SizedBox(height: 22),
                          Card(
                            elevation: 2,
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
                                  infoRow(
                                    'Fecha de publicación:',
                                    _anuncio.fechaPublicacion != null
                                        ? '${_anuncio.fechaPublicacion!.day.toString().padLeft(2, '0')}/${_anuncio.fechaPublicacion!.month.toString().padLeft(2, '0')}/${_anuncio.fechaPublicacion!.year}'
                                        : '-',
                                  ),
                                  infoRow(
                                    'Anunciante:',
                                    _anuncio.nomAnunciante,
                                  ),
                                  infoRow(
                                    'Descripción:',
                                    _anuncio.descCorta,
                                    isEllipsis: true,
                                  ),
                                  infoRow(
                                    'Estado:',
                                    _anuncio.estado?.description ?? '-',
                                    color:
                                        getEstadoColor(
                                          _anuncio.estado?.id ?? 0,
                                        )['color'],
                                    isBold: true,
                                  ),
                                  const Divider(height: 24),
                                  infoRow(
                                    'Monto diario:',
                                    'S/ ${tarifaDiaria.toStringAsFixed(2)}',
                                  ),
                                  infoRow(
                                    'Días publicados:',
                                    '${_anuncio.tiempoPublicacion}',
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
                        ],

                        if ((_anuncio.estado?.id == 2 ||
                                _anuncio.estado?.id == 1 ||
                                _anuncio.estado?.id == 5) &&
                            (_anuncio.idUsuario == usuario?.idUsuario ||
                                usuario?.idTipoUsuario == 1) &&
                            _paymentInfo != null) ...[
                          const SizedBox(height: 18),
                          Card(
                            elevation: 2,
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
                                    'Nom. del titular:',
                                    _paymentInfo!.nomTitular ?? '-',
                                  ),
                                  infoRow(
                                    'Nro. de operación:',
                                    _paymentInfo!.nroOperacion ?? '-',
                                  ),
                                  infoRow(
                                    'Medio de pago:',
                                    _paymentInfo!.medioOperacion ?? '-',
                                  ),
                                  infoRow(
                                    'Fecha de pago:',
                                    _paymentInfo!.fechaPago != null
                                        ? (() {
                                          try {
                                            final date = DateTime.parse(
                                              _paymentInfo!.fechaPago!,
                                            );
                                            return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                                          } catch (_) {
                                            return '-';
                                          }
                                        })()
                                        : '-',
                                  ),
                                  if (_paymentInfo!.imgComprobante != null) ...[
                                    const SizedBox(height: 16),
                                    Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder:
                                                (_) => Dialog(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  child: InteractiveViewer(
                                                    child: Image.network(
                                                      '$apiBaseUrl/${_paymentInfo!.imgComprobante}',
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            '$apiBaseUrl/${_paymentInfo!.imgComprobante}',
                                            height: 180,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (_anuncio.estado?.id == 2 &&
                              _anuncio.idUsuario == usuario?.idUsuario) ...[
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.yellow.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.amber.shade700,
                                  width: 1,
                                ),
                              ),
                              child: Text.rich(
                                TextSpan(
                                  text:
                                      "El anuncio se verificará y publicará en un máximo de 24 horas. Si esto no ocurre, ",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "haz click aquí",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      recognizer:
                                          TapGestureRecognizer()
                                            ..onTap = () {
                                              _openWhatsapp(
                                                soporteWhatsapp,
                                                message:
                                                    "Hola, necesito soporte con mi anuncio.",
                                              );
                                            },
                                    ),
                                    TextSpan(
                                      text: " o comunícate con ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "soporte técnico",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      recognizer:
                                          TapGestureRecognizer()
                                            ..onTap = () {
                                              _phoneCall(soporteTelefono);
                                            },
                                    ),
                                    TextSpan(
                                      text: " y solucionaremos el problema.",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                          if (_anuncio.motivoEstado != null &&
                              _anuncio.motivoEstado!.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.red.shade700,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "${_anuncio.motivoEstado}",
                                      style: TextStyle(
                                        color: Colors.red.shade900,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              "© ${DateTime.now().year} Post Ads. Todos los derechos reservados.",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}

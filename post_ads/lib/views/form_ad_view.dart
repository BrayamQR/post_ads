import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:post_ads/models/ad.dart';
import 'package:post_ads/models/generic_list.dart';
import 'package:post_ads/models/location.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:post_ads/models/usuario.dart';
import 'package:post_ads/services/anuncio_service.dart';
import 'package:post_ads/services/genericList_service.dart';
import 'package:post_ads/services/location_service.dart';
import 'package:post_ads/services/session_manager.dart';
import 'package:post_ads/views/ad_view.dart';
import 'package:post_ads/widgets/custom_quill_editor.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:post_ads/utils/get_styles.dart';
import 'package:flutter_quill/quill_delta.dart';

class FormAdView extends StatefulWidget {
  final int? idAnuncio;
  const FormAdView({super.key, this.idAnuncio});

  @override
  State<FormAdView> createState() => _FormAdViewState();
}

class _FormAdViewState extends State<FormAdView> {
  final _formKey = GlobalKey<FormState>();
  final _descCortaKey = GlobalKey<FormFieldState>();
  final _categoriaKey = GlobalKey<FormFieldState>();
  final _ubigeoKey = GlobalKey<FormFieldState>();
  final _descripcionKey = GlobalKey<FormFieldState>();
  final _duracionKey = GlobalKey<FormFieldState>();
  final _anuncianteKey = GlobalKey<FormFieldState>();
  final _celularKey = GlobalKey<FormFieldState>();
  final _whatsappKey = GlobalKey<FormFieldState>();
  final _emailKey = GlobalKey<FormFieldState>();
  final _tipoKey = GlobalKey<FormFieldState>();
  final _jornadaKey = GlobalKey<FormFieldState>();
  final _urlKey = GlobalKey<FormFieldState>();

  //FocusNode
  final FocusNode _focusDescCorta = FocusNode();
  final FocusNode _focusCategoria = FocusNode();
  final FocusNode _focusDescripcion = FocusNode();
  final FocusNode _focusDuracion = FocusNode();
  final FocusNode _focusAnunciante = FocusNode();
  final FocusNode _focusCelular = FocusNode();
  final FocusNode _focusWhatsapp = FocusNode();
  final FocusNode _focusEmail = FocusNode();
  final FocusNode _focusTipo = FocusNode();
  final FocusNode _focusJornada = FocusNode();
  final FocusNode _focusUrl = FocusNode();

  //widget Controller
  late TextEditingController _ubigeoController = TextEditingController();
  final TextEditingController _descCortaController = TextEditingController();
  GenericList? _categoria;
  Distrito? _distrito;
  final quill.QuillController _descripcionController =
      quill.QuillController.basic();
  final TextEditingController _duracionController = TextEditingController();
  final TextEditingController _anuncianteController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  GenericList? _jornada;
  GenericList? _tipo;
  final GenericListService _genericListService = GenericListService();
  final LocationService _locationService = LocationService();
  final AnuncioService _anuncioService = AnuncioService();

  String? _celularCompleto;
  String? _whatsappCompleto;

  List<GenericList> categorias = [];
  List<GenericList> tipos = [];
  List<GenericList> jornadas = [];
  List<Distrito> lstdistritos = [];

  GenericList? _estado = GenericList(id: 3);

  Usuario? usuario;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _loading = true;
    _ubigeoController.addListener(() {
      setState(() {});
    });

    Future.wait([
      cargarCategorias(),
      cargarDistritos(),
      _loadUser(),
      if (widget.idAnuncio != null) _cargarAnuncioPorId(widget.idAnuncio),
    ]).then((_) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _focusDescCorta.dispose();
    _focusCategoria.dispose();
    _focusTipo.dispose();
    _focusJornada.dispose();
    _focusCelular.dispose();
    _focusWhatsapp.dispose();
    _focusEmail.dispose();
    _focusDescripcion.dispose();
    _focusDuracion.dispose();
    _anuncianteController.dispose();
    _descCortaController.dispose();
    _descripcionController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  Future<void> cargarCategorias() async {
    categorias = await _genericListService.fetchCategorias();

    if (_categoria != null) {
      final match = categorias.where((cat) => cat.id == _categoria!.id);
      if (match.isNotEmpty) {
        setState(() {
          _categoria = match.first;
        });
      }
    }
    setState(() {});
  }

  Future<void> cargarTiposPorCategoria(int categoriaId) async {
    tipos = await _genericListService.fetchTiposPorCategoria(categoriaId);
    if (_tipo != null) {
      final match = tipos.where((t) => t.id == _tipo!.id);
      if (match.isNotEmpty) {
        setState(() {
          _tipo = match.first;
        });
      }
    }
    setState(() {});
  }

  Future<void> cargarJornadasPorCategoria(int categoriaId) async {
    jornadas = await _genericListService.fetchJornadasPorCategoria(categoriaId);
    if (_jornada != null) {
      final match = jornadas.where((j) => j.id == _jornada!.id);
      if (match.isNotEmpty) {
        setState(() {
          _jornada = match.first;
        });
      }
    }
    setState(() {});
  }

  Future<void> cargarDistritos() async {
    lstdistritos = await _locationService.fetchDistritosAnidados();
    if (_distrito != null) {
      final match = lstdistritos.where(
        (d) => d.idDistrito == _distrito!.idDistrito,
      );
      if (match.isNotEmpty) {
        setState(() {
          _distrito = match.first;
        });
      }
    }
    setState(() {});
  }

  Future<void> _loadUser() async {
    final u = await SessionManager.getUsuario();
    setState(() {
      usuario = u;
    });
  }

  Future<void> _cargarAnuncioPorId([int? id]) async {
    int? anuncioId = id;
    if (anuncioId == null) return;
    final anuncio = await _anuncioService.fetchAnuncioById(anuncioId);
    await cargarDistritos();
    List<dynamic> deltaJson;
    try {
      deltaJson = jsonDecode(anuncio.detallAnuncio) as List;
    } catch (_) {
      deltaJson = [];
    }

    final matchCategoria = categorias.where(
      (cat) => cat.id == anuncio.categoria?.id,
    );

    setState(() {
      _anuncianteController.text = anuncio.nomAnunciante;
      _descCortaController.text = anuncio.descCorta;
      _descripcionController.document = quill.Document.fromDelta(
        Delta.fromJson(deltaJson),
      );
      _duracionController.text = anuncio.tiempoPublicacion.toString();
      _emailController.text = anuncio.emailContacto ?? '';
      _urlController.text = anuncio.linkReferencia ?? '';
      _celularController.text = quitarCodigoPais(anuncio.telCelular);
      _whatsappController.text = quitarCodigoPais(anuncio.whatsappContacto);
      _celularCompleto = anuncio.telCelular;
      _whatsappCompleto = anuncio.whatsappContacto;
      _categoria = matchCategoria.isNotEmpty ? matchCategoria.first : null;
      _estado = anuncio.estado;
    });

    if (_categoria != null) {
      await cargarTiposPorCategoria(_categoria!.id);
      await cargarJornadasPorCategoria(_categoria!.id);

      final matchTipo = tipos.where((t) => t.id == anuncio.tipo?.id);
      final matchJornada = jornadas.where((j) => j.id == anuncio.jornada?.id);

      setState(() {
        _tipo = matchTipo.isNotEmpty ? matchTipo.first : null;
        _jornada = matchJornada.isNotEmpty ? matchJornada.first : null;
      });
    }
    final matchDistrito = lstdistritos.where(
      (d) => d.idDistrito == anuncio.distrito?.idDistrito,
    );
    setState(() {
      _distrito = matchDistrito.isNotEmpty ? matchDistrito.first : null;
    });
  }

  Future<void> _guardarAnuncio() async {
    if (usuario == null || _estado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener el usuario o el estado.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final anuncio = Anuncio(
      idUsuario: usuario!.idUsuario,
      nomAnunciante: _anuncianteController.text.trim(),
      distrito: _distrito,
      categoria: _categoria,
      jornada: _jornada,
      tipo: _tipo,
      descCorta: _descCortaController.text.trim(),
      detallAnuncio: jsonEncode(
        _descripcionController.document.toDelta().toJson(),
      ),
      telCelular: _celularCompleto?.isEmpty ?? true ? null : _celularCompleto,
      whatsappContacto:
          _whatsappCompleto?.isEmpty ?? true ? null : _whatsappCompleto,
      emailContacto:
          _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
      linkReferencia:
          _urlController.text.trim().isEmpty
              ? null
              : _urlController.text.trim(),
      tiempoPublicacion: int.tryParse(_duracionController.text.trim()) ?? 0,
      estado: _estado,
    );

    try {
      if (widget.idAnuncio == null) {
        await _anuncioService.registerAnuncio(anuncio);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anuncio registrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _anuncioService.editAnuncio(widget.idAnuncio!, anuncio);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anuncio actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
      Navigator.pushNamedAndRemoveUntil(context, '/userAds', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al grabar: $e'),
          backgroundColor: Colors.red, // Error: rojo
        ),
      );
    }
  }

  Future<void> _vistaPrevia() async {
    if ((_celularCompleto == null || _celularCompleto!.isEmpty) &&
        _celularController.text.isNotEmpty) {
      _celularCompleto = '+51${_celularController.text.trim()}';
    }
    if ((_whatsappCompleto == null || _whatsappCompleto!.isEmpty) &&
        _whatsappController.text.isNotEmpty) {
      _whatsappCompleto = '+51${_whatsappController.text.trim()}';
    }

    final anuncio = Anuncio(
      nomAnunciante: _anuncianteController.text.trim(),
      distrito: _distrito,
      categoria: _categoria,
      jornada: _jornada,
      tipo: _tipo,
      descCorta: _descCortaController.text.trim(),
      detallAnuncio: jsonEncode(
        _descripcionController.document.toDelta().toJson(),
      ),
      telCelular: _celularCompleto?.isEmpty ?? true ? null : _celularCompleto,
      whatsappContacto:
          _whatsappCompleto?.isEmpty ?? true ? null : _whatsappCompleto,
      emailContacto:
          _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
      linkReferencia:
          _urlController.text.trim().isEmpty
              ? null
              : _urlController.text.trim(),
      tiempoPublicacion: int.tryParse(_duracionController.text.trim()) ?? 0,
      idUsuario: usuario?.idUsuario ?? 0,
      estado: GenericList(id: 0),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdView(anuncio: anuncio)),
    );
  }

  String quitarCodigoPais(String? numero) {
    if (numero == null) return '';
    return numero.replaceFirst('+51', '');
  }

  @override
  Widget build(BuildContext context) {
    return _builFormAdView();
  }

  Widget _builFormAdView() {
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
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Lottie.asset(
                              'assets/lottie/ad.json',
                              height: 150,
                              reverse: true,
                              repeat: true,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Datos del anuncio',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Colors.indigo.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text(
                        '* Campos obligatorios',
                        style: TextStyle(color: Colors.red.shade900),
                      ),

                      SizedBox(height: 10),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    dividerColor: Colors.transparent,
                                    listTileTheme: ListTileThemeData(
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),

                                  child: ExpansionTile(
                                    title: Text(
                                      'Datos del anunciante',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo.shade700,
                                      ),
                                    ),
                                    initiallyExpanded: true,
                                    clipBehavior: Clip.none,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 12),
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              key: _anuncianteKey,
                                              focusNode: _focusAnunciante,
                                              controller: _anuncianteController,
                                              clipBehavior: Clip.none,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Anunciante *',
                                                hintText:
                                                    'Ej. Ferreteria Rodrigues, etc.',
                                              ),
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Este campo es obligatorio';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) {
                                                _anuncianteKey.currentState
                                                    ?.validate();
                                                setState(() {});
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                            Autocomplete<Distrito>(
                                              key: ValueKey(
                                                _distrito?.idDistrito ??
                                                    'autocomplete',
                                              ),
                                              initialValue:
                                                  _distrito != null
                                                      ? TextEditingValue(
                                                        text:
                                                            '${_distrito!.distrito}, ${_distrito!.provincia.provincia}, ${_distrito!.provincia.departamento.departamento}',
                                                      )
                                                      : null,
                                              optionsBuilder: (
                                                TextEditingValue
                                                textEditingValue,
                                              ) {
                                                if (textEditingValue
                                                    .text
                                                    .isEmpty) {
                                                  return const Iterable<
                                                    Distrito
                                                  >.empty();
                                                }
                                                return lstdistritos.where((
                                                  distrito,
                                                ) {
                                                  final descripcion =
                                                      '${distrito.distrito}, ${distrito.provincia.provincia}, ${distrito.provincia.departamento.departamento}'
                                                          .toLowerCase();
                                                  return descripcion.contains(
                                                    textEditingValue.text
                                                        .toLowerCase(),
                                                  );
                                                });
                                              },
                                              displayStringForOption:
                                                  (Distrito distrito) =>
                                                      '${distrito.distrito}, ${distrito.provincia.provincia}, ${distrito.provincia.departamento.departamento}',
                                              onSelected: (Distrito selection) {
                                                _distrito = selection;
                                                _ubigeoController.text =
                                                    '${selection.distrito}, ${selection.provincia.provincia}, ${selection.provincia.departamento.departamento}';
                                                setState(() {});
                                              },

                                              fieldViewBuilder: (
                                                context,
                                                controller,
                                                focusNode,
                                                onEditingComplete,
                                              ) {
                                                controller.addListener(() {
                                                  setState(() {
                                                    _ubigeoController =
                                                        controller;
                                                  });
                                                });
                                                focusNode.addListener(() {
                                                  if (!focusNode.hasFocus) {
                                                    final input =
                                                        controller.text.trim();
                                                    final valido = lstdistritos.any(
                                                      (d) =>
                                                          '${d.distrito}, ${d.provincia.provincia}, ${d.provincia.departamento.departamento}'
                                                              .toLowerCase() ==
                                                          input.toLowerCase(),
                                                    );

                                                    if (!valido) {
                                                      setState(() {
                                                        controller.clear();
                                                        _distrito = null;
                                                      });
                                                    }
                                                  }
                                                  setState(() {});
                                                  final distritoText =
                                                      _distrito != null
                                                          ? '${_distrito!.distrito}, ${_distrito!.provincia.provincia}, ${_distrito!.provincia.departamento.departamento}'
                                                          : '';
                                                  if (controller.text !=
                                                      distritoText) {
                                                    controller.text =
                                                        distritoText;
                                                    controller.selection =
                                                        TextSelection.collapsed(
                                                          offset:
                                                              controller
                                                                  .text
                                                                  .length,
                                                        );
                                                  }
                                                });
                                                return TextFormField(
                                                  key: _ubigeoKey,
                                                  controller: controller,
                                                  focusNode: focusNode,
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText: 'Ubicación *',
                                                    hintText:
                                                        'Distrito, Provincia, Departamento',
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Este campo es obligatorio';
                                                    }

                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    _ubigeoKey.currentState
                                                        ?.validate();
                                                    setState(() {});
                                                  },
                                                  onEditingComplete:
                                                      onEditingComplete,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                );
                                              },
                                              optionsViewBuilder: (
                                                BuildContext context,
                                                AutocompleteOnSelected<Distrito>
                                                onSelected,
                                                Iterable<Distrito> options,
                                              ) {
                                                final query =
                                                    _ubigeoController.text;
                                                const maxHeight = 170.0;
                                                const itemHeight = 48.0;
                                                final height =
                                                    (options.length *
                                                                itemHeight)
                                                            .clamp(0, maxHeight)
                                                        as double;
                                                return Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Material(
                                                    elevation: 4.0,
                                                    child: SizedBox(
                                                      height: height,
                                                      child: ListView.builder(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 0,
                                                            ),
                                                        itemCount:
                                                            options.length,
                                                        itemBuilder: (
                                                          BuildContext context,
                                                          int index,
                                                        ) {
                                                          final option = options
                                                              .elementAt(index);
                                                          final descripcion =
                                                              '${option.distrito}, ${option.provincia.provincia}, ${option.provincia.departamento.departamento}';

                                                          return ListTile(
                                                            title:
                                                                _buildHighlightedText(
                                                                  descripcion,
                                                                  query,
                                                                ),
                                                            onTap:
                                                                () =>
                                                                    onSelected(
                                                                      option,
                                                                    ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    dividerColor: Colors.transparent,
                                    listTileTheme: ListTileThemeData(
                                      contentPadding:
                                          EdgeInsets
                                              .zero, // Quita el padding horizontal del título
                                    ),
                                  ),
                                  child: ExpansionTile(
                                    title: Text(
                                      'Información del anuncio',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo.shade700,
                                      ),
                                    ),
                                    initiallyExpanded: true,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 12),
                                        child: Column(
                                          children: [
                                            DropdownButtonFormField<
                                              GenericList
                                            >(
                                              key: _categoriaKey,
                                              focusNode: _focusCategoria,
                                              value: _categoria,

                                              items:
                                                  categorias
                                                      .map(
                                                        (
                                                          item,
                                                        ) => DropdownMenuItem<
                                                          GenericList
                                                        >(
                                                          value: item,
                                                          child: Text(
                                                            item.description ??
                                                                '',
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                              onChanged: (
                                                GenericList? value,
                                              ) async {
                                                _categoria = value;
                                                _categoriaKey.currentState
                                                    ?.validate();
                                                _tipo = null;
                                                _jornada = null;

                                                setState(() {});
                                                if (value != null) {
                                                  await cargarTiposPorCategoria(
                                                    value.id,
                                                  );
                                                  await cargarJornadasPorCategoria(
                                                    value.id,
                                                  );
                                                }
                                              },

                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Categoria *',
                                              ),
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Este campo es obligatorio';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                            AnimatedSize(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                              child:
                                                  tipos.isNotEmpty
                                                      ? Column(
                                                        children: [
                                                          DropdownButtonFormField<
                                                            GenericList
                                                          >(
                                                            key: _tipoKey,
                                                            focusNode:
                                                                _focusTipo,
                                                            value: _tipo,
                                                            items:
                                                                tipos
                                                                    .map(
                                                                      (
                                                                        item,
                                                                      ) => DropdownMenuItem<
                                                                        GenericList
                                                                      >(
                                                                        value:
                                                                            item,
                                                                        child: Text(
                                                                          item.description ??
                                                                              '',
                                                                        ),
                                                                      ),
                                                                    )
                                                                    .toList(),
                                                            onChanged: (
                                                              GenericList?
                                                              value,
                                                            ) {
                                                              _tipo = value;
                                                              _tipoKey
                                                                  .currentState
                                                                  ?.validate();
                                                              setState(() {});
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                  labelText:
                                                                      'Tipo *',
                                                                ),
                                                            validator: (value) {
                                                              if (value ==
                                                                  null) {
                                                                return 'Este campo es obligatorio';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                        ],
                                                      )
                                                      : const SizedBox.shrink(),
                                            ),

                                            AnimatedSize(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                              child:
                                                  jornadas.isNotEmpty
                                                      ? Column(
                                                        children: [
                                                          DropdownButtonFormField<
                                                            GenericList
                                                          >(
                                                            key: _jornadaKey,
                                                            focusNode:
                                                                _focusJornada,
                                                            value: _jornada,
                                                            items:
                                                                jornadas
                                                                    .map(
                                                                      (
                                                                        item,
                                                                      ) => DropdownMenuItem<
                                                                        GenericList
                                                                      >(
                                                                        value:
                                                                            item,
                                                                        child: Text(
                                                                          item.description ??
                                                                              '',
                                                                        ),
                                                                      ),
                                                                    )
                                                                    .toList(),
                                                            onChanged: (
                                                              GenericList?
                                                              value,
                                                            ) {
                                                              _jornada = value;
                                                              _jornadaKey
                                                                  .currentState
                                                                  ?.validate();
                                                              setState(() {});
                                                            },
                                                            decoration: InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(),
                                                              labelText:
                                                                  'Jornada laboral *',
                                                            ),
                                                            validator: (value) {
                                                              if (value ==
                                                                  null) {
                                                                return 'Este campo es obligatorio';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                        ],
                                                      )
                                                      : const SizedBox.shrink(),
                                            ),
                                            TextFormField(
                                              key: _descCortaKey,
                                              focusNode: _focusDescCorta,
                                              controller: _descCortaController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText:
                                                    'Descripción corta *',
                                                hintText:
                                                    'Ej. Departamento, maestro de obras',
                                              ),
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Este campo es obligatorio';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) {
                                                _descCortaKey.currentState
                                                    ?.validate();
                                                setState(() {});
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                            CustomQuillEditor(
                                              formFieldkey: _descripcionKey,
                                              controller:
                                                  _descripcionController,
                                              focusNode: _focusDescripcion,
                                              labelText: 'Descripción *',
                                              isRequired: true,
                                              fontSize: 16,
                                              color: getFormInputColor(
                                                _descripcionKey,
                                                _focusDescripcion,
                                              ),
                                              autovalidateMode:
                                                  AutovalidateMode
                                                      .onUserInteraction,
                                              hintText:
                                                  'Escribe aqui tu anuncio',
                                              showBoldButton: true,
                                              showItalicButton: true,
                                              showListBullets: true,
                                              showListNumbers: true,
                                              showColorButton: true,
                                              showFontSize: true,
                                              showAlignmentButtons: true,
                                              showLink: true,
                                              showFontFamily: true,
                                              onChange: (value) {
                                                _descripcionKey.currentState
                                                    ?.validate();
                                                setState(() {});
                                              },
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Este campo es obligatorio';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                            TextFormField(
                                              key: _duracionKey,
                                              focusNode: _focusDuracion,
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: _duracionController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText:
                                                    'Tiempo de publicación *',
                                                hintText: 'Ej. 7',
                                                suffixText: 'días',
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Este campo es obligatorio';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) {
                                                _duracionKey.currentState
                                                    ?.validate();
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    dividerColor: Colors.transparent,
                                    listTileTheme: ListTileThemeData(
                                      contentPadding:
                                          EdgeInsets
                                              .zero, // Quita el padding horizontal del título
                                    ),
                                  ),
                                  child: ExpansionTile(
                                    title: Text(
                                      'Datos de contacto y registro',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo.shade700,
                                      ),
                                    ),
                                    initiallyExpanded: true,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 12),
                                        child: Column(
                                          children: [
                                            IntlPhoneField(
                                              key: _celularKey,
                                              focusNode: _focusCelular,
                                              controller: _celularController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Celular',
                                                hintText: 'Ej. 999999999',
                                                counterText: '',
                                              ),

                                              initialCountryCode: 'PE',
                                              languageCode: 'es',
                                              pickerDialogStyle:
                                                  PickerDialogStyle(
                                                    searchFieldInputDecoration:
                                                        InputDecoration(
                                                          labelText:
                                                              'Buscar país',
                                                        ),
                                                  ),
                                              showCountryFlag: true,
                                              showDropdownIcon: true,
                                              disableLengthCheck: false,
                                              invalidNumberMessage:
                                                  'Número de telefono invalido',
                                              autovalidateMode:
                                                  AutovalidateMode
                                                      .onUserInteraction,
                                              dropdownTextStyle: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey.shade900,
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  _celularCompleto =
                                                      value.completeNumber;
                                                });
                                              },
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                            ),

                                            SizedBox(height: 20),

                                            IntlPhoneField(
                                              key: _whatsappKey,
                                              focusNode: _focusWhatsapp,
                                              controller: _whatsappController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'WhatsApp',
                                                hintText: 'Ej. 999999999',
                                                counterText: '',
                                              ),

                                              initialCountryCode: 'PE',
                                              languageCode: 'es',
                                              pickerDialogStyle:
                                                  PickerDialogStyle(
                                                    searchFieldInputDecoration:
                                                        InputDecoration(
                                                          labelText:
                                                              'Buscar país',
                                                        ),
                                                  ),
                                              showCountryFlag: true,
                                              showDropdownIcon: true,
                                              disableLengthCheck: false,
                                              invalidNumberMessage:
                                                  'Número de whatsapp invalido',
                                              autovalidateMode:
                                                  AutovalidateMode
                                                      .onUserInteraction,
                                              dropdownTextStyle: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey.shade900,
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  _whatsappCompleto =
                                                      value.completeNumber;
                                                });
                                              },
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            TextFormField(
                                              key: _emailKey,
                                              controller: _emailController,
                                              focusNode: _focusEmail,
                                              decoration: InputDecoration(
                                                labelText: 'Correo electrónico',
                                                border: OutlineInputBorder(),
                                                hintText:
                                                    'Ej. ejemplo@ejemplo.com',
                                              ),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              validator: (value) {
                                                if (value != null &&
                                                    value.isNotEmpty) {
                                                  final emailRegex = RegExp(
                                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                  );
                                                  if (!emailRegex.hasMatch(
                                                    value,
                                                  )) {
                                                    return 'Correo inválido';
                                                  }
                                                }
                                                // Validación simple de correo

                                                return null;
                                              },
                                              onChanged: (value) {
                                                _emailKey.currentState
                                                    ?.validate();
                                                setState(() {});
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                            TextFormField(
                                              key: _urlKey,
                                              controller: _urlController,
                                              focusNode: _focusUrl,
                                              decoration: InputDecoration(
                                                labelText: 'Url',
                                                hintText:
                                                    'Ej. Formulario de registro, etc.',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType: TextInputType.url,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.indigo,
                                    side: BorderSide(color: Colors.indigo),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 16,
                                    ),
                                  ),
                                  onPressed: _vistaPrevia,
                                  icon: Icon(Icons.visibility),
                                  label: Text('Vista previa'),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo.shade600,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 16,
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      await _guardarAnuncio();
                                      setState(() {});
                                    }
                                  },
                                  icon: Icon(Icons.save),
                                  label: Text('Grabar'),
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

  Widget _buildHighlightedText(String source, String query) {
    final sourceLower = source.toLowerCase();
    final queryLower = query.toLowerCase();

    if (queryLower.isEmpty) {
      return Text(source);
    }

    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = sourceLower.indexOf(queryLower, start);
      if (index < 0) {
        spans.add(TextSpan(text: source.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: source.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: source.substring(index, index + queryLower.length),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

      start = index + queryLower.length;
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: spans,
      ),
    );
  }
}

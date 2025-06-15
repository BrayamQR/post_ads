import 'package:flutter/material.dart';
import 'package:post_ads/models/generic_list.dart';
import 'package:post_ads/models/location.dart';
import 'package:post_ads/services/genericList_service.dart';
import 'package:post_ads/services/location_service.dart';

class FilterFormView extends StatefulWidget {
  final String? view;
  final String? initialAnuncio;
  final Distrito? initialDistrito;
  final GenericList? initialCategoria;
  final GenericList? initialEstado;
  const FilterFormView({
    super.key,
    this.view,
    this.initialAnuncio,
    this.initialDistrito,
    this.initialCategoria,
    this.initialEstado,
  });

  @override
  State<FilterFormView> createState() => _FilterFormViewState();
}

class _FilterFormViewState extends State<FilterFormView> {
  final _formKey = GlobalKey<FormState>();
  final _ubigeoKey = GlobalKey<FormFieldState>();
  final GenericListService _genericListService = GenericListService();
  final LocationService _locationService = LocationService();

  late TextEditingController _ubigeoController = TextEditingController();
  Distrito? _distrito;

  List<GenericList> lstCategoria = [];
  List<Distrito> lstdistritos = [];
  List<GenericList> lstEstado = [];
  String? _anuncioFiltro;
  GenericList? _categoriaFiltro;
  GenericList? _estadoFiltro;

  @override
  void initState() {
    super.initState();

    _anuncioFiltro = widget.initialAnuncio;
    _distrito = widget.initialDistrito;
    _categoriaFiltro = widget.initialCategoria;
    _estadoFiltro = widget.initialEstado;

    if (_distrito != null) {
      _ubigeoController.text =
          '${_distrito!.distrito}, ${_distrito!.provincia.provincia}, ${_distrito!.provincia.departamento.departamento}';
    }

    _ubigeoController.addListener(() {
      setState(() {});
    });

    Future.wait([cargarCategorias(), cargarEstados(), cargarDistritos()]).then((
      _,
    ) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildFilterFormView();
  }

  Future<void> cargarCategorias() async {
    lstCategoria = await _genericListService.fetchCategorias();
  }

  Future<void> cargarEstados() async {
    lstEstado = await _genericListService.fetchEstados();
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
    if (mounted) setState(() {});
  }

  Widget _buildFilterFormView() {
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
                        'Filtros de búsqueda',
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
                          initialValue: _anuncioFiltro,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Anuncio',
                            hintText: 'Ej. Departamento, maestro de obras',
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.indigo.shade400,
                            ),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (value) {
                            _anuncioFiltro = value.trim();
                          },
                        ),
                        const SizedBox(height: 20),
                        Autocomplete<Distrito>(
                          key: ValueKey(
                            _distrito?.idDistrito ?? 'autocomplete',
                          ),
                          initialValue:
                              _distrito != null
                                  ? TextEditingValue(
                                    text:
                                        '${_distrito!.distrito}, ${_distrito!.provincia.provincia}, ${_distrito!.provincia.departamento.departamento}',
                                  )
                                  : null,
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<Distrito>.empty();
                            }
                            return lstdistritos.where((distrito) {
                              final descripcion =
                                  '${distrito.distrito}, ${distrito.provincia.provincia}, ${distrito.provincia.departamento.departamento}'
                                      .toLowerCase();
                              return descripcion.contains(
                                textEditingValue.text.toLowerCase(),
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
                                _ubigeoController = controller;
                              });
                            });
                            focusNode.addListener(() {
                              if (!focusNode.hasFocus) {
                                final input = controller.text.trim();
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
                            });
                            return TextFormField(
                              key: _ubigeoKey,
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelText: 'Localización',
                                hintText: 'Distrito, Provincia, Departamento',
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: Colors.red.shade400,
                                ),
                              ),
                              onEditingComplete: onEditingComplete,
                              textCapitalization: TextCapitalization.sentences,
                            );
                          },
                          optionsViewBuilder: (
                            BuildContext context,
                            AutocompleteOnSelected<Distrito> onSelected,
                            Iterable<Distrito> options,
                          ) {
                            final query = _ubigeoController.text;
                            const maxHeight = 170.0;
                            const itemHeight = 48.0;
                            final height =
                                (options.length * itemHeight).clamp(
                                      0,
                                      maxHeight,
                                    )
                                    as double;
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: SizedBox(
                                  height: height,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: options.length,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final option = options.elementAt(index);
                                      final descripcion =
                                          '${option.distrito}, ${option.provincia.provincia}, ${option.provincia.departamento.departamento}';

                                      return ListTile(
                                        title: _buildHighlightedText(
                                          descripcion,
                                          query,
                                        ),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<GenericList>(
                          value: _categoriaFiltro,
                          items:
                              lstCategoria
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item.description ?? ''),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            _categoriaFiltro = value;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Categoría',
                            prefixIcon: Icon(
                              Icons.category,
                              color: Colors.orange.shade400,
                            ),
                          ),
                        ),
                        if (widget.view != null) ...[
                          const SizedBox(height: 20),
                          DropdownButtonFormField<GenericList>(
                            value: _estadoFiltro,
                            items:
                                lstEstado
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(item.description ?? ''),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              _estadoFiltro = value;
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Estado',
                              prefixIcon: Icon(
                                Icons.flag,
                                color: Colors.blue.shade400,
                              ),
                            ),
                          ),
                        ],
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
                                    'anuncio': _anuncioFiltro,
                                    'distrito': _distrito,
                                    'categoria': _categoriaFiltro,
                                    'estado': _estadoFiltro,
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
                                  _anuncioFiltro = null;
                                  _distrito = null;
                                  _ubigeoController.clear();
                                  _categoriaFiltro = null;
                                  _estadoFiltro = null;
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

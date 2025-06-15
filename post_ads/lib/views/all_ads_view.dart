import 'package:flutter/material.dart';
import 'package:post_ads/models/ad.dart';
import 'package:post_ads/models/generic_list.dart';
import 'package:post_ads/models/location.dart';
import 'package:post_ads/models/usuario.dart';
import 'package:post_ads/services/anuncio_service.dart';
import 'package:post_ads/services/session_manager.dart';
import 'package:post_ads/utils/get_styles.dart';
import 'package:post_ads/views/ad_view.dart';
import 'package:post_ads/views/filter_form_view.dart';

class AllAdsView extends StatefulWidget {
  const AllAdsView({super.key});

  @override
  State<AllAdsView> createState() => _AllAdsViewState();
}

class _AllAdsViewState extends State<AllAdsView> {
  final ScrollController _scrollController = ScrollController();
  final int _itemsPerPage = 4;
  int _currentMax = 4;
  bool _isLoading = false;
  Usuario? usuario;
  List<Anuncio> lstAnuncio = [];
  List<Anuncio> lstAnuncioFiltrada = [];
  final AnuncioService _anuncioService = AnuncioService();
  bool _loadingAnuncios = true;

  String? _anuncioFiltro;
  Distrito? _distrito;
  GenericList? _categoriaFiltro;
  GenericList? _estadoFiltro;

  Future<void> _fetchAnuncios() async {
    setState(() {
      _loadingAnuncios = true;
    });
    try {
      lstAnuncio = await _anuncioService.fetchAllAnuncios();
      lstAnuncioFiltrada = List.from(lstAnuncio);
    } catch (e) {
      lstAnuncio = [];
      lstAnuncioFiltrada = [];
    }
    setState(() {
      _loadingAnuncios = false;
      _currentMax = (_itemsPerPage).clamp(0, lstAnuncio.length);
    });
  }

  Future<void> _loadUser() async {
    final u = await SessionManager.getUsuario();
    setState(() {
      usuario = u;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;

    if (_currentMax >= lstAnuncio.length) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _currentMax = (_currentMax + _itemsPerPage).clamp(0, lstAnuncio.length);
      _isLoading = false;
    });
  }

  Icon _getIconCategory(int id) {
    if (id == 1) {
      return Icon(Icons.work_sharp, color: Colors.indigo.shade300);
    } else if (id == 2) {
      return Icon(Icons.real_estate_agent_sharp, color: Colors.indigo.shade300);
    } else if (id == 3) {
      return Icon(Icons.price_change_sharp, color: Colors.indigo.shade300);
    } else {
      return Icon(Icons.monetization_on_sharp, color: Colors.indigo.shade300);
    }
  }

  void _aplicarFiltros(Map filtros) {
    setState(() {
      _anuncioFiltro = filtros['anuncio'];
      _distrito = filtros['distrito'];
      _categoriaFiltro = filtros['categoria'];
      _estadoFiltro = filtros['estado'];
      lstAnuncioFiltrada =
          lstAnuncio.where((anuncio) {
            final coincideAnuncio =
                _anuncioFiltro == null || _anuncioFiltro!.isEmpty
                    ? true
                    : (anuncio.descCorta).toLowerCase().contains(
                      _anuncioFiltro!.toLowerCase(),
                    );

            final coincideCategoria =
                _categoriaFiltro == null
                    ? true
                    : anuncio.categoria?.id == _categoriaFiltro?.id;

            final coincideDistrito =
                _distrito == null
                    ? true
                    : anuncio.distrito?.idDistrito == _distrito?.idDistrito;
            final coinsideEstado =
                _estadoFiltro == null
                    ? true
                    : anuncio.estado?.id == _estadoFiltro?.id;

            return coincideAnuncio &&
                coincideCategoria &&
                coincideDistrito &&
                coinsideEstado;
          }).toList();
      _currentMax = (_itemsPerPage).clamp(0, lstAnuncioFiltrada.length);
    });
  }

  void _quitarFiltros() {
    setState(() {
      _anuncioFiltro = null;
      _distrito = null;
      _categoriaFiltro = null;
      _estadoFiltro = null;
      lstAnuncioFiltrada = List.from(lstAnuncio);
      _currentMax = (_itemsPerPage).clamp(0, lstAnuncioFiltrada.length);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchAnuncios();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildAllAdsView();
  }

  Widget _buildAllAdsView() {
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
        title: const Text('Anuncios'),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder:
                    (context) => Padding(
                      padding: EdgeInsets.only(
                        top: 32,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: FractionallySizedBox(
                        heightFactor: 0.92,
                        child: FilterFormView(
                          view: 'allAds',
                          initialAnuncio: _anuncioFiltro,
                          initialDistrito: _distrito,
                          initialCategoria: _categoriaFiltro,
                          initialEstado: _estadoFiltro,
                        ),
                      ),
                    ),
              );
              if (result is Map) {
                _aplicarFiltros(result);
              } else if (result == true) {
                _quitarFiltros();
              }
            },
            icon: Icon(Icons.filter_alt),
            tooltip: 'Filtrar anuncios',
          ),
        ],
      ),
      body:
          _loadingAnuncios
              ? const Center(child: CircularProgressIndicator())
              : lstAnuncioFiltrada.isEmpty
              ? const Center(child: Text('No tienes anuncios publicados.'))
              : RefreshIndicator(
                onRefresh: _fetchAnuncios,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _currentMax + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _currentMax && _isLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (index >= lstAnuncioFiltrada.length) {
                      return const SizedBox.shrink();
                    }
                    final anuncio = lstAnuncioFiltrada[index];
                    return TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          AdView(idAnuncio: anuncio.idAnuncio!),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.18),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 115,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${anuncio.nomAnunciante} - ${anuncio.distrito!.distrito}, ${anuncio.distrito!.provincia.provincia}',
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontWeight: FontWeight.w300,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      SizedBox(height: 4),
                                      Text(
                                        anuncio.descCorta,
                                        style: TextStyle(
                                          color: Colors.indigo.shade800,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          _getIconCategory(
                                            anuncio.categoria!.id,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            anuncio.categoria?.description ??
                                                '',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color:
                                                  getEstadoColor(
                                                    anuncio.estado!.id,
                                                  )['color'],
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                getEstadoColor(
                                                  anuncio.estado!.id,
                                                )['shadow'],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            anuncio.estado?.description ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color:
                                                  getEstadoColor(
                                                    anuncio.estado!.id,
                                                  )['color'],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

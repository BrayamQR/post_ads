import 'package:flutter/material.dart';
import 'package:post_ads/models/generic_list.dart';
import 'package:post_ads/models/location.dart';
import 'package:post_ads/models/usuario.dart';
import 'package:post_ads/services/anuncio_service.dart';
import 'package:post_ads/services/session_manager.dart';
import 'package:post_ads/utils/get_styles.dart';
import 'package:post_ads/views/ad_view.dart';
import 'package:post_ads/views/filter_form_view.dart';
import 'package:post_ads/views/form_ad_view.dart';
import 'package:post_ads/models/ad.dart';

class UserAdsView extends StatefulWidget {
  const UserAdsView({super.key});

  @override
  State<UserAdsView> createState() => _UserAdsViewState();
}

class _UserAdsViewState extends State<UserAdsView> {
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

  @override
  void initState() {
    super.initState();
    _loadUser();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  Future<void> _fetchUserAnuncios() async {
    setState(() {
      _loadingAnuncios = true;
    });
    if (usuario == null) return;
    lstAnuncio = await _anuncioService.fetchAnunciosByUser(usuario!.idUsuario);
    lstAnuncioFiltrada = List.from(lstAnuncio);
    setState(() {
      _loadingAnuncios = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final u = await SessionManager.getUsuario();
    setState(() {
      usuario = u;
    });
    await _fetchUserAnuncios();
  }

  Future<void> _loadMore() async {
    if (_isLoading) return; // Evitar múltiples cargas simultáneas

    if (_currentMax >= lstAnuncio.length) return; // Ya cargó todo

    setState(() {
      _isLoading = true;
    });

    // Simular tiempo de carga (puede ser una llamada a API real)
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _currentMax = (_currentMax + _itemsPerPage).clamp(0, lstAnuncio.length);
      _isLoading = false;
    });
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
  Widget build(BuildContext context) {
    return _buildUserAdsView();
  }

  Widget _buildUserAdsView() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Mis anuncios',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
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
                          view: 'userAds',
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
                onRefresh: _fetchUserAnuncios,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
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
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          AdView(idAnuncio: anuncio.idAnuncio!),
                                ),
                              );

                              if (result == true) {
                                _fetchUserAnuncios();
                              }
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
                                  height: 103,
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
                                          getIconCategory(
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

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => const Center(child: CircularProgressIndicator()),
          );
          await Future.delayed(const Duration(milliseconds: 1500));
          if (context.mounted) Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormAdView()),
          );
        },
        backgroundColor: Colors.indigo.shade500,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 6.0,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}

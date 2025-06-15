import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:post_ads/models/ad.dart';
import 'package:post_ads/models/generic_list.dart';
import 'package:post_ads/models/location.dart';
import 'package:post_ads/models/usuario.dart';
import 'package:post_ads/services/anuncio_service.dart';
import 'package:post_ads/services/session_manager.dart';
import 'package:post_ads/views/ad_view.dart';
import 'package:post_ads/views/all_ads_view.dart';
import 'package:post_ads/views/filter_form_view.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart';
import 'package:post_ads/views/info_app_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  final int _itemsPerPage = 3;
  int _currentMax = 3;
  bool _isLoading = false;
  Usuario? usuario;
  bool _loadingAnuncios = true;

  List<Anuncio> lstAnuncio = [];
  List<Anuncio> lstAnuncioFiltrada = [];
  final AnuncioService _anuncioService = AnuncioService();

  String? _anuncioFiltro;
  Distrito? _distrito;
  GenericList? _categoriaFiltro;
  bool _welcomeModalShown = false;
  double _progress = 0.0;
  Timer? _closeTimer;
  bool _isPaused = false;
  Duration _elapsed = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return _buildHomeView();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUser();
      _fetchAnuncios();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_welcomeModalShown && ModalRoute.of(context)?.isFirst == true) {
      _welcomeModalShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeModal();
      });
    }
  }

  Future<void> _fetchAnuncios() async {
    setState(() {
      _loadingAnuncios = true;
    });
    try {
      lstAnuncio = await _anuncioService.fetchAnunciosPublicados(1);
      lstAnuncioFiltrada = List.from(lstAnuncio);
      if (lstAnuncio.isNotEmpty) {}
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

  void _aplicarFiltros(Map filtros) {
    setState(() {
      _anuncioFiltro = filtros['anuncio'];
      _distrito = filtros['distrito'];
      _categoriaFiltro = filtros['categoria'];

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

            return coincideAnuncio && coincideCategoria && coincideDistrito;
          }).toList();
      _currentMax = (_itemsPerPage).clamp(0, lstAnuncioFiltrada.length);
    });
  }

  void _quitarFiltros() {
    setState(() {
      _anuncioFiltro = null;
      _distrito = null;
      _categoriaFiltro = null;
      lstAnuncioFiltrada = List.from(lstAnuncio);
      _currentMax = (_itemsPerPage).clamp(0, lstAnuncioFiltrada.length);
    });
  }

  void _showWelcomeModal() async {
    final image = Image.asset('assets/splash_ad.jpg');
    final completer = Completer<Size>();
    image.image
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((ImageInfo info, bool _) {
            completer.complete(
              Size(info.image.width.toDouble(), info.image.height.toDouble()),
            );
          }),
        );
    await completer.future;

    _progress = 0.0;
    _elapsed = Duration.zero;
    _isPaused = false;
    _closeTimer?.cancel();

    bool modalActive = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Cerrar",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: FractionallySizedBox(
              widthFactor: 0.90,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    _closeTimer ??= Timer.periodic(
                      const Duration(milliseconds: 50),
                      (timer) {
                        if (!_isPaused) {
                          _elapsed += const Duration(milliseconds: 50);
                          _progress = _elapsed.inMilliseconds / (3 * 1000);

                          if (mounted) setState(() {});
                          if (modalActive) setModalState(() {});

                          if (_progress >= 1.0) {
                            timer.cancel();
                            _closeTimer = null;
                            if (modalActive) {
                              modalActive = false;
                              if (Navigator.of(
                                context,
                                rootNavigator: true,
                              ).canPop()) {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                              }
                            }
                          }
                        }
                      },
                    );
                    return GestureDetector(
                      onTapDown: (_) {
                        _isPaused = true;
                        setState(() {});
                        if (modalActive) setModalState(() {});
                      },
                      onTapUp: (_) {
                        _isPaused = false;
                        setState(() {});
                        if (modalActive) setModalState(() {});
                      },
                      onTapCancel: () {
                        _isPaused = false;
                        setState(() {});
                        if (modalActive) setModalState(() {});
                      },
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/splash_ad.jpg',
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: GestureDetector(
                              onTap: () {
                                _closeTimer?.cancel();
                                _closeTimer = null;
                                Navigator.of(context).pop();
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: CircularProgressIndicator(
                                      value: _progress,
                                      backgroundColor: Colors.white24,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.orangeAccent,
                                      ),
                                      strokeWidth: 4,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = Curves.easeInOut.transform(animation.value);
        return Opacity(
          opacity: curved,
          child: Transform.scale(scale: 0.95 + 0.05 * curved, child: child),
        );
      },
    ).then((_) {
      modalActive = false;
      _closeTimer?.cancel();
      _closeTimer = null;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildHomeView() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Inicio",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoAppView()),
              );
            },
            icon: Icon(Icons.info),
            tooltip: 'Informacion',
          ),
          if (usuario != null && usuario!.idTipoUsuario == 1)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllAdsView()),
                );
              },
              icon: Icon(Icons.credit_score),
              tooltip: 'Confirmar anuncios',
            ),
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
                          initialAnuncio: _anuncioFiltro,
                          initialDistrito: _distrito,
                          initialCategoria: _categoriaFiltro,
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

                    final delta = Delta.fromJson(
                      jsonDecode(anuncio.detallAnuncio),
                    );

                    final controller = quill.QuillController(
                      document: quill.Document.fromDelta(delta),
                      selection: const TextSelection.collapsed(offset: 0),
                    );

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
                                child: IgnorePointer(
                                  child: SizedBox(
                                    height: 157,
                                    child: quill.QuillEditor(
                                      focusNode: FocusNode(),
                                      scrollController: ScrollController(),
                                      controller: controller,
                                    ),
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

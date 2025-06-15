import 'package:flutter/material.dart';
import 'package:post_ads/config/config.dart';
import 'package:post_ads/models/generic_list.dart';
import 'package:post_ads/models/usuario.dart';
import 'package:post_ads/services/session_manager.dart';
import 'package:post_ads/services/usuario_service.dart';
import 'package:post_ads/views/filter_user_view.dart';
import 'package:post_ads/views/form_register_view.dart';

class AllUsersView extends StatefulWidget {
  const AllUsersView({super.key});

  @override
  State<AllUsersView> createState() => _AllUsersViewState();
}

class _AllUsersViewState extends State<AllUsersView> {
  final ScrollController _scrollController = ScrollController();
  final UsuarioService _usuarioService = UsuarioService();
  List<Usuario> _usuarios = [];
  List<Usuario> _usuariosFiltrados = [];
  bool _isLoading = false;
  final int _itemsPerPage = 5;
  int _currentMax = 5;
  bool _loadingUsuarios = true;
  Usuario? usuario;

  String? _nombreFiltro;
  String? _usuarioOrEmail;
  GenericList? _tipoUsuario;

  @override
  Widget build(BuildContext context) {
    return _buildAllUsersView();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsuario();
      _fetchUsuarios();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  Future<void> _loadUsuario() async {
    final u = await SessionManager.getUsuario();
    setState(() {
      usuario = u;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;

    if (_currentMax >= _usuarios.length) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _currentMax = (_currentMax + _itemsPerPage).clamp(0, _usuarios.length);
      _isLoading = false;
    });
  }

  Future<void> _showUserDetailBottomSheet(Usuario user) async {
    await showModalBottomSheet(
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
              heightFactor: 0.55,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.08 * 255).toInt()),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.indigo.shade50,
                            radius: 24,
                            backgroundImage:
                                (user.fotoUsuario != null &&
                                        user.fotoUsuario!.isNotEmpty)
                                    ? NetworkImage(
                                      '$apiBaseUrl${user.fotoUsuario}',
                                    )
                                    : null,
                            child:
                                (user.fotoUsuario == null ||
                                        user.fotoUsuario!.isEmpty)
                                    ? Icon(
                                      Icons.person,
                                      color: Colors.indigo,
                                      size: 28,
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user.nomUsuario} ${user.apeUsuario ?? ''}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                if (user.userName != null &&
                                    user.userName!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      '@${user.userName}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _buildUserTypeTag(user.idTipoUsuario),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                size: 18,
                                color: Colors.indigo,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  user.emailUsuario,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if ((user.idTipoUsuario == 1 &&
                                  user.idUsuario != usuario?.idUsuario) ||
                              user.idTipoUsuario == 2) ...[
                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.lock_reset,
                                color: Colors.white,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              label: const Text('Restablecer contraseña'),
                              onPressed: () async {
                                Navigator.pop(context);
                                await _resetPasswordToUserName(user.idUsuario);
                              },
                            ),

                            const SizedBox(height: 12),
                          ],

                          if (user.idUsuario != usuario?.idUsuario)
                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              label: const Text('Eliminar'),
                              onPressed: () async {
                                Navigator.pop(context);
                                await _deactivateUser(user.idUsuario);
                              },
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextButton(
                        child: const Text(
                          'Cerrar',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildUserTypeTag(int tipo) {
    String text;
    Color bgColor;
    Color textColor;

    switch (tipo) {
      case 1:
        text = 'Admin';
        bgColor = Colors.indigo.shade100;
        textColor = Colors.indigo;
        break;
      case 2:
        text = 'Colaborador';
        bgColor = Colors.teal.shade100;
        textColor = Colors.teal.shade800;
        break;
      default:
        text = 'Usuario comun';
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
    }

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _fetchUsuarios() async {
    setState(() => _loadingUsuarios = true);
    try {
      final usuarios = await _usuarioService.fetchAllUsers();
      setState(() {
        _usuarios = usuarios;
        _usuariosFiltrados = List.from(_usuarios);
        _loadingUsuarios = false;
        _currentMax = (_itemsPerPage).clamp(0, _usuarios.length);
      });
    } catch (e) {
      setState(() {
        _usuarios = [];
        _usuariosFiltrados = [];
        _loadingUsuarios = false;
        _currentMax = (_itemsPerPage).clamp(0, _usuarios.length);
      });
    }
  }

  void _aplicarFiltros(Map filtros) {
    setState(() {
      _nombreFiltro = filtros['nombre'];
      _usuarioOrEmail = filtros['usuarioOEmail'];
      _tipoUsuario = filtros['tipoUsuario'];

      _usuariosFiltrados =
          _usuarios.where((usuario) {
            final coincidenombre =
                _nombreFiltro == null || _nombreFiltro!.isEmpty
                    ? true
                    : ('${usuario.nomUsuario} ${usuario.apeUsuario ?? ''}')
                        .toLowerCase()
                        .contains(_nombreFiltro!.toLowerCase());

            final coincideusuarioOEmail =
                _usuarioOrEmail == null || _usuarioOrEmail!.isEmpty
                    ? true
                    : (usuario.userName?.toLowerCase().contains(
                              _usuarioOrEmail!.toLowerCase(),
                            ) ??
                            false) ||
                        usuario.emailUsuario.toLowerCase().contains(
                          _usuarioOrEmail!.toLowerCase(),
                        );

            final coincideTipoUsuario =
                _tipoUsuario == null
                    ? true
                    : usuario.idTipoUsuario == _tipoUsuario?.id;

            return coincidenombre &&
                coincideusuarioOEmail &&
                coincideTipoUsuario;
          }).toList();
      _currentMax = (_itemsPerPage).clamp(0, _usuariosFiltrados.length);
    });
  }

  void _quitarFiltros() {
    setState(() {
      _nombreFiltro = null;
      _usuarioOrEmail = null;
      _tipoUsuario = null;
      _usuariosFiltrados = List.from(_usuarios);
      _currentMax = (_itemsPerPage).clamp(0, _usuariosFiltrados.length);
    });
  }

  Future<void> _resetPasswordToUserName(int idUsuario) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    final result = await _usuarioService.resetPasswordToUserName(idUsuario);
    if (mounted) Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Operación realizada'),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
      ),
    );
    if (result['success'] == true) {
      _fetchUsuarios();
    }
  }

  Future<void> _deactivateUser(int idUsuario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar este usuario?',
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                child: Text('Eliminar', style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );
    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    final result = await _usuarioService.deactivateUser(idUsuario);
    if (mounted) Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Operación realizada'),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
      ),
    );
    if (result['success'] == true) {
      _fetchUsuarios();
    }
  }

  Widget _buildAllUsersView() {
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
                        child: FilterUserView(
                          initialNombre: _nombreFiltro,
                          initialUsuarioOEmail: _usuarioOrEmail,
                          initialTipoUsuario: _tipoUsuario,
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
            tooltip: 'Filtrar usuarios',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child:
            _loadingUsuarios
                ? const Center(child: CircularProgressIndicator())
                : _usuariosFiltrados.isEmpty
                ? const Center(child: Text('No hay usuarios registrados'))
                : RefreshIndicator(
                  onRefresh: _fetchUsuarios,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: _currentMax + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _currentMax && _isLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (index >= _usuariosFiltrados.length) {
                        return const SizedBox.shrink();
                      }
                      final usuario = _usuariosFiltrados[index];
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
                                _showUserDetailBottomSheet(usuario);
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
                                    height: 80,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              Colors.indigo.shade50,
                                          radius: 24,
                                          backgroundImage:
                                              (usuario.fotoUsuario != null &&
                                                      usuario
                                                          .fotoUsuario!
                                                          .isNotEmpty)
                                                  ? NetworkImage(
                                                    '$apiBaseUrl${usuario.fotoUsuario}',
                                                  )
                                                  : null,
                                          child:
                                              (usuario.fotoUsuario == null ||
                                                      usuario
                                                          .fotoUsuario!
                                                          .isEmpty)
                                                  ? Icon(
                                                    Icons.person,
                                                    color: Colors.indigo,
                                                    size: 28,
                                                  )
                                                  : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${usuario.nomUsuario} ${usuario.apeUsuario ?? ''}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                usuario.emailUsuario,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (usuario.userName != null &&
                                                  usuario
                                                      .userName!
                                                      .isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  '@${usuario.userName}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        _buildUserTypeTag(
                                          usuario.idTipoUsuario,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  ),
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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormRegisterView()),
          );
          if (result == true) {
            _fetchUsuarios(); // Vuelve a cargar la lista
          }
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

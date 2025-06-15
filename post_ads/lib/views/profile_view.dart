import 'package:flutter/material.dart';
import 'package:post_ads/config/config.dart';
import 'package:post_ads/models/usuario.dart';
import 'package:post_ads/services/session_manager.dart';
import 'package:post_ads/views/all_users_view.dart';
import 'package:post_ads/views/user_data_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Usuario? usuario;

  @override
  void initState() {
    super.initState();
    _loadUsuario();
  }

  Future<void> _loadUsuario() async {
    final u = await SessionManager.getUsuario();
    setState(() {
      usuario = u;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildProfileView();
  }

  Widget _buildProfileView() {
    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Perfíl',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar con borde y sombra
              CircleAvatar(
                backgroundColor: Colors.indigo.shade50,
                radius: 80,
                backgroundImage:
                    (usuario!.fotoUsuario != null &&
                            usuario!.fotoUsuario!.isNotEmpty)
                        ? NetworkImage('$apiBaseUrl${usuario!.fotoUsuario}')
                        : null,
                child:
                    (usuario!.fotoUsuario == null ||
                            usuario!.fotoUsuario!.isEmpty)
                        ? Icon(Icons.person, color: Colors.indigo, size: 120)
                        : null,
              ),
              const SizedBox(height: 18),
              Text(
                usuario!.apeUsuario != null && usuario!.apeUsuario!.isNotEmpty
                    ? '${usuario!.nomUsuario} ${usuario!.apeUsuario}'
                    : usuario!.nomUsuario,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),
              Divider(thickness: 1.2),

              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(
                    Icons.settings,
                    color: Colors.orangeAccent,
                  ),
                  title: const Text('Configuración y seguridad'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserDataView()),
                    );
                  },
                ),
              ),

              if (usuario != null && usuario!.idTipoUsuario == 1)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: ListTile(
                    leading: Icon(
                      Icons.group_sharp,
                      color: Colors.indigo.shade500,
                    ),
                    title: const Text('Gestión de usuarios'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AllUsersView()),
                      );
                    },
                  ),
                ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Cerrar sesión'),
                  onTap: () async {
                    await SessionManager.clear();
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

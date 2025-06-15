import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:post_ads/config/config.dart';

class InfoAppView extends StatefulWidget {
  const InfoAppView({super.key});

  @override
  State<InfoAppView> createState() => _InfoAppViewState();
}

class _InfoAppViewState extends State<InfoAppView> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loading = true;

    Future.wait([]).then((_) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildInfoAppView();
  }

  Widget _buildInfoAppView() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Información',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Lottie.asset(
                              'assets/lottie/info.json',
                              height: 150,
                              reverse: true,
                              repeat: true,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Post Ads',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tu plataforma de anuncios',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.indigo.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Reseña en Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.indigo,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sobre la aplicación',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Esta aplicación permite publicar y buscar anuncios de servicios y productos de manera rápida y sencilla. Nuestro objetivo es conectar a personas y negocios de tu comunidad de forma segura y eficiente.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Contacto en Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.contact_mail,
                                    color: Colors.indigo,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Contacto',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Icon(Icons.email, color: Colors.indigo),
                                  const SizedBox(width: 8),
                                  Text(
                                    'soporte@app.com',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.indigo),
                                  const SizedBox(width: 8),
                                  Text(
                                    soporteWhatsapp,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    soporteTelefono,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Copyright
                      Center(
                        child: Text(
                          '© 2025 Post Ads. Todos los derechos reservados.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

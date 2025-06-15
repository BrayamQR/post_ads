import 'package:flutter/material.dart';
import 'package:post_ads/config/config.dart';
import 'package:post_ads/models/usuario.dart';
import 'package:post_ads/services/session_manager.dart';
import 'package:post_ads/views/home_view.dart';
import 'package:post_ads/views/login_view.dart';
import 'package:post_ads/views/profile_view.dart';
import 'package:post_ads/views/splash_screen.dart';
import 'package:post_ads/views/user_ads_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        quill.FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.indigo.shade700,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.grey.shade100,
        ),
      ),
      home: SplashScreen(),
      routes: {
        '/home': (context) => MainView(),
        '/login': (context) => LoginView(),
        '/userAds': (context) => MainView(initialIndex: 1),
        '/profile': (context) => MainView(initialIndex: 2),
      },
    );
  }
}

class MainView extends StatefulWidget {
  final int initialIndex;
  const MainView({super.key, this.initialIndex = 0});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Usuario? usuario;

  int _selectedIndex = 0;
  bool _isLoadingView = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await SessionManager.getUsuario();
    setState(() {
      usuario = u;
    });
  }

  final List<Widget Function()> _views = [
    () => HomeView(),
    () => UserAdsView(),
    () => ProfileView(),
  ];

  void _onItemTapped(int index) async {
    if (_selectedIndex == index) return;
    setState(() {
      _isLoadingView = true;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _selectedIndex = index;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isLoadingView = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(toolbarHeight: 1),
      body: _views[_selectedIndex](),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap:
              _isLoadingView
                  ? null
                  : (index) async {
                    if ((index == 1 || index == 2) &&
                        (usuario == null || usuario!.nomUsuario.isEmpty)) {
                      final result = await Navigator.pushNamed(
                        context,
                        '/login',
                      );
                      if (result == true) {
                        await _loadUser();
                        setState(() {
                          _selectedIndex = 2;
                        });
                      }
                      return;
                    }
                    _onItemTapped(index);
                  },
          selectedItemColor: Colors.indigo.shade600,
          unselectedItemColor: Colors.grey.shade600,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: 'Mis anuncios',
            ),
            BottomNavigationBarItem(
              icon:
                  (usuario != null &&
                          usuario!.fotoUsuario != null &&
                          usuario!.fotoUsuario!.isNotEmpty)
                      ? CircleAvatar(
                        backgroundImage: NetworkImage(
                          '$apiBaseUrl${usuario!.fotoUsuario}',
                        ),
                        radius: 14,
                      )
                      : const Icon(Icons.account_circle),
              label: usuario?.nomUsuario ?? 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

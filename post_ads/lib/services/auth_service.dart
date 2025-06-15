import 'package:url_launcher/url_launcher.dart';
import 'package:post_ads/config/config.dart';

class AuthService {
  final String backendUrl = '$apiBaseUrl/api/auth/google';

  Future<void> signInWithGoogle() async {
    final url = Uri.parse(backendUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('No se pudo abrir el navegador');
    }
  }
}

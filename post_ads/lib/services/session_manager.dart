import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:post_ads/models/usuario.dart';

class SessionManager {
  static final _storage = FlutterSecureStorage();

  static Future<Usuario?> getUsuario() async {
    final userJson = await _storage.read(key: 'user');
    if (userJson != null) {
      return Usuario.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  static Future<void> saveUsuario(Usuario usuario) async {
    await _storage.write(key: 'user', value: jsonEncode(usuario.toJson()));
  }

  static Future<void> clear() async {
    await _storage.delete(key: 'user');
    await _storage.delete(key: 'jwt_token');
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }
}

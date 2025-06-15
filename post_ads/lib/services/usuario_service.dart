import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:post_ads/config/config.dart';
import 'package:post_ads/models/usuario.dart';
import 'dart:io';

class UsuarioService {
  final String baseUrl = '$apiBaseUrl/api/user';

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'passUsuario': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al iniciar sesión');
    }
  }

  Future<Map<String, dynamic>> registerUsuario(
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/reguser');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al registrar usuario');
    }
  }

  Future<Map<String, dynamic>> sendRecoveryCode(String email) async {
    final url = Uri.parse('$baseUrl/verify-email');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'emailUsuario': email}),
    );

    try {
      final data = jsonDecode(response.body);
      final success = response.statusCode == 200;
      return {
        'success': success,
        'message':
            data['message'] ??
            (success ? 'Código enviado' : 'Error al enviar el código'),
      };
    } catch (_) {
      return {'success': false, 'message': 'Error al enviar el código'};
    }
  }

  Future<Map<String, dynamic>> verifyRecoveryCode({
    required String email,
    required String code,
  }) async {
    final url = Uri.parse('$baseUrl/verify-code');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'emailUsuario': email, 'codigo': code}),
    );

    try {
      final data = jsonDecode(response.body);
      final success = response.statusCode == 200;
      return {
        'success': success,
        'message':
            data['message'] ??
            (success ? 'Código verificado' : 'Código inválido o expirado'),
      };
    } catch (_) {
      return {'success': false, 'message': 'Error al verificar el código'};
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/password-reset');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'emailUsuario': email,
        'codigo': code,
        'nuevaPassword': newPassword,
      }),
    );

    try {
      final data = jsonDecode(response.body);
      final success = response.statusCode == 200;
      return {
        'success': success,
        'message':
            data['message'] ??
            (success
                ? 'Contraseña actualizada'
                : 'No se pudo actualizar la contraseña'),
      };
    } catch (_) {
      return {'success': false, 'message': 'Error al actualizar la contraseña'};
    }
  }

  Future<List<Usuario>> fetchAllUsers() async {
    final url = Uri.parse('$baseUrl/all');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener la lista de usuarios');
    }
  }

  Future<Map<String, dynamic>> resetPasswordToUserName(int idUsuario) async {
    final url = Uri.parse('$baseUrl/restore-password/$idUsuario');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': 'Contraseña restablecida correctamente',
      };
    } else {
      return {
        'success': false,
        'message': 'No se pudo restablecer la contraseña',
      };
    }
  }

  Future<Map<String, dynamic>> deactivateUser(int idUsuario) async {
    final url = Uri.parse('$baseUrl/deactivate/$idUsuario');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Usuario eliminado correctamente'};
    } else {
      return {'success': false, 'message': 'No se pudo eliminar el usuario'};
    }
  }

  Future<Usuario?> fetchUsuarioById(int idUsuario) async {
    final url = Uri.parse('$baseUrl/get/id/$idUsuario');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Usuario.fromJson(data);
    } else {
      return null;
    }
  }

  Future<String?> updateProfilePhoto(int idUsuario, File fotoUsuario) async {
    final url = Uri.parse('$baseUrl/update-photo/$idUsuario');
    final request = http.MultipartRequest('PUT', url);

    request.files.add(
      await http.MultipartFile.fromPath('fotoUsuario', fotoUsuario.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] as String?;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required int idUsuario,
    required String nuevaPassword,
    required String actualPassword,
  }) async {
    final url = Uri.parse('$baseUrl/change-password/$idUsuario');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nuevaPassword': nuevaPassword,
        'actualPassword': actualPassword,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': data['message'] ?? 'Contraseña cambiada correctamente.',
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'No se pudo cambiar la contraseña.',
      };
    }
  }

  Future<Map<String, dynamic>> updateUserNameAndEmail({
    required int idUsuario,
    required String userName,
    required String emailUsuario,
  }) async {
    final url = Uri.parse('$baseUrl/update-verification/$idUsuario');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userName': userName, 'emailUsuario': emailUsuario}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message':
            data['message'] ?? 'Usuario y correo modificados correctamente.',
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'No se pudo modificar usuario y correo.',
      };
    }
  }

  Future<Map<String, dynamic>> updatePersonalData({
    required int idUsuario,
    required String nomUsuario,
    required String apeUsuario,
  }) async {
    final url = Uri.parse('$baseUrl/update-personal-data/$idUsuario');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nomUsuario': nomUsuario, 'apeUsuario': apeUsuario}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message':
            data['message'] ?? 'Datos personales actualizados correctamente.',
      };
    } else {
      return {
        'success': false,
        'message':
            data['message'] ??
            'No se pudieron actualizar los datos personales.',
      };
    }
  }

  Future<Map<String, dynamic>> verifyEmailCode({
    required String emailUsuario,
    required String codigo,
  }) async {
    final url = Uri.parse('$baseUrl/verify-email-code');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'emailUsuario': emailUsuario, 'codigo': codigo}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': data['message'] ?? 'Correo verificado correctamente.',
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'No se pudo verificar el correo.',
      };
    }
  }
}

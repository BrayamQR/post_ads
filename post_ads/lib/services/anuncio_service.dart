import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:post_ads/models/ad.dart';
import 'package:post_ads/config/config.dart';
import 'package:post_ads/models/payment_info.dart';
import 'package:post_ads/services/session_manager.dart';

class AnuncioService {
  final String baseUrl = '$apiBaseUrl/api/ad';

  Future<List<Anuncio>> fetchAllAnuncios() async {
    final response = await http.get(Uri.parse('$baseUrl/all'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Anuncio.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener anuncios');
    }
  }

  Future<List<Anuncio>> fetchAnunciosPublicados(int idEstado) async {
    final response = await http.get(Uri.parse('$baseUrl/adbystate/$idEstado'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Anuncio.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener anuncios publicados');
    }
  }

  Future<List<Anuncio>> fetchAnunciosByUser(int idUsuario) async {
    final response = await http.get(Uri.parse('$baseUrl/adbyuser/$idUsuario'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Anuncio.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener anuncios del usuario');
    }
  }

  Future<Anuncio> fetchAnuncioById(int idAnuncio) async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/ad/get/$idAnuncio'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Anuncio.fromJson(data);
    } else {
      throw Exception('Error al obtener el anuncio');
    }
  }

  Future<Anuncio> registerAnuncio(Anuncio anuncio) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(anuncio.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Anuncio.fromJson(data);
    } else {
      throw Exception('Error al registrar el anuncio');
    }
  }

  Future<void> editAnuncio(int idAnuncio, Anuncio anuncio) async {
    final response = await http.put(
      Uri.parse('$baseUrl/edit/$idAnuncio'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(anuncio.toJson()),
    );
    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Error al editar el anuncio');
    }
  }

  Future<void> confirmarPago({
    required int idAnuncio,
    required String medioPago,
    required String numeroOperacion,
    required String nomTitular,
    required File imgComprobante,
    required double montoPago,
    required int idUsuario,
  }) async {
    final uri = Uri.parse('$baseUrl/confirm-payment/$idAnuncio');
    final request =
        http.MultipartRequest('PUT', uri)
          ..fields['nroOperacion'] = numeroOperacion
          ..fields['nomTitular'] = nomTitular
          ..fields['medioOperacion'] = medioPago
          ..fields['idUsuario'] = idUsuario.toString()
          ..fields['montoPago'] = montoPago.toString()
          ..files.add(
            await http.MultipartFile.fromPath(
              'imgComprobante',
              imgComprobante.path,
            ),
          );

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Error al confirmar el pago');
    }
  }

  Future<PaymentInfo?> fetchPaymentInfo(int idAnuncio) async {
    final response = await http.get(
      Uri.parse('$baseUrl/payment-info/$idAnuncio'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaymentInfo.fromJson(data);
    } else {
      throw Exception('Error al obtener la información del pago');
    }
  }

  Future<void> updateEstadoAnuncio({
    required int idAnuncio,
    required int idEstado,
    String? motivoEstado,
  }) async {
    final uri = Uri.parse('$baseUrl/editstate/$idAnuncio');
    final token = await SessionManager.getToken();

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'idEstado': idEstado, 'motivoEstado': motivoEstado}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el estado del anuncio');
    }
  }
}

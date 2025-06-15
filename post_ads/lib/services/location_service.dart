import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:post_ads/models/location.dart';
import 'package:post_ads/config/config.dart';

class LocationService {
  final String baseUrl = '$apiBaseUrl/api/location';

  Future<List<Distrito>> fetchDistritosAnidados() async {
    final response = await http.get(Uri.parse('$baseUrl/distritos-anidados'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Distrito.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener distritos anidados');
    }
  }
}

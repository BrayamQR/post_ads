import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:post_ads/models/generic_list.dart';
import 'package:post_ads/config/config.dart';

class GenericListService {
  final String baseUrl = '$apiBaseUrl/api/genericList';

  Future<List<GenericList>> fetchCategorias() async {
    final response = await http.get(Uri.parse('$baseUrl/categorys'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => GenericList.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener categorías');
    }
  }

  Future<List<GenericList>> fetchTiposPorCategoria(int categoriaId) async {
    final response = await http.get(Uri.parse('$baseUrl/types/$categoriaId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => GenericList.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener tipos para la categoría');
    }
  }

  Future<List<GenericList>> fetchJornadasPorCategoria(int categoriaId) async {
    final response = await http.get(Uri.parse('$baseUrl/days/$categoriaId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => GenericList.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener jornadas para la categoría');
    }
  }

  Future<List<GenericList>> fetchEstados() async {
    final response = await http.get(Uri.parse('$baseUrl/states'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => GenericList.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener estados');
    }
  }

  Future<List<GenericList>> fetchTiposUsuario() async {
    final response = await http.get(Uri.parse('$baseUrl/user-types'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => GenericList.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener tipos de usuario');
    }
  }
}

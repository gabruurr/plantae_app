import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/plant.dart';

class ApiService {
  static const String _baseUrl =
      'https://enfuptvhruhrmcnqggzv.supabase.co/rest/v1';
  static const String _apiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVuZnVwdHZocnVocm1jbnFnZ3p2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4OTQ1MzMsImV4cCI6MjA2NjQ3MDUzM30.9x9KP5etthTv-EfsXbVw2x4rUg73hLOQZ1MTeiL94gM';

  static final Map<String, String> _headers = {
    'apikey': _apiKey,
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  // get /plants
  Future<List<Plant>> getPlants() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/plants?select=*&order=created_at.desc'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Plant.fromMap(json)).toList();
    } else {
      throw Exception('Falha ao carregar plantas');
    }
  }

  //post /plants
  Future<Plant> addPlant(Plant plant) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/plants'),
      headers: _headers,
      body: plant.toJson(),
    );

    if (response.statusCode == 201) {
      // A resposta contém o objeto criado, incluindo o ID e created_at
      final List<dynamic> data = json.decode(response.body);
      return Plant.fromMap(data.first);
    } else {
      throw Exception('Falha ao adicionar planta');
    }
  }
}
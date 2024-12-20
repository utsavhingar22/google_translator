import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class ApiService {

  Future<List<Map<String, dynamic>>> fetchLanguages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/languages'),
      headers: apiHeaders,
    );
    if (kDebugMode) {
      print('API Response of Language: ${response.body}');
    }
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data']['languages'] as List)
          .map((lang) => {'language': lang['language'], 'name': lang['name']})
          .toList();
    } else {
      if (response.statusCode == 403) {
        throw Exception('Permission Denied: Check your API key.');
      }
      throw Exception('Failed to load languages');
    }
  }

  Future<String> translate(String text, String source, String target) async {
    final body = {
      'q': text,
      'source': source,
      'target': target,
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: apiHeaders,
        body: body, // Send as application/x-www-form-urlencoded
      );

      if (kDebugMode) {
        print('Request URL: ${response.request?.url}');
        print('Request Body: $body');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['translations'][0]['translatedText'];
      } else {
        if (kDebugMode) {
          print('API Response: ${response.body}');
        }
        if (response.statusCode == 403) {
          throw Exception('Permission Denied: Check your API key.');
        }
        throw Exception('Failed to translate text');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred: $e');
      }
      rethrow;
    }
  }


  Future<String> detectLanguage(String text) async {
    final body = {
      'q': text,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/detect'),
      headers: apiHeaders,
      body: body, // Send as application/x-www-form-urlencoded
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['detections'][0][0]['language'];
    } else {
      if (kDebugMode) {
        print('API Response: ${response.body}');
      }
      if (response.statusCode == 403) {
        throw Exception('Permission Denied: Check your API key.');
      }
      throw Exception('Failed to detect language');
    }
  }
}

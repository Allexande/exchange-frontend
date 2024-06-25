import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';
import 'tokenStorage.dart';

class ConnectionController {
  static const String baseUrl = 'https://82.148.29.11:8080';

  static Future<http.Client> createHttpClient() async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return IOClient(ioc);
  }

  static Future<http.Response> getRequest(String endpoint) async {
    final client = await createHttpClient();
    final url = Uri.parse('$baseUrl$endpoint');
    String token = (await TokenStorage.getToken()) ?? '';

    final headers = {
      'Authorization': '$token',
    };

    print('Request URL: $url');
    print('Request Headers: $headers');

    final response = await client.get(url, headers: headers);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return response;
  }

static Future<http.Response> postRequest(String endpoint, Map<String, dynamic> body) async {
  final client = await createHttpClient();
  final url = Uri.parse('$baseUrl$endpoint');
  String token = (await TokenStorage.getToken()) ?? '';

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': '$token',
  };

  print('Request URL: $url');
  print('Request Headers: $headers');
  print('Request Body: $body');

  final response = await client.post(url, headers: headers, body: json.encode(body));

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  return response;
}


  static Future<http.Response> putRequest(String endpoint, Map<String, dynamic> body) async {
    final client = await createHttpClient();
    final url = Uri.parse('$baseUrl$endpoint');
    String token = (await TokenStorage.getToken()) ?? '';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': '$token',
    };

    print('Request URL: $url');
    print('Request Headers: $headers');
    print('Request Body: $body');

    final response = await client.put(url, headers: headers, body: json.encode(body));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return response;
  }

  static Future<http.Response> deleteRequest(String endpoint) async {
    final client = await createHttpClient();
    final url = Uri.parse('$baseUrl$endpoint');
    String token = (await TokenStorage.getToken()) ?? '';

    final headers = {
      'Authorization': '$token',
    };

    print('Request URL: $url');
    print('Request Headers: $headers');

    final response = await client.delete(url, headers: headers);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return response;
  }

  static Future<bool> isAnonymous() async {
    String token = await TokenStorage.getToken() ?? '';
    return token.isEmpty;
  }
}
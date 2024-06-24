import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import '../controllers/pagesList.dart';

class TestLoginPage extends StatefulWidget {
  final void Function(PageType) onPageChange;

  TestLoginPage({Key? key, required this.onPageChange}) : super(key: key);

  @override
  _TestLoginPageState createState() => _TestLoginPageState();
}

class _TestLoginPageState extends State<TestLoginPage> {
  String _output = '';
  String _token = '';
  final String _baseUrl = 'https://82.148.29.11:8080';

  @override
  void initState() {
    super.initState();
    _login();
  }

  Future<http.Client> createClient() async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return IOClient(ioc);
  }

  Future<void> _login() async {
    String url = '$_baseUrl/login';
    Map<String, dynamic> body = {'login': 'homelander', 'password': 'whereismyson'};

    try {
      var client = await createClient();
      var response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      client.close();

      setState(() {
        _output += "Request to /login:\n${json.encode(body)}\n\n";
        _output += "Response from /login:\n${response.body}\n\n";
        print("Request to /login: ${json.encode(body)}");
        print("Response from /login: ${response.body}");
      });

      var data = json.decode(response.body);
      if (data.containsKey('token')) {
        _token = data['token'];
        _getUserInfo();
      }
    } catch (e) {
      setState(() {
        _output += "Error making login request: $e\n";
      });
      print("Error making login request: $e");
    }
  }

Future<void> _getUserInfo() async {
  String url = '$_baseUrl/user/me';
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': '$_token'  
  };

  try {
    var client = await createClient();
    var request = http.Request('GET', Uri.parse(url))
      ..headers.addAll(headers);
    var streamedResponse = await client.send(request);
    var response = await http.Response.fromStream(streamedResponse);

    client.close();

    setState(() {
      _output += "Experiment Request to /user/me:\nURL: $url\nHeaders: ${json.encode(headers)}\n\n";
      _output += "Experiment Response from /user/me:\n${response.body}\n\n";
      print("Experiment Request to /user/me: URL: $url, Headers: ${json.encode(headers)}");
      print("Experiment Response from /user/me: ${response.body}");
    });
  } catch (e) {
    setState(() {
      _output += "Error in experiment user/me request: $e\n";
    });
    print("Error in experiment user/me request: $e");
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(_output),
        ),
      ),
    );
  }
}

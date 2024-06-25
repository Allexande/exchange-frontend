/*
  Login page

  Asks to enter user's e-mail and password to enter the account
*/

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import '../styles/theme.dart';
import '../controllers/pagesList.dart';
import '../controllers/tokenStorage.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/connectionController.dart';

class LoginPage extends StatefulWidget {
  final void Function(PageType) onPageChange;
  final VoidCallback goBack;

  const LoginPage({super.key, required this.onPageChange, required this.goBack});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  Future<int> authenticateUser(String login, String password) async {
    const endpoint = '/login';

    final body = {
      if (isValidEmail(login)) 'email': login,
      if (!isValidEmail(login)) 'login': login,
      'password': password,
    };

    print('Request: POST $endpoint');
    print('Body: ${json.encode(body)}');

    final response = await ConnectionController.postRequest(endpoint, body);

    print('Response: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      await TokenStorage.saveToken(responseData['token']);
      return 1;
    } else {
      try {
        final errorData = json.decode(response.body);
        String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
        print('Displaying overlay with message: $errorMessage');
        MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
      } catch (e) {
        print('Displaying overlay with message: Ошибка ${response.statusCode}: ${response.body}');
        MessageOverlayManager.showMessageOverlay('Ошибка ${response.statusCode}: ${response.body}', "Понятно");
      }
      return 0;
    }
  }

  Future<int> getUserRole() async {
    const endpoint = '/user/me';

    print('Request: GET $endpoint');

    final response = await ConnectionController.getRequest(endpoint);

    print('Response: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['role'] == 'MODERATOR') {
        return 2; // MODERATOR
      } else {
        return 1; // NOT MODERATOR
      }
    } else {
      return 0; // ERROR
    }
  }

  void handleLogin() async {
    String login = _loginController.text;
    String password = _passwordController.text;

    if (login.isEmpty) {
      print('Displaying overlay with message: Вы не ввели почту или логин');
      MessageOverlayManager.showMessageOverlay("Вы не ввели почту или логин", "Понятно");
      return;
    }

    if (password.isEmpty) {
      print('Displaying overlay with message: Вы не ввели пароль');
      MessageOverlayManager.showMessageOverlay("Вы не ввели пароль", "Понятно");
      return;
    }

    int authResult = await authenticateUser(login, password);

    if (authResult == 0) {
      print('Displaying overlay with message: Не удалось найти такого пользователя');
      MessageOverlayManager.showMessageOverlay("Не удалось найти такого пользователя", "Понятно");
    } else if (authResult == 1) {
      int roleResult = await getUserRole();
      if (roleResult == 2) {
        widget.onPageChange(PageType.moderator_profile_page);
      } else if (roleResult == 1) {
        widget.onPageChange(PageType.user_page);
      } else {
        MessageOverlayManager.showMessageOverlay("Ошибка получения данных пользователя", "Понятно");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SvgPicture.asset(
                'build/assets/images/logo.svg',
                height: 100,
              ),
              Text(
                'Вход',
                style: TextStyles.subHeadline,
                textAlign: TextAlign.center,
              ),
              DefaultTextField(
                hintText: 'E-Mail или Логин',
                controller: _loginController,
                keyboardType: TextInputType.emailAddress,
              ),
              PasswordTextField(
                hintText: 'Пароль',
                controller: _passwordController,
                keyboardType: TextInputType.text,
              ),
              MainButton(
                text: 'Войти',
                onPressed: handleLogin,
              ),
              SubButton(
                text: 'Назад',
                onPressed: () {
                  widget.onPageChange(PageType.authorization_page);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
  Register page

  Asks to enter user's name, e-mail, contacts and password to create a new account
*/

import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:convert';
import '../styles/theme.dart';
import '../controllers/pagesList.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/connectionController.dart';

class RegistrationPage extends StatefulWidget {
  final void Function(PageType) onPageChange;
  final VoidCallback goBack;

  const RegistrationPage({super.key, required this.onPageChange, required this.goBack});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _contactsController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<int> registerUser(String name, String surname, String contacts, String email, String password) async {
    const endpoint = '/register';
    final body = {
      'name': name,
      'surname': surname,
      'description': contacts,
      'email': email,
      'login': email,
      'password': password,
    };

    print('Request Endpoint: $endpoint');
    print('Request Body: $body');

    final response = await ConnectionController.postRequest(endpoint, body);

    print('Response: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return 1;
    } else {
      try {
        final errorData = json.decode(response.body);
        String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
        MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
      } catch (e) {
        MessageOverlayManager.showMessageOverlay('Ошибка ${response.statusCode}: ${response.body}', "Понятно");
      }
      return 0;
    }
  }

  void register() async {
    String name = _nameController.text;
    String surname = _surnameController.text;
    String contacts = _contactsController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (name.isEmpty) {
      MessageOverlayManager.showMessageOverlay("Введите ваше имя.", "Понятно");
      return;
    }

    if (surname.isEmpty) {
      MessageOverlayManager.showMessageOverlay("Введите вашу фамилию.", "Понятно");
      return;
    }

    if (contacts.isEmpty) {
      MessageOverlayManager.showMessageOverlay("Введите контакты, чтобы другие люди могли с Вами связаться.", "Понятно");
      return;
    }

    if (!_validateEmail(email)) {
      MessageOverlayManager.showMessageOverlay("Введите корректный email адрес.", "Понятно");
      return;
    }

    if (!_validatePassword(password)) {
      MessageOverlayManager.showMessageOverlay("Пароль должен быть минимум 8 символов, содержать цифры и буквы обоих регистров.", "Понятно");
      return;
    }

    int result = await registerUser(name, surname, contacts, email, password);

    if (result == 1) {
      widget.onPageChange(PageType.confirm_page);
    } else {
      MessageOverlayManager.showMessageOverlay("Ошибка регистрации. Попробуйте снова.", "Понятно");
    }
  }

  bool _validateEmail(String email) {
    final RegExp emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegExp.hasMatch(email);
  }

  bool _validatePassword(String password) {
    if (password.length < 8) {
      return false;
    }
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    return hasDigits && hasUpper && hasLower;
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
                'Регистрация',
                style: TextStyles.subHeadline,
                textAlign: TextAlign.center,
              ),
              DefaultTextField(
                hintText: 'Ваше имя',
                controller: _nameController,
                keyboardType: TextInputType.text,
              ),
              DefaultTextField(
                hintText: 'Ваша фамилия',
                controller: _surnameController,
                keyboardType: TextInputType.text,
              ),
              DefaultTextField(
                hintText: 'Контакты для связи',
                controller: _contactsController,
                keyboardType: TextInputType.text,
              ),
              DefaultTextField(
                hintText: 'Электронная почта',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              PasswordTextField(
                hintText: 'Пароль',
                controller: _passwordController,
                keyboardType: TextInputType.text,
              ),
              MainButton(
                text: 'Регистрация',
                onPressed: register,
              ),
              SubButton(
                text: 'Назад',
                onPressed: () {
                  widget.goBack();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageOverlay extends StatelessWidget {
  final String message;
  final String buttonText;

  MessageOverlay({required this.message, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20.0),
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

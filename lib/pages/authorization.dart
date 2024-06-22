/*
  Authorization page

  Shows the message that user should login
  Here user choises the way to get in
*/

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';

class AuthorizationPage extends StatefulWidget {
  final void Function(PageType) onPageChange;

  const AuthorizationPage({super.key, required this.onPageChange});

  @override
  _AuthorizationPageState createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MessageOverlayManager.showMessageOverlay(
        "Вы находитесь в тестовой отладочной версии приложения, некоторые функции могут быть недоступны",
        "Понятно"
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SvgPicture.asset(
                'build/assets/images/logo.svg',
                height: 100,
              ),
              const SizedBox(height: 10),
              Text(
                'После входа в аккаунт вы получите доступ ко всем возможностям',
                textAlign: TextAlign.center,
                style: TextStyles.mainText,
              ),
              const SizedBox(height: 10),
              MainButton(
                text: 'Войти',
                onPressed: () {
                  widget.onPageChange(PageType.login_page); 
                },
              ),
              MainButton(
                text: 'Зарегистрироваться',
                onPressed: () {
                  widget.onPageChange(PageType.register_page); 
                },
              ),
              SubButton(
                text: 'Войти как гость',
                onPressed: () {
                  widget.onPageChange(PageType.filters_page); 
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

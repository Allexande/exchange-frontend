/*
  Authorization page

  Shows the message that user should login
  Here user choises the way to get in
*/

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../styles/theme.dart';
import '../controllers/pagesList.dart';
import '../controllers/connectionController.dart';

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
    checkUserStatus();
  }

  Future<void> checkUserStatus() async {
    bool isAnonymous = await ConnectionController.isAnonymous();
    if (!isAnonymous) {
      widget.onPageChange(PageType.user_page);
    }
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

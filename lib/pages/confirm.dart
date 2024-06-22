/*
  Confirm page

  Asks to enter user's e-mail and password to enter the account
*/

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../styles/theme.dart';
import '../controllers/pagesList.dart';


class ConfirmPage extends StatefulWidget {
  final void Function(PageType) onPageChange;

  const ConfirmPage({required this.onPageChange});

  @override
  _ConfirmPageState createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
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
              Text(
                'На введенный адрес электронной почты была отправлена ссылка для подтверждения. После перехода по ней вы сможете войти.',
                textAlign: TextAlign.center,
                style: TextStyles.mainText,
              ),
              SizedBox(height: 20),
              MainButton(
                text: 'К входу',
                onPressed: () => widget.onPageChange(PageType.login_page),
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

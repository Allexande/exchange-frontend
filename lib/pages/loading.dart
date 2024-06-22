/*
  Loading page

  Checks if the app builded and then move to the authorization page
*/

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../styles/theme.dart';
import 'dart:async';
import '../controllers/pagesList.dart';

class LoadingPage extends StatefulWidget {
  final void Function(PageType) onPageChange;

  LoadingPage({required this.onPageChange});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    checkAppStatus();
  }

  void checkAppStatus() async {
    // TODO Remove timer, make status check
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      widget.onPageChange(PageType.authorization_page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'build/assets/images/logo.svg',
              height: 200,
            ),
            const SizedBox(height: 20),
            Text('МЕНЯЙСЯ!', style: TextStyles.mainHeadline, textAlign: TextAlign.center),
            //const SizedBox(height: 50),
            Text('Уют на уют', style: TextStyles.mainText, textAlign: TextAlign.center),
            const SizedBox(height: 50),
            Text('Загрузка...', style: TextStyles.subText, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

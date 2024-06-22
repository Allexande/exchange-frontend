import 'package:flutter/material.dart';
import 'dart:convert';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../controllers/connectionController.dart';

class RedactProfilePage extends StatefulWidget {
  final void Function(PageType) onPageChange;

  RedactProfilePage({required this.onPageChange});

  @override
  _RedactProfilePageState createState() => _RedactProfilePageState();
}

class _RedactProfilePageState extends State<RedactProfilePage> {
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _socialsController = TextEditingController();

  @override
  void dispose() {
    _infoController.dispose();
    _socialsController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    const endpoint = '/user/edit';

    final body = {
      'description': _infoController.text,
      'socials': _socialsController.text,
      
    };

    print('Request Endpoint: $endpoint');
    print('Request Body: $body');

    final response = await ConnectionController.putRequest(endpoint, body);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (mounted) {
        MessageOverlayManager.showMessageOverlay("Профиль успешно обновлен", "ОК");
        widget.onPageChange(PageType.user_page);
      }
    } else {
      if (mounted) {
        try {
          final errorData = json.decode(response.body);
          String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
          MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
        } catch (e) {
          String errorMessage = 'Ошибка ${response.statusCode}: ${response.body}';
          MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Редактирование профиля",
              style: TextStyles.mainHeadline,
              textAlign: TextAlign.center,
            ),
            Text(
              "Имя и фамилия:",
              style: TextStyles.subHeadline,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DefaultTextField(
                hintText: 'Имя и фамилия',
                controller: _infoController,
              ),
            ),
            Text(
              "Описание:",
              style: TextStyles.subHeadline,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DefaultTextField(
                hintText: 'Описание',
                controller: _socialsController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: MainButton(
                onPressed: _updateProfile,
                text: 'Подтвердить',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SubButton(
                onPressed: () {
                  widget.onPageChange(PageType.user_page);
                },
                text: 'Назад',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

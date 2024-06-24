/*
  Redact page

  Gives tools to upload new contacts and avatar image
*/

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../controllers/connectionController.dart';

class RedactProfilePage extends StatefulWidget {
  final void Function(PageType) onPageChange;
  final VoidCallback goBack;

  const RedactProfilePage({super.key, required this.onPageChange, required this.goBack});

  @override
  // ignore: library_private_types_in_public_api
  _RedactProfilePageState createState() => _RedactProfilePageState();
}

class _RedactProfilePageState extends State<RedactProfilePage> {
  final TextEditingController _infoController = TextEditingController();
  //final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  
  get http => null;

  @override
  void dispose() {
    _infoController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    const endpoint = '/user/edit';

    final body = {
      'description': _infoController.text,
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

  Future<void> _pickImage() async {
    MessageOverlayManager.showMessageOverlay("В данный момент загрузка фото невозможна", "Понятно");
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
              style: TextStyles.subHeadline,
              textAlign: TextAlign.center,
            ),
            MainButton(
              onPressed: _pickImage,
              text: 'Загрузить аватар',
            ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Image.file(
                  File(_selectedImage!.path),
                  height: 200,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              "Контакты:",
              style: TextStyles.subHeadline,
              textAlign: TextAlign.left,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: DefaultTextField(
                hintText: 'Описание',
                controller: _infoController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: MainButton(
                onPressed: _updateProfile,
                text: 'Подтвердить',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: SubButton(
                onPressed: () {
                  widget.goBack();
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

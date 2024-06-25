import 'package:exchange/controllers/pagesList.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/connectionController.dart';
import '../controllers/tokenStorage.dart';

class ModerProfilePage extends StatefulWidget {
  final void Function(PageType) onPageChange;

  ModerProfilePage({required this.onPageChange});

  @override
  _ModerProfilePageState createState() => _ModerProfilePageState();
}

class _ModerProfilePageState extends State<ModerProfilePage> {
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final endpoint = '/user/me';
    final response = await ConnectionController.getRequest(endpoint);

    if (response.statusCode == 200) {
      setState(() {
        profileData = json.decode(utf8.decode(response.bodyBytes));
      });
    } else {
      final errorData = json.decode(utf8.decode(response.bodyBytes));
      String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
      MessageOverlayManager.showMessageOverlay("Ошибка", errorMessage);
    }
  }

  void _logout() async {
    await TokenStorage.clear();
    widget.onPageChange(PageType.authorization_page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Вы находитесь в аккаунте модератора',
              textAlign: TextAlign.center,
              style: TextStyles.subHeadline,
            ),
            SizedBox(height: 20),
            profileData != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Имя: ${profileData!['name']}',
                        style: TextStyles.mainText,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Фамилия: ${profileData!['surname']}',
                        style: TextStyles.mainText,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Логин: ${profileData!['login']}',
                        style: TextStyles.mainText,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Описание: ${profileData!['description']}',
                        style: TextStyles.mainText,
                      ),
                    ],
                  )
                : Center(child: CircularProgressIndicator()),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: SubButton(
                onPressed: _logout,
                text: 'Выйти',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

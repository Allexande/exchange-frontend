import 'dart:convert';
import 'package:flutter/material.dart';
import '../styles/theme.dart';
import '../models/user.dart' as user_model;
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../controllers/connectionController.dart';

class UserProfilePage extends StatefulWidget {
  final void Function(PageType, {int? userId}) onPageChange;
  final int? userId;

  UserProfilePage({Key? key, required this.onPageChange, this.userId}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isOwner = false;
  user_model.UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final endpoint = widget.userId == null ? '/user/me' : '/user/${widget.userId}';
    print('Requesting data from endpoint: $endpoint');
    final response = await ConnectionController.getRequest(endpoint);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Parsed data: $data');
      if (data['id'] == 0 || data['login'] == null) {
        print('Invalid user data: $data');
        MessageOverlayManager.showMessageOverlay("Ошибка при загрузке данных пользователя", "Понятно");
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          user = user_model.UserModel.fromJson(data);
          isOwner = widget.userId == null;
          isLoading = false;
        });
        print("IS OWNER???");
        print(isOwner);
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      final errorMessage = widget.userId == null
          ? "Ошибка при загрузке данных пользователя"
          : "Пользователя с ID=${widget.userId} не существует";
      MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : user == null
              ? Center(child: Text("Ошибка при загрузке данных пользователя", style: TextStyles.mainText))
              : SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(Icons.account_circle, size: 120),
                          Text(
                            '${user!.name} ${user!.surname}',
                            style: TextStyles.mainHeadline,
                            textAlign: TextAlign.center,
                          ),
                          Text('Имя:', style: TextStyles.subHeadline),
                          Text(user!.name, textAlign: TextAlign.center, style: TextStyles.mainText),
                          Text('Соцсети:', style: TextStyles.subHeadline),
                          Text(user!.surname, textAlign: TextAlign.center, style: TextStyles.mainText),
                          Text('Публикации:', style: TextStyles.subHeadline),
                          Text('Отсутствуют', textAlign: TextAlign.center, style: TextStyles.mainText),
                          Text('Комментарии:', style: TextStyles.subHeadline),
                          Text('Отсутствуют', textAlign: TextAlign.center, style: TextStyles.mainText),
                          if (isOwner)
                            MainButton(
                              text: 'Редактировать',
                              onPressed: () {
                                widget.onPageChange(PageType.redact_page);
                              },
                            )
                          else
                            MainButton(
                              text: 'Пожаловаться',
                              onPressed: () {
                                MessageOverlayManager.showMessageOverlay("Приложение пока что не может позволить увидеть всю информацию о чужом аккаунте", "Понятно");
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

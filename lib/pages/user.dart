import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../styles/theme.dart';
import '../models/user.dart' as user_model;
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../controllers/connectionController.dart';

class UserProfilePage extends StatefulWidget {
  final void Function(PageType, {int? userId, int? reviewId, int? houseId}) onPageChange;
  final int? userId;

  UserProfilePage({Key? key, required this.onPageChange, this.userId}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isOwner = false;
  user_model.UserModel? user;
  bool isLoading = true;
  Uint8List? avatarImage;
  List<Map<String, dynamic>> userReviews = [];
  List<Map<String, dynamic>> userHouses = [];

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
    print('Response body: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
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
        loadAvatar();
        loadUserReviews();
        loadUserHouses();
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

  Future<void> loadAvatar() async {
    final endpoint = '/users/${user!.id}/avatar';
    final response = await ConnectionController.getRequest(endpoint);

    if (response.statusCode == 200) {
      setState(() {
        avatarImage = base64Decode(response.body);
      });
    }
  }

  Future<void> loadUserReviews() async {
    final endpoint = '/users/${user!.id}/reviews';
    final response = await ConnectionController.getRequest(endpoint);

    if (response.statusCode == 200) {
      setState(() {
        userReviews = List<Map<String, dynamic>>.from(json.decode(utf8.decode(response.bodyBytes)));
      });
    }
  }

  Future<void> loadUserHouses() async {
    final endpoint = '/users/${user!.id}/houses';
    final response = await ConnectionController.getRequest(endpoint);

    if (response.statusCode == 200) {
      setState(() {
        userHouses = List<Map<String, dynamic>>.from(json.decode(utf8.decode(response.bodyBytes)));
      });
    }
  }

  Widget _buildUserAvatar() {
    if (avatarImage != null) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: MemoryImage(avatarImage!),
      );
    } else {
      return Column(
        children: [
          Icon(Icons.account_circle, size: 120),
          Text("Аватар не загружен", style: TextStyles.subText),
        ],
      );
    }
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Отзывы:', style: TextStyles.subHeadline),
        userReviews.isEmpty
            ? Text('Отсутствуют', textAlign: TextAlign.center, style: TextStyles.mainText)
            : Column(
                children: userReviews.map((review) {
                  return GestureDetector(
                    onTap: () {
                      widget.onPageChange(PageType.review_page, reviewId: review['id']);
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Рейтинг: ${review['rating']}',
                                    style: TextStyles.smallHeadline,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    review['description'] ?? '',
                                    style: TextStyles.mainText,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildHousesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Публикации:', style: TextStyles.subHeadline),
        userHouses.isEmpty
            ? Text('Отсутствуют', textAlign: TextAlign.center, style: TextStyles.mainText)
            : Column(
                children: userHouses.map((house) {
                  return GestureDetector(
                    onTap: () {
                      widget.onPageChange(PageType.declaration_page, houseId: house['id']);
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${house['city']}, ${house['address']}',
                                    style: TextStyles.smallHeadline,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    house['description'] ?? '',
                                    style: TextStyles.mainText,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  void _logout() {
    // TODO Clear token
    widget.onPageChange(PageType.login_page);
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
                          _buildUserAvatar(),
                          SizedBox(height: 20),
                          Text(
                            '${user!.name} ${user!.surname}',
                            style: TextStyles.mainHeadline,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          Text('Контакты:', style: TextStyles.subHeadline),
                          Text(user!.description ?? '', textAlign: TextAlign.left, style: TextStyles.mainText),
                          SizedBox(height: 20),
                          _buildReviewsSection(),
                          SizedBox(height: 20),
                          _buildHousesSection(),
                          SizedBox(height: 20),
                          if (isOwner)
                            Column(
                              children: [
                                MainButton(
                                  text: 'Редактировать',
                                  onPressed: () {
                                    widget.onPageChange(PageType.redact_page);
                                  },
                                ),
                                MainButton(
                                  text: 'Выйти',
                                  onPressed: _logout,
                                ),
                              ],
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

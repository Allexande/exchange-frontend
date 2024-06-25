import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../styles/theme.dart';
import '../models/user.dart' as user_model;
import '../models/house.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../controllers/connectionController.dart';
import '../widgets/houseCard/housesCardList.dart';
import '../controllers/tokenStorage.dart';

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
  List<House> userHouses = [];
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    checkUserAuthorization();
  }

  Future<void> checkUserAuthorization() async {
    bool isAnonymous = await ConnectionController.isAnonymous();
    if (isAnonymous && widget.userId == null) {
      MessageOverlayManager.showMessageOverlay(
        "У незарегистрированного пользователя нет своего аккаунта, но самое время его создать!",
        "Понятно"
      );
      widget.onPageChange(PageType.register_page);
    } else {
      await loadCurrentUserId();
      await loadUserData();
    }
  }

  Future<void> loadCurrentUserId() async {
    final response = await ConnectionController.getRequest('/user/me');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        currentUserId = data['id'];
      });
    } else {
      print('Ошибка при загрузке текущего пользователя: ${response.body}');
    }
  }

  Future<void> loadUserData() async {
    final endpoint = widget.userId == null ? '/user/me' : '/users/${widget.userId}';
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
          isOwner = widget.userId == null || currentUserId == widget.userId;
          isLoading = false;
        });
        await loadAvatar();
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
      if (mounted) {
        setState(() {
          avatarImage = response.bodyBytes;
        });
      }
    } else {
      print('Ошибка при загрузке аватара: ${response.body}');
    }
  }

  Future<void> loadUserReviews() async {
    final endpoint = '/users/${user!.id}/reviews-to-user';
    final response = await ConnectionController.getRequest(endpoint);

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          userReviews = List<Map<String, dynamic>>.from(json.decode(utf8.decode(response.bodyBytes)));
        });
      }
    } else {
      MessageOverlayManager.showMessageOverlay("Ошибка при загрузке отзывов: ${response.body}", "Понятно");
    }
  }

  Future<void> loadUserHouses() async {
    final endpoint = '/users/${user!.id}/houses';
    final response = await ConnectionController.getRequest(endpoint);

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
      if (mounted) {
        setState(() {
          userHouses = responseData
              .where((houseData) => houseData['status'] == 'MODERATED')
              .map((houseData) => House.fromJson(houseData))
              .toList();
        });
      }
    } else {
      MessageOverlayManager.showMessageOverlay("Ошибка при загрузке домов: ${response.body}", "Понятно");
    }
  }

  Widget _buildUserAvatar() {
    if (avatarImage != null) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: SizedBox(
            width: 120,
            height: 120,
            child: Image.memory(
              avatarImage!,
              fit: BoxFit.cover,
            ),
          ),
        ),
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
            : Container(
                height: 200, // Установите высоту контейнера
                child: ListView(
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
                                    SizedBox(height: 10),
                                    Text(
                                      'Дом: ${review['houseResponse']['city']}, ${review['houseResponse']['address']}',
                                      style: TextStyles.mainText,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Пользователь: ${review['userDtoResponse']['name']} ${review['userDtoResponse']['surname']}',
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
              ),
      ],
    );
  }

  Widget _buildHousesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Дома:', style: TextStyles.subHeadline),
        userHouses.isEmpty
            ? Text('Отсутствуют', textAlign: TextAlign.center, style: TextStyles.mainText)
            : Container(
                height: 200, 
                child: HousesCardList(
                  houses: userHouses,
                  onTap: (houseId) {
                    widget.onPageChange(PageType.declaration_page, houseId: houseId);
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Контакты:', style: TextStyles.subHeadline),
        Text(user!.description?.isEmpty ?? true
            ? 'Пользователь не оставил контактов'
            : user!.description!,
            textAlign: TextAlign.left,
            style: TextStyles.mainText,
        ),
      ],
    );
  }

  void _logout() async {
    await TokenStorage.clear();
    widget.onPageChange(PageType.login_page);
  }

  @override
  void dispose() {
    super.dispose();
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
                          _buildContactsSection(),
                          SizedBox(height: 20),
                          _buildReviewsSection(),
                          SizedBox(height: 20),
                          _buildHousesSection(),
                          SizedBox(height: 20),
                          if (isOwner)
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: MainButton(
                                    text: 'Редактировать',
                                    onPressed: () {
                                      widget.onPageChange(PageType.redact_page);
                                    },
                                  ),
                                ),
                                SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: SubButton(
                                    text: 'Выйти',
                                    onPressed: _logout,
                                  ),
                                ),
                              ],
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: MainButton(
                                text: 'Пожаловаться',
                                onPressed: () {
                                  MessageOverlayManager.showMessageOverlay("Приложение пока что не может позволить увидеть всю информацию о чужом аккаунте", "Понятно");
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

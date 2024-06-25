import 'package:flutter/material.dart';
import 'dart:convert';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../models/house.dart';
import '../controllers/connectionController.dart';

class CreateReviewPage extends StatefulWidget {
  final int? houseId;
  final void Function(PageType, {int? houseId}) onPageChange;
  final VoidCallback goBack;

  CreateReviewPage({this.houseId, required this.onPageChange, required this.goBack});

  @override
  _CreateReviewPageState createState() => _CreateReviewPageState();
}

class _CreateReviewPageState extends State<CreateReviewPage> {
  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 5;
  House? house;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    if (widget.houseId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MessageOverlayManager.showMessageOverlay(
            "Ошибка", "нужно выбрать дом на который вы оставляете отзыв");
      });
    } else {
      loadCurrentUserId();
    }
  }

  Future<void> loadCurrentUserId() async {
    final response = await ConnectionController.getRequest('/user/me');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        currentUserId = data['id'];
      });
      loadHouseData(widget.houseId!);
    } else {
      showErrorOverlay(response);
    }
  }

  Future<void> loadHouseData(int houseId) async {
    final response = await ConnectionController.getRequest('/houses/$houseId');
    if (response.statusCode == 200) {
      var houseData = House.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      if (houseData.user.id == currentUserId) {
        MessageOverlayManager.showMessageOverlay(
            "Ошибка", "Отзываться о своем доме нельзя");
        widget.onPageChange(PageType.filters_page);
      } else {
        setState(() {
          house = houseData;
        });
      }
    } else {
      showErrorOverlay(response);
    }
  }

  void showErrorOverlay(response) {
    try {
      final errorData = json.decode(response.body);
      String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
      MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
    } catch (e) {
      MessageOverlayManager.showMessageOverlay('Ошибка ${response.statusCode}: ${response.body}', "Понятно");
    }
  }

  Future<void> _publishReview() async {
    final body = {
      'houseId': widget.houseId,
      'rating': _selectedRating,
      'description': _reviewController.text,
    };

    print('Request Body: $body');

    final response = await ConnectionController.postRequest('/houses/review', body);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      MessageOverlayManager.showMessageOverlay(
          "Отзыв успешно опубликован", "Понятно");
      widget.goBack();
    } else {
      showErrorOverlay(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (house != null) ...[
                Text(
                  'Оставить отзыв о доме',
                  style: TextStyles.mainHeadline,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Город: ${house!.city}',
                  style: TextStyles.mainText,
                ),
                Text(
                  'Адрес: ${house!.address}',
                  style: TextStyles.mainText,
                ),
                Text(
                  'Владелец: ${house!.user.name} ${house!.user.surname}',
                  style: TextStyles.mainText,
                ),
                Text(
                  'Рейтинг владельца: ${house!.user.ratingSum}',
                  style: TextStyles.mainText,
                ),
                SizedBox(height: 20),
              ],
              DefaultTextField(
                hintText: 'Введите ваш отзыв здесь',
                controller: _reviewController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
              SizedBox(height: 20),
              Text(
                'Оценка:',
                style: TextStyles.mainHeadline,
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 20),
              MainButton(
                text: 'Опубликовать',
                onPressed: _publishReview,
              ),
              SizedBox(height: 10),
              SubButton(
                text: 'Назад',
                onPressed: () {
                  widget.onPageChange(PageType.authorization_page);
                },
                //onPressed: widget.goBack,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

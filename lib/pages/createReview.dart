import 'package:exchange/controllers/pagesList.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/connectionController.dart';

class CreateReviewPage extends StatefulWidget {
  final int? houseId;
  final void Function(PageType) onPageChange;

  CreateReviewPage({this.houseId, required this.onPageChange});

  @override
  _CreateReviewPageState createState() => _CreateReviewPageState();
}

class _CreateReviewPageState extends State<CreateReviewPage> {
  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 1; // Default rating

  @override
  void initState() {
    super.initState();
    if (widget.houseId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MessageOverlayManager.showMessageOverlay(
            "Ошибка", "нужно выбрать дом на который вы оставляете отзыв");
      });
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
          "Успех", "Отзыв успешно опубликован");
      Navigator.of(context).pop();
    } else {
      try {
        final errorData = json.decode(response.body);
        String errorMessage =
            'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
        MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
      } catch (e) {
        MessageOverlayManager.showMessageOverlay('Ошибка ${response.statusCode}: ${response.body}', "Понятно");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Написать отзыв'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Написать отзыв',
                style: TextStyles.mainHeadline,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
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
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

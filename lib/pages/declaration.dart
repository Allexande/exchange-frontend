import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../models/house.dart';
import '../controllers/connectionController.dart';

class DeclarationPage extends StatefulWidget {
  final int houseId;
  final void Function(PageType, {int? userId, int? houseId, int? recievedHouseId, int? givenHouseId}) onPageChange;

  DeclarationPage({required this.houseId, required this.onPageChange});

  @override
  _DeclarationPageState createState() => _DeclarationPageState();
}

class _DeclarationPageState extends State<DeclarationPage> {
  House? house;
  bool isOwner = false;
  int? userId;
  DateTimeRange? dateRange;
  List<House> userHouses = [];
  List<Uint8List> houseImages = [];

  @override
  void initState() {
    super.initState();
    loadHouseData();
  }

  Future<void> loadHouseData() async {
    final houseResponse = await ConnectionController.getRequest('/houses/${widget.houseId}');
    if (houseResponse.statusCode == 200) {
      final houseData = House.fromJson(json.decode(utf8.decode(houseResponse.bodyBytes)));
      setState(() {
        house = houseData;
      });
      loadUserData(houseData.user.id);
      loadHouseImages();
    } else {
      showErrorOverlay(houseResponse.body, houseResponse.statusCode);
    }
  }

  Future<void> loadUserData(int userId) async {
    final userResponse = await ConnectionController.getRequest('/user/me');
    if (userResponse.statusCode == 200) {
      final userData = json.decode(utf8.decode(userResponse.bodyBytes));
      setState(() {
        this.userId = userData['id'];
        isOwner = userData['id'] == userId;
      });
      loadUserHouses(userData['id']);
    } else {
      showErrorOverlay(userResponse.body, userResponse.statusCode);
    }
  }

  Future<void> loadUserHouses(int userId) async {
    final response = await ConnectionController.getRequest('/users/$userId/houses');
    if (response.statusCode == 200) {
      setState(() {
        userHouses = List<House>.from(json.decode(utf8.decode(response.bodyBytes)).map((house) => House.fromJson(house)));
      });
    } else {
      showErrorOverlay(response.body, response.statusCode);
    }
  }

  Future<void> loadHouseImages() async {
    final response = await ConnectionController.getRequest('/houses/${widget.houseId}/images');
    if (response.statusCode == 200) {
      setState(() {
        houseImages = List<Uint8List>.from(json.decode(response.body).map((image) => base64Decode(image['path'])));
      });
    } else {
      showErrorOverlay(response.body, response.statusCode);
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDateRange: dateRange,
    );
    if (picked != null && picked != dateRange) {
      setState(() {
        dateRange = picked;
      });
    }
  }

  Future<void> respondToHouse(int givenHouseId) async {
    if (dateRange == null) {
      MessageOverlayManager.showMessageOverlay("Выберите даты для сделки", "Понятно");
      return;
    }

    final startDate = DateFormat('yyyy-MM-dd').format(dateRange!.start);
    final endDate = DateFormat('yyyy-MM-dd').format(dateRange!.end);
    final body = {
      'givenHouseId': givenHouseId,
      'receivedHouseId': widget.houseId,
      'startDate': startDate,
      'endDate': endDate,
    };

    final response = await ConnectionController.postRequest('/houses/trade', body);

    if (response.statusCode == 200) {
      widget.onPageChange(PageType.deal_page, recievedHouseId: widget.houseId, givenHouseId: givenHouseId);
    } else {
      showErrorOverlay(response.body, response.statusCode);
    }
  }

  Future<void> deleteHouse() async {
    final response = await ConnectionController.deleteRequest('/houses/${widget.houseId}');
    if (response.statusCode == 200) {
      widget.onPageChange(PageType.results_page);
    } else {
      showErrorOverlay(response.body, response.statusCode);
    }
  }

  void showErrorOverlay(String responseBody, int statusCode) {
    try {
      final errorData = json.decode(responseBody);
      String errorMessage = 'Ошибка $statusCode: ${errorData['message'] ?? 'Неизвестная ошибка'}';
      MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
    } catch (e) {
      String errorMessage = 'Ошибка $statusCode: $responseBody';
      MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
    }
  }

  String safeDecode(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }
    try {
      return utf8.decode(value.codeUnits);
    } catch (e) {
      return value;
    }
  }

  Widget _buildHouseImages() {
    if (houseImages.isEmpty) {
      return Center(
        child: Text(
          'Фотографии для этого дома отсутствуют',
          style: TextStyles.mainText,
        ),
      );
    } else if (houseImages.length == 1) {
      return Image.memory(
        houseImages[0],
        height: 200,
      );
    } else {
      return SizedBox(
        height: 200,
        child: PageView(
          children: houseImages.map((image) => Image.memory(image)).toList(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: house == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Предложение',
                        style: TextStyles.mainHeadline,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _buildHouseImages(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Город',
                        style: TextStyles.subHeadline,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        safeDecode(house!.city),
                        style: TextStyles.mainText,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Адрес',
                        style: TextStyles.subHeadline,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        safeDecode(house!.address),
                        style: TextStyles.mainText,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Описание',
                        style: TextStyles.subHeadline,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        safeDecode(house!.description),
                        style: TextStyles.mainText,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        widget.onPageChange(PageType.user_page, userId: house!.user.id);
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          "${safeDecode(house!.user.name)} ${safeDecode(house!.user.surname)}",
                          style: TextStyles.subHeadline,
                        ),
                        subtitle: Text(
                          'Рейтинг: ${house!.user.ratingSum}',
                          style: TextStyles.mainText,
                        ),
                      ),
                    ),
                    isOwner
                        ? MainButton(
                            onPressed: deleteHouse,
                            text: 'Удалить',
                          )
                        : Column(
                            children: [
                              GestureDetector(
                                onTap: () => _selectDateRange(context),
                                child: AbsorbPointer(
                                  child: DefaultTextField(
                                    hintText: dateRange == null
                                        ? 'Выберите даты'
                                        : '${DateFormat('dd/MM/yyyy').format(dateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(dateRange!.end)}',
                                    controller: TextEditingController(),
                                    keyboardType: TextInputType.datetime,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              userHouses.isEmpty
                                  ? Text(
                                      'У вас нет ни одного дома, чтобы предложить его взамен',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.mainText,
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: userHouses.length,
                                      itemBuilder: (context, index) {
                                        final userHouse = userHouses[index];
                                        return Card(
                                          margin: EdgeInsets.symmetric(vertical: 10),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  safeDecode(userHouse.city),
                                                  style: TextStyles.smallHeadline,
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  safeDecode(userHouse.description),
                                                  style: TextStyles.mainText,
                                                ),
                                                SizedBox(height: 10),
                                                MainButton(
                                                  onPressed: () => respondToHouse(userHouse.id),
                                                  text: 'Использовать',
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}

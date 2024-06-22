import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import 'data/cities.dart';
import '../controllers/connectionController.dart';

class CreateDeclarationPage extends StatefulWidget {
  final void Function(PageType) onPageChange;

  CreateDeclarationPage({required this.onPageChange});

  @override
  _CreateDeclarationPageState createState() => _CreateDeclarationPageState();
}

class _CreateDeclarationPageState extends State<CreateDeclarationPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  DateTimeRange? dateRange;
  String? selectedCity;
  List<String> availableCities = [];
  List<String> filteredCities = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  void fetchCities() async {
    try {
      List<String> cities = await getCities();
      setState(() {
        availableCities = cities;
        filteredCities = cities;
      });
      print('Fetched cities: $cities');
    } catch (error) {
      print('Error fetching cities: $error');
      MessageOverlayManager.showMessageOverlay("Не удалось загрузить список городов", "Понятно");
    }
  }

  String getFromToDate() {
    if (dateRange == null) {
      return 'Выбрать';
    } else {
      final from = DateFormat('dd/MM/yyyy').format(dateRange!.start);
      final to = DateFormat('dd/MM/yyyy').format(dateRange!.end);
      return '$from - $to';
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
        _dateController.text = getFromToDate();
      });
    }
  }

  void _filterCities(String query) {
    setState(() {
      filteredCities = availableCities
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      MessageOverlayManager.showMessageOverlay("По техническим причинам загрузка фотографий невозможна", "Понятно");
    }
  }

  Future<void> _submitDeclaration() async {
  if (_descriptionController.text.isEmpty) {
    MessageOverlayManager.showMessageOverlay("Описание не может быть пустым", "Понятно");
    return;
  }

  if (selectedCity == null) {
    MessageOverlayManager.showMessageOverlay("Вы не выбрали город", "Понятно");
    return;
  }

  if (dateRange == null) {
    MessageOverlayManager.showMessageOverlay("Вы не выбрали даты", "Понятно");
    return;
  }

  const endpoint = '/houses';

  final body = {
    'description': _descriptionController.text,
    'city': selectedCity ?? 'Unknown',
    'address': 'Sample Address',
    'startDate': dateRange!.start.toIso8601String(),
    'endDate': dateRange!.end.toIso8601String(),
  };

  print('Request Endpoint: $endpoint');
  print('Request Body: $body');

  final response = await ConnectionController.postRequest(endpoint, body);

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    widget.onPageChange(PageType.results_page);
  } else {
    try {
      final errorData = json.decode(response.body);
      String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
      MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
    } catch (e) {
      MessageOverlayManager.showMessageOverlay('Ошибка ${response.statusCode}: ${response.body}', "Понятно");
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
              'Создать новое объявление',
              style: TextStyles.subHeadline,
              textAlign: TextAlign.center,
            ),
            MainButton(
              onPressed: _pickImage,
              text: 'Загрузить фото',
            ),
            SizedBox(height: 10),
            /*
            GestureDetector(
              onTap: () => _selectDateRange(context),
              child: AbsorbPointer(
                child: DefaultTextField(
                  hintText: 'Дата',
                  keyboardType: TextInputType.datetime,
                  controller: _dateController,
                ),
              ),
            ),
            */
            Stack(
              children: [
                DefaultTextField(
                  hintText: 'Выбрать город',
                  controller: cityController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onChanged: (query) {
                    _filterCities(query);
                    setState(() {});
                  },
                ),
                if (cityController.text.isNotEmpty && filteredCities.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 72),
                    constraints: BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.secondary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: filteredCities.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            filteredCities[index],
                            style: TextStyles.mainText,
                          ),
                          onTap: () {
                            setState(() {
                              selectedCity = filteredCities[index];
                              cityController.text = filteredCities[index];
                              filteredCities.clear();
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
            DefaultTextField(
              hintText: 'Описание',
              controller: _descriptionController,
            ),
            MainButton(
              onPressed: _submitDeclaration,
              text: 'На модерацию',
            ),
            SubButton(
              onPressed: () {
                widget.onPageChange(PageType.filters_page);
              },
              text: 'Назад',
            ),
          ],
        ),
      ),
    );
  }
}

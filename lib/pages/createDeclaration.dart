import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import 'data/cities.dart';
import '../controllers/connectionController.dart';
import '../controllers/tokenStorage.dart';

class CreateDeclarationPage extends StatefulWidget {
  final void Function(PageType) onPageChange;
  final VoidCallback goBack;

  CreateDeclarationPage({required this.onPageChange, required this.goBack});

  @override
  _CreateDeclarationPageState createState() => _CreateDeclarationPageState();
}

class _CreateDeclarationPageState extends State<CreateDeclarationPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  DateTimeRange? dateRange;
  String? selectedCity;
  List<String> availableCities = [];
  List<String> filteredCities = [];
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    checkIfAnonymous();
  }

  Future<void> checkIfAnonymous() async {
    final isAnon = await isAnonymous();
    if (isAnon) {
      MessageOverlayManager.showMessageOverlay(
        "Незарегистрированные пользователи не могут создавать объявления, пожалуйста, зарегистрируйтесь!",
        "Понятно",
      );
      widget.onPageChange(PageType.register_page);
    } else {
      fetchCities();
    }
  }

  Future<bool> isAnonymous() async {
    final token = await TokenStorage.getToken();
    return token == null;
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

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _submitDeclaration() async {
    if (_descriptionController.text.isEmpty || _addressController.text.isEmpty || selectedCity == null) {
      MessageOverlayManager.showMessageOverlay("Все поля должны быть заполнены, включая изображения", "Понятно");
      return;
    }

    const endpoint = '/houses';
    final body = {
      'description': _descriptionController.text,
      'city': selectedCity!,
      'address': _addressController.text,
    };

    final response = await ConnectionController.postRequest(endpoint, body);
    if (response.statusCode == 200) {
      final houseId = json.decode(response.body)['id'];
      if (_selectedImages.isNotEmpty) {
        await _uploadHouseImages(houseId);
      }
      widget.onPageChange(PageType.filters_page);
    } else {
      MessageOverlayManager.showMessageOverlay("Ошибка создания объявления: ${response.body}", "Понятно");
    }
  }

  Future<void> _uploadHouseImages(int houseId) async {
    final token = await TokenStorage.getToken();

    var request = http.MultipartRequest('POST', Uri.parse('${ConnectionController.baseUrl}/houses/$houseId/images'));
    request.headers['Authorization'] = '$token';
    request.headers['Content-Type'] = 'multipart/form-data';

    for (var image in _selectedImages) {
      request.files.add(await http.MultipartFile.fromPath(
        'files', image.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      MessageOverlayManager.showMessageOverlay("Изображения успешно загружены", "ОК");
    } else {
      final responseBody = await response.stream.bytesToString();
      MessageOverlayManager.showMessageOverlay("Ошибка загрузки изображений: $responseBody", "Понятно");
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
              onPressed: _pickImages,
              text: 'Загрузить фото',
            ),
            SizedBox(height: 10),
            if (_selectedImages.isNotEmpty)
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        File(_selectedImages[index].path),
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 10),
            Stack(
              children: [
                DefaultTextField(
                  hintText: 'Выбрать город',
                  controller: _cityController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onChanged: (query) {
                    _filterCities(query);
                    setState(() {});
                  },
                ),
                if (_cityController.text.isNotEmpty && filteredCities.isNotEmpty)
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
                              _cityController.text = filteredCities[index];
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
              hintText: 'Адрес',
              controller: _addressController,
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
                //widget.goBack();
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

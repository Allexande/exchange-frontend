/*
  Filters page

  Allowes to enter filters for houses search
*/

//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../styles/theme.dart';
import '../controllers/pagesList.dart';
import '../widgets/messageOverlay.dart';
import 'data/cities.dart';
import '../controllers/connectionController.dart';

class FiltersPage extends StatefulWidget {
  final void Function(PageType, {String? city, DateTimeRange? dateRange}) onPageChange;

  const FiltersPage({super.key, required this.onPageChange});

  @override
  // ignore: library_private_types_in_public_api
  _FiltersPageState createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  DateTimeRange? dateRange;
  String? selectedCity;
  TextEditingController cityController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  List<String> availableCities = [];
  List<String> filteredCities = [];

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  void fetchCities() async {
    try {
      final response = await ConnectionController.getRequest('/cities');
      if (response.statusCode == 200) {
        //List<String> cities = List<String>.from(json.decode(response.body));
        // TODO Use cities from server, not from data/cities.dart
        List<String> cities = await getCities();
        setState(() {
          availableCities = cities;
          filteredCities = cities;
        });
        print('Fetched cities: $cities');
      } else {
        throw Exception('Failed to load cities');
      }
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
        dateController.text = getFromToDate();
      });
      print('Selected date range: $picked');
    }
  }

  void _filterCities(String query) {
    setState(() {
      filteredCities = availableCities
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _applyFiltersAndNavigate() {
    if (selectedCity == null || selectedCity!.isEmpty) {
      MessageOverlayManager.showMessageOverlay("Необходимо указать город для поиска", "Понятно");
      return;
    }

    widget.onPageChange(PageType.results_page, city: selectedCity, dateRange: dateRange);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Фильтры поиска',
                  style: TextStyles.subHeadline,
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Желаемая локация:',
                  style: TextStyles.smallHeadline,
                ),
                Stack(
                  children: [
                    DefaultTextField(
                      hintText: 'Выбрать город',
                      controller: cityController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onChanged: (query) {
                        _filterCities(query);
                        setState(() {});
                      },
                    ),
                    if (cityController.text.isNotEmpty && filteredCities.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 72), 
                        constraints: const BoxConstraints(maxHeight: 200),
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
                SizedBox(height: 16),
                Text(
                  'Время пребывания:',
                  style: TextStyles.smallHeadline,
                ),
                GestureDetector(
                  onTap: () => _selectDateRange(context),
                  child: AbsorbPointer(
                    child: DefaultTextField(
                      hintText: getFromToDate(),
                      controller: dateController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                MainButton(
                  onPressed: _applyFiltersAndNavigate,
                  text: 'Применить',
                ),
                MainButton(
                  onPressed: () {
                    widget.onPageChange(PageType.create_declaration_page);
                  },
                  text: '+ СОЗДАТЬ',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

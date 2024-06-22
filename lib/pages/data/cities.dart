Future<List<String>> getCities() async {
  // Вместо запроса на сервер возвращаем закомментированный список
  const List<String> russianCities = [
    'Москва',
    'Санкт-Петербург',
    'Новосибирск',
    'Екатеринбург',
    'Нижний Новгород',
    'Казань',
    'Челябинск',
    'Омск',
    'Самара',
    'Ростов-на-Дону',
    'Уфа',
    'Красноярск',
    'Воронеж',
    'Пермь',
    'Волгоград',
    // Можно продолжать, но пока что хватит и этого
  ];

  return russianCities;
}

/*
Future<List<String>> getCities() async {
  final url = Uri.parse('http://82.148.29.11:8080/cities');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> citiesJson = json.decode(response.body);
    return List<String>.from(citiesJson);
  } else {
    throw Exception('Failed to load cities');
  }
}
*/
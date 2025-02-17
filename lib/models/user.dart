class UserModel {
  final int id;
  final String login;
  final String surname;
  final String name;
  final int totalReviews;
  final int ratingSum;
  final String? description;

  UserModel({
    required this.id,
    required this.login,
    required this.surname,
    required this.name,
    required this.totalReviews,
    required this.ratingSum,
    this.description,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      login: json['login'],
      surname: json['surname'],
      name: json['name'],
      totalReviews: json['totalReviews'],
      ratingSum: json['ratingSum'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'surname': surname,
      'name': name,
      'totalReviews': totalReviews,
      'ratingSum': ratingSum,
      'description': description,
    };
  }
}

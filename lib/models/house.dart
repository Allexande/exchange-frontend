import 'user.dart'; 

class User {
  final int id;
  final String login;
  final String surname;
  final String name;
  final int totalReviews;
  final int ratingSum;

  User({
    required this.id,
    required this.login,
    required this.surname,
    required this.name,
    required this.totalReviews,
    required this.ratingSum,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      login: json['login'],
      surname: json['surname'],
      name: json['name'],
      totalReviews: json['totalReviews'],
      ratingSum: json['ratingSum'],
    );
  }
}

class House {
  final int id;
  final String description;
  final String city;
  final String address;
  final UserModel user;

  House({
    required this.id,
    required this.description,
    required this.city,
    required this.address,
    required this.user,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      id: json['id'],
      description: json['description'],
      city: json['city'],
      address: json['address'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'city': city,
      'address': address,
      'user': user.toJson(),
    };
  }
}

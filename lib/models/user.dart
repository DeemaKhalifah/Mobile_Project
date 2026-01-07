class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final double balance;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.balance,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      balance: double.parse(json['balance'].toString()),
      role: json['role'],
    );
  }
}

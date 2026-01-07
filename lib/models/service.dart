class Service {
  final int id;
  final String name;
  final double price;
  final String image;
  final String description;

  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      price: double.parse(json['price'].toString()),
      image: json['image'],
      description: json['description'],
    );
  }
}

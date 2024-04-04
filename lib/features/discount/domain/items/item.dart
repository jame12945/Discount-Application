class Item {
  final int id;
  final String name;
  final double price;
  final String category;

  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      category: json['category'],
    );
  }
}

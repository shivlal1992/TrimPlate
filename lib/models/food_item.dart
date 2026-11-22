
class FoodItem {
  final int id;
  final String name;
  final String category;
  final String description;
  final double price;
  final int? calories;
  final String? imageUrl;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    this.calories,
    this.imageUrl,
  });

  factory FoodItem.fromJson(
      Map<String, dynamic> json,
      ) {
    return FoodItem(
      id: int.tryParse(
        json['id'].toString(),
      ) ??
          0,
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description:
      json['description']?.toString() ?? '',
      price: double.tryParse(
        json['price'].toString(),
      ) ??
          0,
      calories: int.tryParse(
        json['calories'].toString(),
      ),
      imageUrl: json['image_url']?.toString(),
    );
  }
}

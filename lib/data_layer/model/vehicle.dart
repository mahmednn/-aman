class VehicleModel {
  final int id;
  final String name;
  final String slug;
  final String image;
  final String imageUrl;
  final double basePrice;
  final bool isActive;
  final String? description;

  VehicleModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
    required this.imageUrl,
    required this.basePrice,
    required this.isActive,
    this.description,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      image: json['image'] as String,
      imageUrl: json['image_url'] as String,
      basePrice: double.tryParse(json['base_price'].toString()) ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      description: json['description']?.toString(),
    );
  }
}

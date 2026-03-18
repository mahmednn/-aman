class SupplierModel {
  final int id;
  final int? userId;
  final String? logo;
  final int? supplierCategoryId;
  final String? slug;
  final String? address;
  final String? logoUrl;
  final String? rating;
  final double? latitude;
  final double? longitude;
  final bool? isAvailable;
  final bool? isActive;
  final int? zoneId;
  final String? commissionRate;
  final String? createdAt;
  final String? updatedAt;

  final UserModel? user;
  final ZoneModel? zone;
  final SupplierCategoryModel? supplierCategory;
  final List<ProductModel>? products;

  SupplierModel({
    required this.id,
    this.userId,
    this.logo,
    this.supplierCategoryId,
    this.slug,
    this.address,
    this.logoUrl,
    this.rating,
    this.latitude,
    this.longitude,
    this.isAvailable,
    this.isActive,
    this.zoneId,
    this.commissionRate,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.zone,
    this.supplierCategory,
    this.products,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      userId: json['user_id'],
      logo: json['logo'],
      supplierCategoryId: json['supplier_category_id'],
      slug: json['slug'],
      address: json['address'],
      logoUrl: json['logo_url'],
      rating: json['rating']?.toString(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isAvailable: json['is_available'] == 1 || json['is_available'] == true || json['is_available'] == '1',
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == '1',
      zoneId: json['zone_id'],
      commissionRate: json['commission_rate']?.toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      zone: json['zone'] != null ? ZoneModel.fromJson(json['zone']) : null,
      supplierCategory: json['supplier_category'] != null
          ? SupplierCategoryModel.fromJson(json['supplier_category'])
          : null,
      products: json['products'] != null
          ? List<ProductModel>.from(
              json['products'].map((x) => ProductModel.fromJson(x)),
            )
          : [],
    );
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString(),
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class SupplierCategoryModel {
  final int id;
  final String name;
  final String? image;
  final String? imageUrl;
  final String? slug;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  SupplierCategoryModel({
    required this.id,
    required this.name,
    this.image,
    this.imageUrl,
    this.slug,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory SupplierCategoryModel.fromJson(Map<String, dynamic> json) {
    return SupplierCategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'],
      imageUrl: json['image_url'],
      slug: json['slug'],
      isActive: json['is_active'] == "1" || json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class ZoneModel {
  final int id;
  final String name;
  final double? centerLat;
  final double? centerLng;
  final int? radiusMeters;
  final String? createdAt;
  final String? updatedAt;

  ZoneModel({
    required this.id,
    required this.name,
    this.centerLat,
    this.centerLng,
    this.radiusMeters,
    this.createdAt,
    this.updatedAt,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id'],
      name: json['name'] ?? '',
      centerLat: json['center_lat']?.toDouble(),
      centerLng: json['center_lng']?.toDouble(),
      radiusMeters: json['radius_meters'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class ProductModel {
  final int id;
  final int? productCategoryId;
  final String name;
  final String? productCategory;
  final String? description;
  final String? slug;
  final String? img;
  final String? brand;
  final String? price;
  final int? quantity;
  final bool? isAvailable;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  
  final int? pivotSupplierId;
  final int? pivotProductId;
  final int? pivotId;

  ProductModel({
    required this.id,
    this.productCategoryId,
    required this.name,
    this.productCategory,
    this.description,
    this.slug,
    this.img,
    this.brand,
    this.price,
    this.quantity,
    this.isAvailable,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.pivotSupplierId,
    this.pivotProductId,
    this.pivotId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final pivot = json['pivot'];

    return ProductModel(
      id: json['id'],
      productCategoryId: json['product_category_id'],
      productCategory: pivot != null
          ? pivot['product_category_id']?.toString()
          : null,
      name: json['name'] ?? '',
      description: json['description'],
      slug: json['slug'],
      img: json['img'],
      brand: json['brand'],
      price: pivot != null ? pivot['price']?.toString() : null,
      quantity: pivot != null ? pivot['quantity'] : null,
      isAvailable: pivot != null ? (pivot['is_available'] == 1 || pivot['is_available'] == true || pivot['is_available'] == '1') : null,
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == '1',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      pivotSupplierId: pivot != null ? pivot['supplier_id'] : null,
      pivotProductId: pivot != null ? pivot['product_id'] : null,
      pivotId: pivot != null
          ? (pivot['id'] ?? pivot['product_supplier_id'] ?? pivot['pivot_id'])
          : (json['product_supplier_id'] ?? json['pivot_id']),
    );
  }
}

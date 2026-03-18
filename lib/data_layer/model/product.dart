class ProductResponse {
  final bool status;
  final List<ProductModel> data;

  ProductResponse({
    required this.status,
    required this.data,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class ProductModel {
  final int id;
  final int productCategoryId;
  final String productCategoryName;
  final String name;
  final String description;
  final String slug;
  final String img;
  final String brand;
  final bool isActive;
  final List<ProductSupplierModel> suppliers;
  final String createdAt;
  final String updatedAt;

  ProductModel({
    required this.id,
    required this.productCategoryId,
    required this.productCategoryName,
    required this.name,
    required this.description,
    required this.slug,
    required this.img,
    required this.brand,
    required this.isActive,
    required this.suppliers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      productCategoryId: json['product_category_id'] ?? 0,
      productCategoryName: json['product_category_name'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      slug: json['slug'] ?? '',
      img: json['img'] ?? '',
      brand: json['brand'] ?? '',
      isActive: json['is_active'] ?? false,
      suppliers: (json['suppliers'] as List<dynamic>?)
              ?.map((e) => ProductSupplierModel.fromJson(e))
              .toList() ??
          [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_category_id': productCategoryId,
      'product_category_name': productCategoryName,
      'name': name,
      'description': description,
      'slug': slug,
      'img': img,
      'brand': brand,
      'is_active': isActive,
      'suppliers': suppliers.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ProductSupplierModel {
  final int productSupplierId;
  final int supplierId;
  final String supplierName;
  final num price;
  final int quantity;
  final bool isActive;
  final bool isAvailable;

  ProductSupplierModel({
    required this.productSupplierId,
    required this.supplierId,
    required this.supplierName,
    required this.price,
    required this.quantity,
    required this.isActive,
    required this.isAvailable,
  });

  factory ProductSupplierModel.fromJson(Map<String, dynamic> json) {
    return ProductSupplierModel(
      productSupplierId: json['product_supplier_id'] ?? 0,
      supplierId: json['supplier_id'] ?? 0,
      supplierName: json['supplier_name'] ?? '',
      price: json['price'] ?? 0.0,
      quantity: json['quantity'] ?? 0,
      isActive: json['is_active'] ?? false,
      isAvailable: json['is_available'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_supplier_id': productSupplierId,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'price': price,
      'quantity': quantity,
      'is_active': isActive,
      'is_available': isAvailable,
    };
  }
}

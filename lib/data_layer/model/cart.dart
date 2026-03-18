class CartModel {
  final int id;
  final int customerId;
  final int supplierId;
  final String? supplierName;
  final String status;
  final int itemsCount;
  final num subtotal;
  final List<CartItemModel> items;
  final String createdAt;
  final String updatedAt;
  final String? notes; // Kept as optional just in case
  final String? supplierLogo; // Kept as optional just in case

  CartModel({
    required this.id,
    required this.customerId,
    required this.supplierId,
    this.supplierName,
    required this.status,
    required this.itemsCount,
    required this.subtotal,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.supplierLogo,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      customerId: json['customer_id'] is int ? json['customer_id'] : int.tryParse(json['customer_id']?.toString() ?? '0') ?? 0,
      supplierId: json['supplier_id'] is int ? json['supplier_id'] : int.tryParse(json['supplier_id']?.toString() ?? '0') ?? 0,
      supplierName: json['supplier_name']?.toString(),
      status: json['status']?.toString() ?? 'active',
      itemsCount: json['items_count'] is int ? json['items_count'] : int.tryParse(json['items_count']?.toString() ?? '0') ?? 0,
      subtotal: num.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      items: json['items'] != null
          ? List<CartItemModel>.from(
              (json['items'] as List).map((x) => CartItemModel.fromJson(x)),
            )
          : [],
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      notes: json['notes']?.toString(),
      supplierLogo: json['supplier_logo']?.toString(),
    );
  }
}

class CartItemModel {
  final int id;
  final int productSupplierId;
  final int productId;
  final String? productName;
  final String? productImage;
  final int supplierId;
  final int quantity;
  final int? availableQuantity;
  final num currentPrice;
  final bool isAvailable;
  final bool isActive;
  final num lineTotal;

  CartItemModel({
    required this.id,
    required this.productSupplierId,
    required this.productId,
    this.productName,
    this.productImage,
    required this.supplierId,
    required this.quantity,
    this.availableQuantity,
    required this.currentPrice,
    required this.isAvailable,
    required this.isActive,
    required this.lineTotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      productSupplierId: json['product_supplier_id'] is int ? json['product_supplier_id'] : int.tryParse(json['product_supplier_id']?.toString() ?? '0') ?? 0,
      productId: json['product_id'] is int ? json['product_id'] : int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      productName: json['product_name']?.toString(),
      productImage: json['product_image']?.toString(),
      supplierId: json['supplier_id'] is int ? json['supplier_id'] : int.tryParse(json['supplier_id']?.toString() ?? '0') ?? 0,
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      availableQuantity: json['available_quantity'] is int ? json['available_quantity'] : int.tryParse(json['available_quantity']?.toString() ?? ''),
      currentPrice: num.tryParse(json['current_price']?.toString() ?? '0') ?? 0,
      isAvailable: json['is_available'] == true,
      isActive: json['is_active'] == true,
      lineTotal: num.tryParse(json['line_total']?.toString() ?? '0') ?? 0,
    );
  }
}

class CheckoutPreviewModel {
  final LocationModel location;
  final String paymentMethod;
  final VehiclePreviewModel? vehicleType;
  final WalletModel? wallet;
  final List<OrderPreviewModel> orders;
  final SummaryPreviewModel summary;

  CheckoutPreviewModel({
    required this.location,
    required this.paymentMethod,
    this.vehicleType,
    this.wallet,
    required this.orders,
    required this.summary,
  });

  factory CheckoutPreviewModel.fromJson(Map<String, dynamic> json) {
    return CheckoutPreviewModel(
      location: LocationModel.fromJson(json['location'] ?? {}),
      paymentMethod: json['payment_method']?.toString() ?? 'cash',
      vehicleType: json['vehicle_type'] != null ? VehiclePreviewModel.fromJson(json['vehicle_type']) : null,
      wallet: json['wallet'] != null ? WalletModel.fromJson(json['wallet']) : null,
      orders: json['orders'] != null ? List<OrderPreviewModel>.from(
        (json['orders'] as List).map((x) => OrderPreviewModel.fromJson(x))
      ) : [],
      summary: SummaryPreviewModel.fromJson(json['summary'] ?? {}),
    );
  }
}

class LocationModel {
  final int id;
  final String name;
  final String address;

  LocationModel({required this.id, required this.name, required this.address});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }
}

class VehiclePreviewModel {
  final int id;
  final String name;

  VehiclePreviewModel({required this.id, required this.name});

  factory VehiclePreviewModel.fromJson(Map<String, dynamic> json) {
    return VehiclePreviewModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class WalletModel {
  final bool enabled;
  final num balance;
  final String formattedBalance;

  WalletModel({
    required this.enabled,
    required this.balance,
    required this.formattedBalance,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      enabled: json['enabled'] == true,
      balance: num.tryParse(json['balance']?.toString() ?? '0') ?? 0,
      formattedBalance: json['formatted_balance']?.toString() ?? '',
    );
  }
}

class OrderPreviewModel {
  final int cartId;
  final String supplierName;
  final num distanceMeters;
  final num subtotal;
  final num deliveryFee;
  final num total;
  final List<OrderItemPreviewModel> items;

  OrderPreviewModel({
    required this.cartId,
    required this.supplierName,
    required this.distanceMeters,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.items,
  });

  factory OrderPreviewModel.fromJson(Map<String, dynamic> json) {
    return OrderPreviewModel(
      cartId: json['cart_id'] is int ? json['cart_id'] : int.tryParse(json['cart_id']?.toString() ?? '0') ?? 0,
      supplierName: json['supplier_name']?.toString() ?? '',
      distanceMeters: num.tryParse(json['distance_meters']?.toString() ?? '0') ?? 0,
      subtotal: num.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      deliveryFee: num.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0,
      total: num.tryParse(json['total']?.toString() ?? '0') ?? 0,
      items: json['items'] != null ? List<OrderItemPreviewModel>.from(
        (json['items'] as List).map((x) => OrderItemPreviewModel.fromJson(x))
      ) : [],
    );
  }
}

class OrderItemPreviewModel {
  final int cartItemId;
  final String productName;
  final num price;
  final int quantity;
  final num lineTotal;

  OrderItemPreviewModel({
    required this.cartItemId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.lineTotal,
  });

  factory OrderItemPreviewModel.fromJson(Map<String, dynamic> json) {
    return OrderItemPreviewModel(
      cartItemId: json['cart_item_id'] is int ? json['cart_item_id'] : int.tryParse(json['cart_item_id']?.toString() ?? '0') ?? 0,
      productName: json['product_name']?.toString() ?? '',
      price: num.tryParse(json['price']?.toString() ?? '0') ?? 0,
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      lineTotal: num.tryParse(json['line_total']?.toString() ?? '0') ?? 0,
    );
  }
}

class SummaryPreviewModel {
  final num subtotal;
  final num deliveryFee;
  final num total;
  final num walletDeduction;
  final num cashRemaining;

  SummaryPreviewModel({
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.walletDeduction,
    required this.cashRemaining,
  });

  factory SummaryPreviewModel.fromJson(Map<String, dynamic> json) {
    return SummaryPreviewModel(
      subtotal: num.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      deliveryFee: num.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0,
      total: num.tryParse(json['total']?.toString() ?? '0') ?? 0,
      walletDeduction: num.tryParse(json['wallet_deduction']?.toString() ?? '0') ?? 0,
      cashRemaining: num.tryParse(json['cash_remaining']?.toString() ?? '0') ?? 0,
    );
  }
}

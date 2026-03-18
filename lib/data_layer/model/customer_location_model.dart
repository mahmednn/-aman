class CustomerLocationModel {
  final int? id;
  final int? customerId;
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int? isDefault;
  final String? createdAt;
  final String? updatedAt;

  CustomerLocationModel({
    this.id,
    this.customerId,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerLocationModel.fromJson(Map<String, dynamic> json) {
    int? parsedIsDefault;
    if (json['is_default'] != null) {
      if (json['is_default'] == true ||
          json['is_default'] == 1 ||
          json['is_default'] == '1') {
        parsedIsDefault = 1;
      } else {
        parsedIsDefault = 0;
      }
    }

    return CustomerLocationModel(
      id: json['id'],
      customerId: json['customer_id'],
      name: json['name']?.toString(),
      address: json['address']?.toString(),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      isDefault: parsedIsDefault,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class LocationResponse {
  final bool status;
  final String? message;
  final List<CustomerLocationModel>? data;
  final CustomerLocationModel? singleData;

  LocationResponse({
    required this.status,
    this.message,
    this.data,
    this.singleData,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    bool isSuccess =
        json['status'] == true ||
        json['status'] == 'success' ||
        (json.containsKey('data') && json['data'] != null);

    if (!isSuccess && json.containsKey('message')) {
      final msg = json['message']?.toString().toLowerCase() ?? '';
      if (msg.contains('success') || msg.contains('تم')) {
        isSuccess = true;
      }
    }

    List<CustomerLocationModel>? parsedData;
    CustomerLocationModel? parsedSingleData;

    if (json['data'] != null) {
      if (json['data'] is List) {
        parsedData = (json['data'] as List)
            .map((item) => CustomerLocationModel.fromJson(item))
            .toList();
      } else if (json['data'] is Map<String, dynamic>) {
        parsedSingleData = CustomerLocationModel.fromJson(json['data']);
        parsedData = [parsedSingleData];
      }
    }

    return LocationResponse(
      status: isSuccess,
      message: json['message']?.toString(),
      data: parsedData ?? [],
      singleData: parsedSingleData,
    );
  }
}

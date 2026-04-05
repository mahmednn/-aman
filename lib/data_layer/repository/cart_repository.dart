import 'package:dio/dio.dart';
import '../model/cart.dart';
import '../model/vehicle.dart';
import '../model/checkout_preview.dart';
import '../web_services/cart_services.dart';

class CartRepository {
  final CartServices cartServices;

  CartRepository(this.cartServices);

  Future<List<CartModel>> getCarts() async {
    try {
      final response = await cartServices.getCarts();
      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        final data = responseData is Map<String, dynamic> ? responseData['data'] : null;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(CartModel.fromJson)
              .toList();
        }
      }
      return [];
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return [];
      }
      throw _handleError(e);
    }
  }
  
  Future<List<VehicleModel>> getVehicleTypes() async {
    try {
      final response = await cartServices.getVehicleTypes();
      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        final data = responseData is Map<String, dynamic> ? responseData['data'] : null;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(VehicleModel.fromJson)
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CartModel?> getCartBySupplier(int supplierId) async {
    try {
      final response = await cartServices.getCartBySupplier(supplierId);
      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData['data'] is Map<String, dynamic>) {
          return CartModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> addToCart(
    int productId,
    int quantity,
    int productSupplierId,
  ) async {
    try {
      final response = await cartServices.addToCart(productId, quantity, productSupplierId);
      return {'success': true, 'message': _extractMessage(response.data, 'تمت الإضافة بنجاح')};
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateCartItem(int cartItemId, int quantity) async {
    try {
      final response = await cartServices.updateCartItem(cartItemId, quantity);
      return {'success': true, 'message': _extractMessage(response.data, 'تم التحديث بنجاح')};
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> removeCartItem(int cartItemId) async {
    try {
      final response = await cartServices.removeCartItem(cartItemId);
      return {'success': true, 'message': _extractMessage(response.data, 'تم إزالة المنتج')};
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> clearCart(int cartId) async {
    try {
      final response = await cartServices.clearCart(cartId);
      return {'success': true, 'message': _extractMessage(response.data, 'تم تفريغ السلة')};
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CheckoutPreviewModel> previewCheckout({
    required int locationId,
    required List<int> cartIds,
    required int vehicleTypeId,
    required String paymentMethod,
    num walletAmount = 0,
  }) async {
    try {
      final response = await cartServices.previewCheckout(
        locationId: locationId,
        cartIds: cartIds,
        vehicleTypeId: vehicleTypeId,
        paymentMethod: paymentMethod,
        walletAmount: walletAmount,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData['data'] is Map<String, dynamic>) {
          return CheckoutPreviewModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
      }
      throw 'تنسيق بيانات المعاينة غير صحيح';
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 401 || statusCode == 403) {
          return 'انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مجددًا.';
        } else if (statusCode == 422) {
          return _extractMessage(data, 'بيانات غير صالحة، يرجى التحقق من الكمية أو المنتج.');
        } else if (statusCode == 500) {
          return 'حدث خطأ في الخادم (السيرفر)، الرجاء المحاولة لاحقًا.';
        } else {
          return _extractMessage(data, 'حدث خطأ غير متوقع ($statusCode).');
        }
      } else {
        return 'لا يوجد اتصال بالإنترنت أو تعذر الوصول للسيرفر.';
      }
    }
    return 'حدث خطأ غير معروف: ${error.toString()}';
  }

  String _extractMessage(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    return fallback;
  }
}

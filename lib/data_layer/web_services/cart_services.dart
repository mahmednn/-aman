import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/strings.dart';

class CartServices {
  late Dio dio;

  CartServices() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl1,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    dio = Dio(options);

    // Auth Interceptor for dynamic token attachment
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    // Logger
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
      ),
    );
  }

  Future<Response> getCarts() async {
    return await dio.get(getCartsEndpoint);
  }

  Future<Response> getCartBySupplier(int supplierId) async {
    return await dio.get('$getCartBySupplierEndpoint$supplierId');
  }

  Future<Response> addToCart(int productId, int quantity, int productSupplierId) async {
    return await dio.post(
      addToCartEndpoint,
      data: {
        'product_id': productId,
        'quantity': quantity,
        'product_supplier_id': productSupplierId,
      },
    );
  }

  Future<Response> updateCartItem(int cartItemId, int quantity) async {
    return await dio.put(
      '$updateCartItemEndpoint$cartItemId',
      data: {'quantity': quantity},
    );
  }

  Future<Response> removeCartItem(int cartItemId) async {
    return await dio.delete('$removeCartItemEndpoint$cartItemId');
  }

  Future<Response> clearCart(int cartId) async {
    return await dio.delete('$clearCartEndpoint$cartId/clear');
  }
}

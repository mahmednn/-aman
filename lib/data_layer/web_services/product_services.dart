import 'package:dio/dio.dart';

class ProductServices {
  final Dio dio;

  ProductServices(this.dio);

  Future<Response> getAllProducts() async {
    return await dio.get('public/products');
  }
}

import 'package:flutter_application_11/data_layer/model/product.dart';
import 'package:flutter_application_11/data_layer/web_services/product_services.dart';

class ProductRepository {
  final ProductServices productServices;

  ProductRepository(this.productServices);

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await productServices.getAllProducts();
      if (response.statusCode == 200 && response.data != null) {
        // The API response matches ProductResponse which has a 'status' and 'data' list.
        final productResponse = ProductResponse.fromJson(response.data);
        return productResponse.data;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_application_11/constants/strings.dart';

class SupplierServices {
  Dio dio = Dio();

  SupplierServices({Dio? dio}) {
    if (dio != null) {
      this.dio = dio;
    } else {
      BaseOptions options = BaseOptions(
        baseUrl: baseUrl1, // Use standard baseUrl
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      );
      this.dio = Dio(options);
    }
  }

  Future<List<Map<String, dynamic>>> getSuppliers() async {
    print("SupplierServices: getSuppliers called");
    print("SupplierServices: Base URL: ${dio.options.baseUrl}");
    print("SupplierServices: Headers: ${dio.options.headers}");

    try {
      Response response = await dio.get('public/suppliers');

      print("SupplierServices: Response status code: ${response.statusCode}");
      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        print("SupplierServices: Response status: ${body['status']}");

        if (body['status'] == true && body['data'] is List) {
          final List<dynamic> dataList = body['data'];
          print("SupplierServices: Found ${dataList.length} suppliers");
          return dataList.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('SupplierServices: Error fetching suppliers: $e');
      return [];
    }
  }
}

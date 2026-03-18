import 'package:dio/dio.dart';
import 'package:flutter_application_11/constants/strings.dart';

class CategoryServices {
  Dio dio = Dio();

  CategoryServices({Dio? dio}) {
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

  Future<List<Map<String, dynamic>>> getCategories() async {
    print("CategoryServices: getCategories called");
    print("CategoryServices: Base URL: ${dio.options.baseUrl}");

    try {
      Response response = await dio.get('public/supplier-categories');

      print("CategoryServices: Response status code: ${response.statusCode}");
      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        print("CategoryServices: Response status: ${body['status']}");

        if ((body['status'] == true || body['status'] == 'success') &&
            body['data'] is List) {
          final List<dynamic> dataList = body['data'];
          print("CategoryServices: Found ${dataList.length} categories");
          return dataList.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('CategoryServices: Error fetching categories: $e');
      return [];
    }
  }
}

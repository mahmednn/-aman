import 'package:flutter_application_11/data_layer/model/category.dart';
import 'package:flutter_application_11/data_layer/web_services/category_services.dart';

class CategoryRepo {
  final CategoryServices categoryServices;

  CategoryRepo({required this.categoryServices});

  Future<List<CategoryModel>> getCategories() async {
    // هنا الـ response هو الـ List القادمة من السيرفس مباشرة
    final response = await categoryServices.getCategories();

    // تحويل كل Map داخل القائمة إلى CategoryModel
    return response
        .map((categoryJson) => CategoryModel.fromJson(categoryJson))
        .toList();
  }
}

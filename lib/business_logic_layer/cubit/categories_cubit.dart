import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application_11/data_layer/model/category.dart';
import 'package:flutter_application_11/data_layer/repository/category_repo.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoryRepo categoryRepo;
  List<CategoryModel> categories = [];

  CategoriesCubit({required this.categoryRepo}) : super(CategoriesInitial());

  // categories_cubit.dart

  void getAllCategories() async {
    emit(CategoriesLoading(const [])); // إرسال حالة التحميل أولاً
    try {
      final categoriesList = await categoryRepo.getCategories();
      emit(CategoriesLoaded(categoriesList));
      categories = categoriesList;
    } catch (error) {
      emit(CategoriesError(error.toString()));
    }
  }
}
